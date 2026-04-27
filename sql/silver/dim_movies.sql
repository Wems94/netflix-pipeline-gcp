CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.dim_movies` AS
SELECT
    SAFE_CAST(MOVIEID AS INT64) AS MOVIE_ID,
    TITLE,
    GENRES,
    SAFE_CAST(REGEXP_EXTRACT(TITLE, r'\((\d{4})\)\s*$') AS INT64)
        AS RELEASE_YEAR
FROM `netflix-pipeline-gcp.netflix_raw.raw_movies`
WHERE MOVIEID IS NOT NULL
QUALIFY
    ROW_NUMBER() OVER (
        PARTITION BY SAFE_CAST(MOVIEID AS INT64)
        ORDER BY TITLE
    ) = 1;
