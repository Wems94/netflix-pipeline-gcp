CREATE OR REPLACE EXTERNAL TABLE `netflix-pipeline-gcp.netflix_raw.raw_user_recommendation_history`
(
  userId          STRING,
  tstamp          STRING,
  movieId         STRING,
  predictedRating STRING
)
OPTIONS (
  format                = 'CSV',
  uris                  = ['gs://netflix-pipeline-gcp-raw/bronze_movies/user_recommendation_history.csv'],
  skip_leading_rows     = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows     = TRUE
);
