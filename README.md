![Netflix](https://img.shields.io/badge/Netflix-E50914?style=for-the-badge&logo=netflix&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-%2300758F.svg?style=for-the-badge&logo=mysql&logoColor=white)
![GCP](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![BigQuery](https://img.shields.io/badge/BigQuery-4285F4?style=for-the-badge&logo=google-bigquery&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Metabase](https://img.shields.io/badge/Metabase-509EE3?style=for-the-badge&logo=metabase&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

---

# Pipeline de Dados com BigQuery e Metabase — Arquitetura Medallion (Bronze, Silver e Gold)

Pipeline de dados ponta a ponta utilizando o dataset **MovieLens Beliefs 2024** para construção de uma plataforma de analytics de filmes, com modelagem dimensional no BigQuery e visualização via Metabase.

> Projeto baseado no [Desafio Técnico 01](https://meadow-squid-e0b.notion.site/Desafio-t-cnico-01-Case-real-com-BigQuery-e-Metabase-8f920ba56c5a829e926481d46d4156c4) da comunidade **Dados Por Todos**.

---

## 🗂️ Estrutura do Repositório

```
netflix-pipeline-gcp/
├── catalog/
│   └── catalog.yml              # Catálogo de dados (descrição de tabelas e colunas)
├── data/                        # Dataset local (não versionado)
│   └── data_release/
│       ├── movies.csv
│       ├── belief_data.csv
│       ├── user_rating_history.csv
│       ├── ratings_for_additional_users.csv
│       ├── movie_elicitation_set.csv
│       └── user_recommendation_history.csv
├── sql/
│   ├── bronze/                  # Tabelas externas (raw)
│   │   ├── raw_movies.sql
│   │   ├── raw_belief_data.sql
│   │   ├── raw_user_rating_history.sql
│   │   ├── raw_ratings_for_additional_users.sql
│   │   ├── raw_movie_elicitation_set.sql
│   │   └── raw_user_recommendation_history.sql
│   ├── silver/                  # Tabelas nativas (limpas e tipadas)
│   │   ├── dim_movies.sql
│   │   └── fact_ratings.sql
│   └── gold/                    # Views analíticas para o Metabase
│       ├── vw_movies_kpis.sql
│       ├── vw_genre_performance.sql
│       ├── vw_ratings_heatmap.sql
│       ├── vw_top_movies.sql
│       ├── vw_user_activity.sql
│       └── vw_scatter_popularity_vs_quality.sql
├── pipeline.py                  # Script de automação do pipeline
├── cost_report.py               # Script de análise de custo e créditos GCP
├── movielens_dataset_readme.md  # Documentação do dataset
└── README.md
```

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Finalidade |
|---|---|
| **Google Cloud Storage (GCS)** | Armazenamento dos arquivos CSV (camada raw) |
| **BigQuery** | Data Warehouse — processamento e modelagem SQL |
| **Docker** | Containerização do Metabase |
| **Metabase** | Ferramenta de BI para criação de dashboards |
| **SQL** | Transformação e modelagem dimensional |
| **Python** | Automação do pipeline e relatório de custos |
| **gcloud CLI** | Gerenciamento do GCP via terminal |

---

## 🏗️ Arquitetura Medallion

O projeto segue a arquitetura Medallion, dividida em três camadas que garantem rastreabilidade, qualidade e reusabilidade dos dados:

```
[CSVs locais] → [GCS Bucket] → [BigQuery Bronze] → [BigQuery Silver] → [BigQuery Gold] → [Metabase]
```

### 🥉 Camada Bronze — Raw

Os arquivos CSV são carregados no **Google Cloud Storage** e expostos no BigQuery como **External Tables**, sem nenhuma transformação. Todos os campos permanecem como `STRING`.

- Dataset BigQuery: `netflix_raw`
- Fonte: [MovieLens Beliefs Dataset 2024](https://grouplens.org/datasets/movielens/ml_belief_2024/)

### 🥈 Camada Silver — Limpeza e Tipagem

Os dados brutos da Bronze são transformados em **tabelas nativas** do BigQuery. Principais transformações:

- Conversão de tipos: `STRING` → `INT64`, `FLOAT64`, `TIMESTAMP`
- Tratamento de nulos com `SAFE_CAST` e `NULLIF`
- Remoção de registros inválidos (user_id, movie_id ou rating nulos)
- Extração do ano de lançamento via `REGEXP_EXTRACT`
- União de duas fontes de ratings via `UNION ALL`

- Dataset BigQuery: `netflix_analytical`
- Tabelas: `dim_movies`, `fact_ratings`

### 🥇 Camada Gold — Camada Analítica

Views criadas sobre a Silver para alimentar diretamente os dashboards no Metabase com KPIs e métricas de negócio calculadas:

| View | Descrição |
|---|---|
| `vw_movies_kpis` | Média, total e desvio padrão de ratings por filme |
| `vw_genre_performance` | Performance e volume de avaliações por gênero |
| `vw_ratings_heatmap` | Volume de ratings por mês/ano |
| `vw_top_movies` | Ranking dos filmes mais avaliados |
| `vw_user_activity` | Atividade e engajamento por usuário |
| `vw_scatter_popularity_vs_quality` | Filmes com 50+ avaliações (popularidade vs qualidade) |

- Dataset BigQuery: `netflix_analytical`

---

## ✅ Pré-requisitos

Antes de executar o projeto, certifique-se de ter instalado:

- [VS Code](https://code.visualstudio.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Python 3.10+](https://www.python.org/)
- Conta no [Google Cloud Platform](https://cloud.google.com/) — novos usuários recebem **$300 de crédito gratuito**

---

## 🚀 Como Executar o Projeto

### 1. Clonar o repositório

```bash
git clone https://github.com/Wems94/netflix-pipeline-gcp.git
cd netflix-pipeline-gcp
```

### 2. Baixar o Dataset

Acesse [grouplens.org/datasets/movielens/ml_belief_2024](https://grouplens.org/datasets/movielens/ml_belief_2024/) e baixe o arquivo `ml_belief_2024_data_release_2.zip`.

```bash
unzip ml_belief_2024_data_release_2.zip -d data
```

### 3. Configurar o ambiente Python

```bash
python3 -m venv venv
source venv/bin/activate
pip install google-cloud-bigquery pyyaml
```

### 4. Configurar o GCP

```bash
# Autenticar no GCP
gcloud auth login

# Definir o projeto ativo
gcloud config set project netflix-pipeline-gcp
```

No [Google Cloud Console](https://console.cloud.google.com/):

- Crie um **Bucket** no Cloud Storage
- Faça upload de todos os arquivos `.csv` para `gs://SEU_BUCKET/bronze_movies/`
- Crie uma **Service Account** com as permissões:
  - `BigQuery Data Editor`
  - `BigQuery Job User`
  - `BigQuery Metadata Viewer`
  - `Storage Object Viewer`
  - `Storage Insights Collector Service`
- Salve o arquivo **JSON** da Service Account em `~/.config/gcp/netflix-pipeline-sa.json`

### 5. Executar o Pipeline

```bash
python pipeline.py
```

O script executa automaticamente todas as camadas na ordem correta e aplica as descrições do catálogo em cada tabela:

```
🚀 Iniciando pipeline Netflix...
📦 Criando datasets...
🥉 Executando camada Bronze...
🥈 Executando camada Silver...
🥇 Executando camada Gold...
🎉 Pipeline concluído com sucesso!
```

### 6. Analisar Custo e Créditos

```bash
python cost_report.py
```

Exibe um relatório com dados processados, custo estimado por job e créditos GCP restantes.

### 7. Subir o Metabase com Docker

```bash
docker run -d -p 3000:3000 --name metabase metabase/metabase
```

Acesse [http://localhost:3000](http://localhost:3000) e configure:

1. Crie a conta admin (primeiro acesso)
2. Vá em **Admin → Databases → Add database → BigQuery**
3. Informe o **Project ID** e faça upload do **Service Account JSON**
4. Sincronize: **Admin → Databases → Sync database schema**

### 8. Criar os Dashboards no Metabase

Exemplos de visualizações:

- 📊 Evolução de ratings ao longo do tempo (Heatmap)
- 🏆 Ranking Top 10 filmes mais bem avaliados (Bar Chart)
- 🎬 Filmes mais avaliados (Bar Chart)
- 🎭 Popularidade dos gêneros (Bar Chart)
- 🔵 Popularidade vs Qualidade (Scatter Plot)

---

## 📋 Catálogo de Dados

O arquivo `catalog/catalog.yml` documenta todas as tabelas e colunas do projeto. As descrições são aplicadas automaticamente no BigQuery a cada execução do pipeline.

---

## 👤 Autor

**William Sebastião**

Projeto executado como parte do **Desafio Técnico 01** da comunidade [Dados Por Todos](https://meadow-squid-e0b.notion.site/Desafio-t-cnico-01-Case-real-com-BigQuery-e-Metabase-8f920ba56c5a829e926481d46d4156c4).

Projeto original desenvolvido por [Andreza Santos](https://github.com/AndrezaSS/netflix-pipeline-gcp).