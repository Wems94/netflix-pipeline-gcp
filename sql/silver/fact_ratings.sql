DROP TABLE IF EXISTS `netflix-pipeline-gcp.netflix_analytical.fact_ratings`;

CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.fact_ratings`
PARTITION BY DATE(rating_ts)
CLUSTER BY movie_id, user_id
AS
WITH all_ratings AS (
  SELECT
    SAFE_CAST(NULLIF(userId, '') AS INT64)                 AS user_id,
    SAFE_CAST(NULLIF(movieId, '') AS INT64)                AS movie_id,
    SAFE_CAST(NULLIF(NULLIF(rating, 'NA'), '') AS FLOAT64) AS rating,
    COALESCE(
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%Ez', tstamp),
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S',    tstamp)
    )                                                      AS rating_ts,
    'user_rating_history'                                  AS src
  FROM `netflix-pipeline-gcp.netflix_raw.raw_user_rating_history`

  UNION ALL

  SELECT
    SAFE_CAST(NULLIF(userId, '') AS INT64)                 AS user_id,
    SAFE_CAST(NULLIF(movieId, '') AS INT64)                AS movie_id,
    SAFE_CAST(NULLIF(NULLIF(rating, 'NA'), '') AS FLOAT64) AS rating,
    COALESCE(
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%Ez', tstamp),
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S',    tstamp)
    )                                                      AS rating_ts,
    'rating_for_additional_users'                          AS src
  FROM `netflix-pipeline-gcp.netflix_raw.raw_ratings_for_additional_users`
),
deduped AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY user_id, movie_id, rating_ts
      ORDER BY src
    ) AS rn
  FROM all_ratings
  WHERE user_id   IS NOT NULL
    AND movie_id  IS NOT NULL
    AND rating    IS NOT NULL
    AND rating_ts IS NOT NULL
)
SELECT
  TO_HEX(MD5(CONCAT(
    CAST(user_id   AS STRING), '-',
    CAST(movie_id  AS STRING), '-',
    CAST(rating_ts AS STRING)
  ))) AS rating_id,
  user_id,
  movie_id,
  rating,
  rating_ts,
  src
FROM deduped
WHERE rn = 1;
