CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.fact_belief_data` AS
SELECT
  SAFE_CAST(NULLIF(userId,  '') AS INT64)   AS user_id,
  SAFE_CAST(NULLIF(movieId, '') AS INT64)   AS movie_id,
  SAFE_CAST(isSeen AS INT64)                AS is_seen,
  SAFE.PARSE_DATE('%Y-%m-%d', watchDate)    AS watch_date,
  SAFE_CAST(userElicitRating  AS FLOAT64)   AS user_elicit_rating,
  SAFE_CAST(userPredictRating AS FLOAT64)   AS user_predict_rating,
  SAFE_CAST(userCertainty     AS FLOAT64)   AS user_certainty,
  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%Ez', tstamp),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S',    tstamp)
  )                                         AS belief_ts,
  SAFE_CAST(month_idx AS INT64)             AS month_idx,
  SAFE_CAST(source    AS INT64)             AS source,
  SAFE_CAST(systemPredictRating AS FLOAT64) AS system_predict_rating
FROM `netflix-pipeline-gcp.netflix_raw.raw_belief_data`
WHERE userId  IS NOT NULL
  AND movieId IS NOT NULL;
