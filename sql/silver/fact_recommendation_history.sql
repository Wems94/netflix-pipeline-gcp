CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.fact_recommendation_history` AS
SELECT
    SAFE_CAST(NULLIF(USERID, '') AS INT64) AS USER_ID,
    COALESCE(
        SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S%Ez', TSTAMP),
        SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', TSTAMP)
    ) AS RECOMMENDATION_TS,
    SAFE_CAST(NULLIF(MOVIEID, '') AS INT64) AS MOVIE_ID,
    SAFE_CAST(PREDICTEDRATING AS FLOAT64) AS PREDICTED_RATING
FROM `netflix-pipeline-gcp.netflix_raw.raw_user_recommendation_history`
WHERE
    USERID IS NOT NULL
    AND MOVIEID IS NOT NULL;
