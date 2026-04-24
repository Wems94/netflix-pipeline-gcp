CREATE OR REPLACE EXTERNAL TABLE `project-12268d68-4dba-41b8-846.netflix_raw.raw_movies`
(
  movieId STRING,
  title   STRING,
  genres  STRING
)
OPTIONS (
  format = 'CSV',
  uris   = ['gs://raw_movies_netflix/bronze_movies/movies.csv'],
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE
);
