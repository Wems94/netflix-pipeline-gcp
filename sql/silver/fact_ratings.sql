CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.fact_ratings` AS
WITH all_ratings AS (
  SELECT 
    SAFE_CAST(NULLIF(userId, '') AS INT64) AS user_Id,
    SAFE_CAST(NULLIF(movieId, '') AS INT64) AS movie_Id,


    -- remove NA/ null
    SAFE_CAST(NULLIF(NULLIF(rating, 'NA'),'')AS FLOAT64) AS rating,

    --aceita timestamp com ou sem timezone
    COALESCE(
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%Ez', tstamp),
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', tstamp)

    ) AS rating_ts,

    'user_rating_history' AS src

  from  `netflix-pipeline-gcp.netflix_raw.raw_user_rating_history`

  UNION ALL

  select 
    SAFE_CAST(NULLIF(userId,'') AS INT64) AS user_Id,
    SAFE_CAST(NULLIF(movieId,'') AS INT64) AS movie_Id,

    SAFE_CAST(NULLIF(NULLIF(rating, 'NA'),'')AS FLOAT64) AS rating,

    COALESCE(
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%Ez', tstamp),
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', tstamp)

    ) AS rating_ts,

    'rating_for_additional_users' AS src

  FROM `netflix-pipeline-gcp.netflix_raw.raw_ratings_for_additional_users`

)

SELECT
  user_Id,
  movie_Id,
  rating,
  rating_ts,
  src 
FROM all_ratings
WHERE user_Id IS NOT NULL
  AND movie_Id IS NOT NULL
  AND rating IS NOT NULL
  AND rating_ts IS NOT NULL;