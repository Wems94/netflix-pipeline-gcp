CREATE OR REPLACE EXTERNAL TABLE `netflix-pipeline-gcp.netflix_raw.raw_ratings_for_additional_users`
(
    USERID STRING,
    MOVIEID STRING,
    RATING STRING,
    TSTAMP STRING
)
OPTIONS (
    format = 'CSV',
    uris
    = [
        'gs://netflix-pipeline-gcp-raw/bronze_movies/ratings_for_additional_users.csv'
    ],
    skip_leading_rows = 1,
    allow_quoted_newlines = TRUE,
    allow_jagged_rows = TRUE
);
