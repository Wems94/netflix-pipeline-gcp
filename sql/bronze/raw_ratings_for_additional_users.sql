CREATE OR REPLACE EXTERNAL TABLE `netflix-pipeline-gcp.netflix_raw.raw_ratings_for_additional_users`
(
  movieId STRING,
  title   STRING,
  genres  STRING
)
OPTIONS (
  format = 'CSV',
  uris   = ['gs://raw_movies_netflix/bronze_movies/ratings_for_additional_users.csv'],
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE
);