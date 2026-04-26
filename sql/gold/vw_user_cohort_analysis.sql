CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.vw_user_cohort_analysis` AS
WITH first_rating AS (
  SELECT
    user_id,
    DATE_TRUNC(DATE(MIN(rating_ts)), MONTH) AS cohort_month
  FROM `netflix-pipeline-gcp.netflix_analytical.fact_ratings`
  GROUP BY user_id
),
activity AS (
  SELECT
    f.user_id,
    fr.cohort_month,
    DATE_TRUNC(DATE(f.rating_ts), MONTH)    AS activity_month,
    DATE_DIFF(
      DATE_TRUNC(DATE(f.rating_ts), MONTH),
      fr.cohort_month,
      MONTH
    )                                       AS months_since_cohort,
    COUNT(*)                                AS ratings_in_month
  FROM `netflix-pipeline-gcp.netflix_analytical.fact_ratings` f
  JOIN first_rating fr ON f.user_id = fr.user_id
  GROUP BY f.user_id, fr.cohort_month, activity_month, months_since_cohort
)
SELECT
  cohort_month,
  months_since_cohort,
  COUNT(DISTINCT user_id) AS active_users,
  SUM(ratings_in_month)   AS total_ratings
FROM activity
GROUP BY cohort_month, months_since_cohort;
