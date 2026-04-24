CREATE OR REPLACE VIEW `netflix-pipeline-gcp.netflix_analytical.vw_movies_kpis` AS
SELECT
  r.movie_id,
  m.title,
  m.genres,
  m.release_year,
  count(*) AS total_rating,
  AVG(r.rating) AS avg_rating,
  STDDEV(r.rating) AS std_rating,
  min(r.rating_ts) AS first_rating_ts,
  max(r.rating_ts) AS last_rating_ts

FROM `netflix-pipeline-gcp.netflix_analytical.fact_ratings` r
LEFT JOIN `netflix-pipeline-gcp.netflix_analytical.dim_movies` m ON m.movie_id = r.movie_id GROUP BY 1,2,3,4;