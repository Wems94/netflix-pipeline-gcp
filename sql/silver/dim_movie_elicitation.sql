CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.dim_movie_elicitation` AS
SELECT
  SAFE_CAST(NULLIF(movieId, '') AS INT64) AS movie_id,
  SAFE_CAST(month_idx AS INT64)           AS month_idx,
  SAFE_CAST(source    AS INT64)           AS source,
  CASE SAFE_CAST(source AS INT64)
    WHEN 1 THEN 'Popularidade'
    WHEN 2 THEN 'Rating'
    WHEN 3 THEN 'Lancamentos Populares'
    WHEN 4 THEN 'Lancamentos em Alta'
    WHEN 5 THEN 'Serendipidade'
    ELSE        'Desconhecido'
  END                                     AS source_label,
  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%Ez', tstamp),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S',    tstamp)
  )                                       AS elicitation_ts
FROM `netflix-pipeline-gcp.netflix_raw.raw_movie_elicitation_set`
WHERE movieId IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY SAFE_CAST(movieId AS INT64), SAFE_CAST(month_idx AS INT64)
  ORDER BY tstamp DESC
) = 1;
