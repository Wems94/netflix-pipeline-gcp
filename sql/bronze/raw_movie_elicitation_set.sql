CREATE OR REPLACE EXTERNAL TABLE `netflix-pipeline-gcp.netflix_raw.raw_movie_elicitation_set`
(
    MOVIEID STRING,
    MONTH_IDX STRING,
    SOURCE STRING,
    TSTAMP STRING
)
OPTIONS (
    format = 'CSV',
    uris
    = ['gs://netflix-pipeline-gcp-raw/bronze_movies/movie_elicitation_set.csv'],
    skip_leading_rows = 1,
    allow_quoted_newlines = TRUE,
    allow_jagged_rows = TRUE
);
