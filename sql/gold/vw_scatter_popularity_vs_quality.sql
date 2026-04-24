CREATE OR REPLACE VIEW `netflix-pipeline-gcp.netflix_analytical.vw_scatter_popularity_vs_quality` AS
SELECT
  movie_id,
  title,
  genres,
  total_avaliacoes,
  media_rating
FROM `netflix-pipeline-gcp.netflix_analytical.vw_movies_kpis`
WHERE total_avaliacoes >= 50;