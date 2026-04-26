DROP VIEW IF EXISTS `netflix-pipeline-gcp.netflix_analytical.vw_ratings_heatmap`;

CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.vw_ratings_heatmap` AS
SELECT
  EXTRACT(YEAR FROM rating_ts)      AS year,
  EXTRACT(MONTH FROM rating_ts)     AS month_number,
  FORMAT_TIMESTAMP('%b', rating_ts) AS month_name,
  COUNT(*)                          AS total_ratings
FROM `netflix-pipeline-gcp.netflix_analytical.fact_ratings`
GROUP BY year, month_number, month_name;
