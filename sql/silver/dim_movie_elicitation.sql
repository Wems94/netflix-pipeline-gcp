CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.dim_movie_elicitation` AS
SELECT
    SAFE_CAST(NULLIF(MOVIEID, '') AS INT64) AS MOVIE_ID,
    SAFE_CAST(MONTH_IDX AS INT64) AS MONTH_IDX,
    SAFE_CAST(SOURCE AS INT64) AS SOURCE,
    CASE SAFE_CAST(SOURCE AS INT64)
        WHEN 1 THEN 'Popularidade'
        WHEN 2 THEN 'Rating'
        WHEN 3 THEN 'Lancamentos Populares'
        WHEN 4 THEN 'Lancamentos em Alta'
        WHEN 5 THEN 'Serendipidade'
        ELSE 'Desconhecido'
    END AS SOURCE_LABEL,
    COALESCE(
        SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%Ez', TSTAMP),
        SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', TSTAMP)
    ) AS ELICITATION_TS
FROM `netflix-pipeline-gcp.netflix_raw.raw_movie_elicitation_set`
WHERE MOVIEID IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY SAFE_CAST(MOVIEID AS INT64), SAFE_CAST(MONTH_IDX AS INT64)
    ORDER BY TSTAMP DESC
) = 1;
