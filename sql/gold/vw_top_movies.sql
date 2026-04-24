CREATE OR REPLACE VIEW `project-12268d68-4dba-41b8-846.netflix_analytical.vw_movies_kpis` AS
SELECT
  dm.movie_id,
  dm.title,
  dm.genres,
  COUNT(*)       AS total_avaliacoes,
  AVG(fr.rating) AS media_rating
FROM `project-12268d68-4dba-41b8-846.netflix_analytical.dim_movies` AS dm
LEFT JOIN `project-12268d68-4dba-41b8-846.netflix_analytical.fact_ratings` AS fr
  ON SAFE_CAST(dm.movie_id AS INT64) = fr.movie_id
GROUP BY dm.movie_id, dm.title, dm.genres;