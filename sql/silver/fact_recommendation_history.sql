CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.fact_recommendation_history` AS
SELECT
  SAFE_CAST(NULLIF(userId,  '') AS INT64) AS user_id,
  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%Ez', tstamp),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S',    tstamp)
  )                                       AS recommendation_ts,
  SAFE_CAST(NULLIF(movieId, '') AS INT64) AS movie_id,
  SAFE_CAST(predictedRating AS FLOAT64)   AS predicted_rating
FROM `netflix-pipeline-gcp.netflix_raw.raw_user_recommendation_history`
WHERE userId  IS NOT NULL
  AND movieId IS NOT NULL;
