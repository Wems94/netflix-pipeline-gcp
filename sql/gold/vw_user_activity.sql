CREATE OR REPLACE VIEW `project-12268d68-4dba-41b8-846.netflix_analytical.vw_user_activity` AS
SELECT
  user_id,
  COUNT(*) AS total_rating,
  COUNT(DISTINCT movie_id) AS distinct_movies_rated,
  AVG(rating) AS avg_rating,
  STDDEV(rating) AS std_rating,
  MIN(rating_ts) AS fist_activity_ts,
  MAX(rating_ts) AS last_activity_ts
FROM `project-12268d68-4dba-41b8-846.netflix_analytical.fact_ratings`
GROUP BY 1
ORDER BY total_rating DESC, avg_rating DESC;