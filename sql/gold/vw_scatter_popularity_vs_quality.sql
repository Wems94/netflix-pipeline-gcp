DROP VIEW IF EXISTS `netflix-pipeline-gcp.netflix_analytical.vw_scatter_popularity_vs_quality`;

CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.vw_scatter_popularity_vs_quality` AS
SELECT
  movie_id,
  title,
  genres,
  total_rating,
  avg_rating
FROM `netflix-pipeline-gcp.netflix_analytical.vw_movies_kpis`
WHERE total_rating >= 50;
