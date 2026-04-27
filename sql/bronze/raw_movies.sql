CREATE OR REPLACE EXTERNAL TABLE `netflix-pipeline-gcp.netflix_raw.raw_movies`
(
    MOVIEID STRING,
    TITLE STRING,
    GENRES STRING
)
OPTIONS (
    format = 'CSV',
    uris = ['gs://netflix-pipeline-gcp-raw/bronze_movies/movies.csv'],
    skip_leading_rows = 1,
    allow_quoted_newlines = TRUE,
    allow_jagged_rows = TRUE
);
