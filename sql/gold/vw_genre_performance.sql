CREATE OR REPLACE VIEW `netflix-pipeline-gcp.netflix_analytical.vw_genre_performance` AS
WITH exploded AS (
  SELECT 
  r.rating,
  genre

  FROM `netflix-pipeline-gcp.netflix_analytical.fact_ratings` r
  JOIN `netflix-pipeline-gcp.netflix_analytical.dim_movies` m ON m.movie_id = r.movie_id
  CROSS JOIN UNNEST (SPLIT(COALESCE(m.genres, ''), '|')) AS genre 
)
SELECT 
  genre,
  count(*) AS total_ratings,
  AVG(rating) AS avg_rating,
  STDDEV(rating) AS std_rating
  FROM exploded
WHERE genre IS NOT NULL
  AND genre != ''
  AND genre != '(no genres listed)'
GROUP BY 1;