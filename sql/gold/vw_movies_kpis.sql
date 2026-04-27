CREATE OR REPLACE TABLE `netflix-pipeline-gcp.netflix_analytical.vw_movies_kpis` AS
SELECT
    r.movie_id,
    m.title,
    m.genres,
    m.release_year,
    COUNT(*) AS total_rating,
    AVG(r.rating) AS avg_rating,
    STDDEV(r.rating) AS std_rating,
    MIN(r.rating_ts) AS first_rating_ts,
    MAX(r.rating_ts) AS last_rating_ts
FROM `netflix-pipeline-gcp.netflix_analytical.fact_ratings` AS r
LEFT JOIN `netflix-pipeline-gcp.netflix_analytical.dim_movies` AS m
    ON r.movie_id = m.movie_id
GROUP BY 1, 2, 3, 4;
