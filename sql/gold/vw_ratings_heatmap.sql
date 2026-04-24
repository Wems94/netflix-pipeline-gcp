CREATE OR REPLACE VIEW `project-12268d68-4dba-41b8-846.netflix_analytical.vw_ratings_heatmap` AS
SELECT
  EXTRACT(YEAR FROM rating_ts) AS year,
  EXTRACT(MONTH FROM rating_ts) AS month_number,
  FORMAT_TIMESTAMP('%b', rating_ts) AS month_name,
  COUNT(*) AS total_ratings
FROM `project-12268d68-4dba-41b8-846.netflix_analytical.fact_ratings`
GROUP BY year, month_number, month_name
ORDER BY year, month_number;