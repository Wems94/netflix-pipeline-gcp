CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.vw_recommendation_accuracy` AS
SELECT
  r.movie_id,
  m.title,
  m.genres,
  COUNT(*)                                          AS total_predictions,
  AVG(ABS(r.predicted_rating - f.rating))           AS mae,
  SQRT(AVG(POW(r.predicted_rating - f.rating, 2))) AS rmse,
  AVG(r.predicted_rating)                           AS avg_predicted,
  AVG(f.rating)                                     AS avg_actual
FROM `netflix-pipeline-gcp.netflix_analytical.fact_recommendation_history` r
JOIN `netflix-pipeline-gcp.netflix_analytical.fact_ratings` f
  ON r.user_id = f.user_id AND r.movie_id = f.movie_id
JOIN `netflix-pipeline-gcp.netflix_analytical.dim_movies` m
  ON r.movie_id = m.movie_id
GROUP BY r.movie_id, m.title, m.genres;
