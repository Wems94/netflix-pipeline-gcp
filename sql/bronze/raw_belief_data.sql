CREATE OR REPLACE EXTERNAL TABLE `netflix-pipeline-gcp.netflix_raw.raw_belief_data`
(
  userId              STRING,
  movieId             STRING,
  isSeen              STRING,
  watchDate           STRING,
  userElicitRating    STRING,
  userPredictRating   STRING,
  userCertainty       STRING,
  tstamp              STRING,
  month_idx           STRING,
  source              STRING,
  systemPredictRating STRING
)
OPTIONS (
  format                = 'CSV',
  uris                  = ['gs://netflix-pipeline-gcp-raw/bronze_movies/belief_data.csv'],
  skip_leading_rows     = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows     = TRUE
);
