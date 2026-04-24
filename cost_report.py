import os
from datetime import datetime, timezone
from google.cloud import bigquery
from google.oauth2 import service_account

# ============================================================
# CONFIGURAÇÕES
# ============================================================
PROJECT_ID       = "netflix-pipeline-gcp"
CREDENTIALS_PATH = os.path.expanduser("~/.config/gcp/netflix-pipeline-sa.json")
PRECO_POR_TB     = 5.0  # USD por TB processado (política do BigQuery)
CREDITO_INICIAL  = 300.0  # USD de crédito gratuito do GCP

# ============================================================
# CONEXÃO COM O BIGQUERY
# ============================================================
credentials = service_account.Credentials.from_service_account_file(
    CREDENTIALS_PATH,
    scopes=["https://www.googleapis.com/auth/cloud-platform"]
)

client = bigquery.Client(project=PROJECT_ID, credentials=credentials)

# ============================================================
# FUNÇÕES
# ============================================================
def bytes_para_tb(bytes: int) -> float:
    return bytes / (1024 ** 4)

def calcular_custo(bytes: int) -> float:
    tb = bytes_para_tb(bytes)
    return tb * PRECO_POR_TB

def formatar_tamanho(bytes: int) -> str:
    if bytes >= 1024 ** 3:
        return f"{bytes / (1024 ** 3):.2f} GB"
    elif bytes >= 1024 ** 2:
        return f"{bytes / (1024 ** 2):.2f} MB"
    else:
        return f"{bytes / 1024:.2f} KB"

def buscar_jobs_do_dia() -> list:
    """Busca todos os jobs executados hoje no projeto."""
    hoje = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    jobs = client.list_jobs(all_users=True, min_creation_time=datetime.now(timezone.utc).replace(
        hour=0, minute=0, second=0, microsecond=0
    ))
    return list(jobs)

def gerar_relatorio():
    print("\n" + "="*60)
    print("📊 RELATÓRIO DE CUSTO — NETFLIX PIPELINE GCP")
    print("="*60)
    print(f"🕐 Gerado em: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
    print(f"📁 Projeto: {PROJECT_ID}")
    print("="*60)

    jobs = buscar_jobs_do_dia()

    if not jobs:
        print("\n⚠️  Nenhum job encontrado hoje.")
        return

    total_bytes = 0
    total_jobs  = 0
    linhas      = []

    for job in jobs:
        if not hasattr(job, "total_bytes_processed") or job.total_bytes_processed is None:
            continue

        bytes_processados = job.total_bytes_processed
        custo             = calcular_custo(bytes_processados)
        duracao           = None

        if job.ended and job.started:
            duracao = (job.ended - job.started).total_seconds()

        total_bytes += bytes_processados
        total_jobs  += 1

        linhas.append({
            "job_id"  : job.job_id[:20] + "...",
            "tamanho" : formatar_tamanho(bytes_processados),
            "custo"   : custo,
            "duracao" : f"{duracao:.1f}s" if duracao else "N/A",
            "estado"  : job.state
        })

    # Exibe tabela de jobs
    print(f"\n{'JOB ID':<25} {'DADOS':>10} {'CUSTO (USD)':>12} {'DURAÇÃO':>10} {'ESTADO':>10}")
    print("-" * 70)
    for l in linhas:
        print(f"{l['job_id']:<25} {l['tamanho']:>10} ${l['custo']:>11.6f} {l['duracao']:>10} {l['estado']:>10}")

    # Totais
    custo_total = calcular_custo(total_bytes)
    print("-" * 70)
    print(f"\n📦 Total de jobs executados : {total_jobs}")
    print(f"💾 Total de dados processados: {formatar_tamanho(total_bytes)}")
    print(f"💰 Custo total estimado      : ${custo_total:.6f} USD")

    # Créditos
    print("\n" + "="*60)
    print("💳 CRÉDITOS GCP")
    print("="*60)
    print(f"🎁 Crédito inicial          : ${CREDITO_INICIAL:.2f} USD")
    print(f"💸 Consumido hoje           : ${custo_total:.6f} USD")
    print(f"✅ Crédito restante estimado: ${CREDITO_INICIAL - custo_total:.6f} USD")
    print("\n⚠️  Nota: O BigQuery oferece 1 TB gratuito por mês.")
    print(f"   Acima disso, o custo é de ${PRECO_POR_TB}/TB processado.")
    print("   O crédito restante é uma estimativa baseada apenas no BigQuery.")
    print("="*60 + "\n")

if __name__ == "__main__":
    gerar_relatorio()
