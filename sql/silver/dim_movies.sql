CREATE OR REPLACE TABLE `project-12268d68-4dba-41b8-846.netflix_analytical.dim_movies` AS
SELECT
  SAFE_CAST(movieId AS INT64) as movie_id,
  CAST(title AS STRING) as title,
  CAST(genres AS STRING) as genres,
  SAFE_CAST(REGEXP_EXTRACT(CAST (title as STRING), r'\((\d{4})\)\s*$') as INT64) as release_year
  from `project-12268d68-4dba-41b8-846.netflix_raw.raw_movies`;