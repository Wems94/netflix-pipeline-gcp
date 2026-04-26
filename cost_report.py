import os
import logging
from datetime import datetime, timezone
from google.cloud import bigquery
from google.oauth2 import service_account

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

# ============================================================
# CONFIGURAÇÕES
# ============================================================
PROJECT_ID      = "netflix-pipeline-gcp"
PRECO_POR_TB    = 5.0    # USD por TB processado (política do BigQuery)
CREDITO_INICIAL = 300.0  # USD de crédito gratuito do GCP


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


client = get_client()

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
    logger.info("=" * 60)
    logger.info("RELATORIO DE CUSTO - NETFLIX PIPELINE GCP")
    logger.info("=" * 60)
    logger.info("Gerado em: %s", datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
    logger.info("Projeto: %s", PROJECT_ID)
    logger.info("=" * 60)

    jobs = buscar_jobs_do_dia()

    if not jobs:
        logger.warning("Nenhum job encontrado hoje.")
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
            "estado"  : job.state,
        })

    custo_total = calcular_custo(total_bytes)

    logger.info("\n%-25s %10s %12s %10s %10s", "JOB ID", "DADOS", "CUSTO (USD)", "DURACAO", "ESTADO")
    logger.info("-" * 70)
    for l in linhas:
        logger.info("%-25s %10s $%11.6f %10s %10s",
                    l["job_id"], l["tamanho"], l["custo"], l["duracao"], l["estado"])

    logger.info("-" * 70)
    logger.info("Total de jobs executados : %d", total_jobs)
    logger.info("Total de dados processados: %s", formatar_tamanho(total_bytes))
    logger.info("Custo total estimado      : $%.6f USD", custo_total)
    logger.info("=" * 60)
    logger.info("CREDITOS GCP")
    logger.info("Credito inicial          : $%.2f USD", CREDITO_INICIAL)
    logger.info("Consumido hoje           : $%.6f USD", custo_total)
    logger.info("Credito restante estimado: $%.6f USD", CREDITO_INICIAL - custo_total)
    logger.info("Nota: O BigQuery oferece 1 TB gratuito por mes.")
    logger.info("Acima disso, o custo e de $%.1f/TB processado.", PRECO_POR_TB)
    logger.info("=" * 60)

if __name__ == "__main__":
    gerar_relatorio()
