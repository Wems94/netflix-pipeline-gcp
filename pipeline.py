import os
import logging
import time
import yaml
from datetime import datetime, timezone
from google.cloud import bigquery
from google.oauth2 import service_account

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

PROJECT_ID   = "netflix-pipeline-gcp"
SQL_DIR      = os.path.join(os.path.dirname(__file__), "sql")
CATALOG_PATH = os.path.join(os.path.dirname(__file__), "catalog", "catalog.yml")

with open(CATALOG_PATH, "r") as f:
    catalog = yaml.safe_load(f)


def get_client() -> bigquery.Client:
    credentials_path = os.getenv(
        "GCP_SA_KEY_PATH",
        os.path.expanduser("~/.config/gcp/netflix-pipeline-sa.json"),
    )
    credentials = service_account.Credentials.from_service_account_file(
        credentials_path,
        scopes=["https://www.googleapis.com/auth/cloud-platform"],
    )
    return bigquery.Client(project=PROJECT_ID, credentials=credentials)


def buscar_catalogo(nome_tabela: str) -> dict:
    for camada in ["bronze", "silver", "gold"]:
        tabelas = catalog.get(camada, {})
        if nome_tabela in tabelas:
            return tabelas[nome_tabela]
    return {}


def criar_dataset(client: bigquery.Client, dataset_id: str):
    dataset_ref = f"{PROJECT_ID}.{dataset_id}"
    dataset = bigquery.Dataset(dataset_ref)
    dataset.location = "US"
    client.create_dataset(dataset, exists_ok=True)
    logger.info("Dataset '%s' pronto.", dataset_id)


def garantir_tabela_controle(client: bigquery.Client):
    schema = [
        bigquery.SchemaField("run_ts",     "TIMESTAMP"),
        bigquery.SchemaField("status",     "STRING"),
        bigquery.SchemaField("duration_s", "FLOAT64"),
        bigquery.SchemaField("error",      "STRING"),
    ]
    table_ref = f"{PROJECT_ID}.netflix_raw.pipeline_runs"
    table = bigquery.Table(table_ref, schema=schema)
    client.create_table(table, exists_ok=True)


def registrar_execucao(
    client: bigquery.Client, status: str, duracao_s: float, erro: str = ""
):
    rows = [{
        "run_ts":     datetime.now(timezone.utc).isoformat(),
        "status":     status,
        "duration_s": duracao_s,
        "error":      erro,
    }]
    errors = client.insert_rows_json(
        f"{PROJECT_ID}.netflix_raw.pipeline_runs", rows
    )
    if errors:
        logger.warning("Falha ao registrar execucao: %s", errors)


def aplicar_descricoes(client: bigquery.Client, dataset_id: str, nome_tabela: str):
    info = buscar_catalogo(nome_tabela)
    if not info:
        return

    table_ref = f"{PROJECT_ID}.{dataset_id}.{nome_tabela}"
    try:
        table = client.get_table(table_ref)
    except Exception:
        return

    table.description = info.get("description", "")
    colunas_catalogo = info.get("columns", {})
    novos_campos = [
        campo.from_api_repr({
            **campo.to_api_repr(),
            "description": colunas_catalogo.get(campo.name, ""),
        })
        for campo in table.schema
    ]
    table.schema = novos_campos
    client.update_table(table, ["description", "schema"])
    logger.info("Descricoes aplicadas: %s", nome_tabela)


def executar_sqls_da_pasta(client: bigquery.Client, pasta: str, dataset_id: str):
    caminho = os.path.join(SQL_DIR, pasta)
    arquivos = sorted([f for f in os.listdir(caminho) if f.endswith(".sql")])

    for arquivo in arquivos:
        caminho_arquivo = os.path.join(caminho, arquivo)
        with open(caminho_arquivo, "r") as f:
            query = f.read()

        logger.info("Executando: %s", arquivo)
        try:
            job = client.query(query)
            job.result()
            logger.info("Concluido: %s", arquivo)
        except Exception as e:
            logger.error("Falha ao executar %s: %s", arquivo, e)
            raise

        nome_tabela = arquivo.replace(".sql", "")
        aplicar_descricoes(client, dataset_id, nome_tabela)


def main():
    logger.info("Iniciando pipeline Netflix...")
    client = get_client()
    inicio = time.time()

    try:
        criar_dataset(client, "netflix_raw")
        criar_dataset(client, "netflix_analytical")
        garantir_tabela_controle(client)

        logger.info("Camada Bronze...")
        executar_sqls_da_pasta(client, "bronze", "netflix_raw")

        logger.info("Camada Silver...")
        executar_sqls_da_pasta(client, "silver", "netflix_analytical")

        logger.info("Camada Gold...")
        executar_sqls_da_pasta(client, "gold", "netflix_analytical")

        duracao = time.time() - inicio
        registrar_execucao(client, "SUCCESS", duracao)
        logger.info("Pipeline concluido em %.1fs.", duracao)

    except Exception as e:
        duracao = time.time() - inicio
        registrar_execucao(client, "FAILED", duracao, str(e))
        raise


if __name__ == "__main__":
    main()
