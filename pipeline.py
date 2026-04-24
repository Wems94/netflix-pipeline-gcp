import os
import yaml
from google.cloud import bigquery
from google.oauth2 import service_account

# ============================================================
# CONFIGURAÇÕES
# ============================================================
PROJECT_ID       = "netflix-pipeline-gcp"
CREDENTIALS_PATH = os.path.expanduser("~/.config/gcp/netflix-pipeline-sa.json")
SQL_DIR          = os.path.join(os.path.dirname(__file__), "sql")
CATALOG_PATH     = os.path.join(os.path.dirname(__file__), "catalog", "catalog.yml")

# ============================================================
# CONEXÃO COM O BIGQUERY
# ============================================================
credentials = service_account.Credentials.from_service_account_file(
    CREDENTIALS_PATH,
    scopes=["https://www.googleapis.com/auth/cloud-platform"]
)

client = bigquery.Client(project=PROJECT_ID, credentials=credentials)

# ============================================================
# CARREGA O CATÁLOGO
# ============================================================
with open(CATALOG_PATH, "r") as f:
    catalog = yaml.safe_load(f)

# Mapeia nome da tabela para suas descrições no catálogo
# Ex: "raw_movies" -> { description: ..., columns: { movieId: ... } }
def buscar_catalogo(nome_tabela: str) -> dict:
    for camada in ["bronze", "silver", "gold"]:
        tabelas = catalog.get(camada, {})
        if nome_tabela in tabelas:
            return tabelas[nome_tabela]
    return {}

# ============================================================
# FUNÇÕES AUXILIARES
# ============================================================
def criar_dataset(dataset_id: str):
    """Cria um dataset no BigQuery se ele ainda não existir."""
    dataset_ref = f"{PROJECT_ID}.{dataset_id}"
    dataset = bigquery.Dataset(dataset_ref)
    dataset.location = "US"
    client.create_dataset(dataset, exists_ok=True)
    print(f"✅ Dataset '{dataset_id}' pronto.")


def aplicar_descricoes(dataset_id: str, nome_tabela: str):
    """Aplica descrições da tabela e colunas usando o catálogo YAML."""
    info = buscar_catalogo(nome_tabela)
    if not info:
        return

    table_ref = f"{PROJECT_ID}.{dataset_id}.{nome_tabela}"

    try:
        table = client.get_table(table_ref)
    except Exception:
        return  # tabela não encontrada, pula

    # Aplica descrição da tabela
    table.description = info.get("description", "")

    # Aplica descrição das colunas
    colunas_catalogo = info.get("columns", {})
    novos_campos = []
    for campo in table.schema:
        descricao = colunas_catalogo.get(campo.name, "")
        novo_campo = campo.from_api_repr({
            **campo.to_api_repr(),
            "description": descricao
        })
        novos_campos.append(novo_campo)

    table.schema = novos_campos
    client.update_table(table, ["description", "schema"])
    print(f"  📋 Descrições aplicadas: {nome_tabela}")


def executar_sqls_da_pasta(pasta: str, dataset_id: str):
    """Lê, executa todos os arquivos .sql de uma pasta e aplica descrições."""
    caminho = os.path.join(SQL_DIR, pasta)
    arquivos = sorted([f for f in os.listdir(caminho) if f.endswith(".sql")])

    for arquivo in arquivos:
        caminho_arquivo = os.path.join(caminho, arquivo)
        with open(caminho_arquivo, "r") as f:
            query = f.read()

        print(f"  ▶ Executando: {arquivo}")
        job = client.query(query)
        job.result()  # aguarda a conclusão
        print(f"  ✅ Concluído: {arquivo}")

        # Aplica descrições logo após a criação
        nome_tabela = arquivo.replace(".sql", "")
        aplicar_descricoes(dataset_id, nome_tabela)


# ============================================================
# PIPELINE PRINCIPAL
# ============================================================
def main():
    print("\n🚀 Iniciando pipeline Netflix...\n")

    # 1. Criar datasets
    print("📦 Criando datasets...")
    criar_dataset("netflix_raw")
    criar_dataset("netflix_analytical")

    # 2. Camada Bronze
    print("\n🥉 Executando camada Bronze...")
    executar_sqls_da_pasta("bronze", "netflix_raw")

    # 3. Camada Silver
    print("\n🥈 Executando camada Silver...")
    executar_sqls_da_pasta("silver", "netflix_analytical")

    # 4. Camada Gold
    print("\n🥇 Executando camada Gold...")
    executar_sqls_da_pasta("gold", "netflix_analytical")

    print("\n🎉 Pipeline concluído com sucesso!")


if __name__ == "__main__":
    main()
