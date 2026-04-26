CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.dim_movies` AS
SELECT
  SAFE_CAST(movieId AS INT64)                                    AS movie_id,
  title,
  genres,
  SAFE_CAST(REGEXP_EXTRACT(title, r'\((\d{4})\)\s*$') AS INT64) AS release_year
FROM `netflix-pipeline-gcp.netflix_raw.raw_movies`
WHERE movieId IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY SAFE_CAST(movieId AS INT64) ORDER BY title) = 1;
