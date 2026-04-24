CREATE OR REPLACE VIEW `project-12268d68-4dba-41b8-846.netflix_analytical.vw_scatter_popularity_vs_quality` AS
SELECT
  movie_id,
  title,
  genres,
  total_avaliacoes,
  media_rating
FROM `project-12268d68-4dba-41b8-846.netflix_analytical.vw_movies_kpis`
WHERE total_avaliacoes >= 50;