CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.vw_top_movies` AS
SELECT
  dm.movie_id,
  dm.title,
  dm.genres,
  COUNT(*)       AS total_rating,
  AVG(fr.rating) AS avg_rating
FROM `netflix-pipeline-gcp.netflix_analytical.dim_movies` AS dm
LEFT JOIN `netflix-pipeline-gcp.netflix_analytical.fact_ratings` AS fr
  ON dm.movie_id = fr.movie_id
GROUP BY dm.movie_id, dm.title, dm.genres;
