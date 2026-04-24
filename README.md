![Netflix](https://img.shields.io/badge/Netflix-E50914?style=for-the-badge&logo=netflix&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-%2300758F.svg?style=for-the-badge&logo=mysql&logoColor=white)
![GCP](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![BigQuery](https://img.shields.io/badge/BigQuery-4285F4?style=for-the-badge&logo=google-bigquery&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Metabase](https://img.shields.io/badge/Metabase-509EE3?style=for-the-badge&logo=metabase&logoColor=white)

---

# Pipeline de Dados com BigQuery e Metabase — Arquitetura Medallion (Bronze, Silver e Gold)

Pipeline de dados ponta a ponta utilizando o dataset **MovieLens Beliefs 2024** para construção de uma plataforma de analytics de filmes, com modelagem dimensional no BigQuery e visualização via Metabase.

> Projeto baseado no [Desafio Técnico 01](https://meadow-squid-e0b.notion.site/Desafio-t-cnico-01-Case-real-com-BigQuery-e-Metabase-8f920ba56c5a829e926481d46d4156c4) da comunidade **Dados Por Todos**.

---

## 🗂️ Estrutura do Repositório

```
netflix-pipeline-gcp/
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
- Conta no [Google Cloud Platform](https://cloud.google.com/) — novos usuários recebem **$300 de crédito gratuito**

---

## 🚀 Como Executar o Projeto

### 1. Baixar o Dataset

Acesse [grouplens.org/datasets/movielens/ml_belief_2024](https://grouplens.org/datasets/movielens/ml_belief_2024/) e baixe o arquivo `ml_belief_2024_data_release_2.zip` (versão atualizada de fev/2025).

```bash
unzip ml_belief_2024_data_release_2.zip -d data
```

### 2. Configurar o GCP

```bash
# Autenticar no GCP
gcloud auth login

# Definir o projeto ativo
gcloud config set project netflix-pipeline-gcp
```

No [Google Cloud Console](https://console.cloud.google.com/):

- Crie um **Bucket** no Cloud Storage (ex: `raw_movies_netflix`)
- Crie a pasta `bronze_movies/` dentro do bucket
- Faça upload de todos os arquivos `.csv` para `gs://raw_movies_netflix/bronze_movies/`
- Crie uma **Service Account** com as permissões:
  - `BigQuery Data Viewer`
  - `BigQuery Job User`
  - `BigQuery Metadata Viewer`
  - `Storage Insights Viewer`
- Gere e baixe o arquivo **JSON** da Service Account

### 3. Camada Bronze — Tabelas Externas

No editor do BigQuery, crie o dataset `netflix_raw` e execute os 6 SQLs da pasta `sql/bronze/`.

> ⚠️ Substitua `netflix-pipeline-gcp` pelo ID do seu projeto GCP e `SEU_BUCKET` pelo nome do seu bucket em todos os arquivos SQL.

Exemplo — `raw_movies.sql`:

```sql
CREATE OR REPLACE EXTERNAL TABLE `netflix-pipeline-gcp.netflix_raw.raw_movies`
(
  movieId STRING,
  title   STRING,
  genres  STRING
)
OPTIONS (
  format               = 'CSV',
  uris                 = ['gs://SEU_BUCKET/bronze_movies/movies.csv'],
  skip_leading_rows    = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows    = TRUE
);
```

### 4. Camada Silver — Tabelas Nativas

Crie o dataset `netflix_analytical` e execute os SQLs da pasta `sql/silver/`:

- `dim_movies.sql` — dimensão de filmes com ano extraído via REGEXP
- `fact_ratings.sql` — fato de avaliações unificando duas fontes

### 5. Camada Gold — Views Analíticas

Execute os 6 SQLs da pasta `sql/gold/` no dataset `netflix_analytical`.

### 6. Subir o Metabase com Docker

```bash
# Iniciar o container
docker run -d -p 3000:3000 --name metabase metabase/metabase

# Verificar se está rodando
docker ps

# Ver logs se necessário
docker logs metabase
```

Acesse [http://localhost:3000](http://localhost:3000) e configure:

1. Crie a conta admin (primeiro acesso)
2. Vá em **Admin → Databases → Add database → BigQuery**
3. Informe o **Project ID** e faça upload do **Service Account JSON**
4. Sincronize: **Admin → Databases → Sync database schema**

### 7. Criar os Dashboards no Metabase

Exemplos de visualizações:

- 📊 Evolução de ratings ao longo do tempo (Heatmap)
- 🏆 Ranking Top 10 filmes mais bem avaliados (Bar Chart)
- 🎬 Filmes mais avaliados (Bar Chart)
- 🎭 Popularidade dos gêneros (Bar Chart)
- 🔵 Popularidade vs Qualidade (Scatter Plot)

---

## 👤 Autor

**William Sebastião**

Projeto executado como parte do **Desafio Técnico 01** da comunidade [Dados Por Todos](https://meadow-squid-e0b.notion.site/Desafio-t-cnico-01-Case-real-com-BigQuery-e-Metabase-8f920ba56c5a829e926481d46d4156c4).

Projeto original desenvolvido por [Andreza Santos](https://github.com/AndrezaSS/netflix-pipeline-gcp).