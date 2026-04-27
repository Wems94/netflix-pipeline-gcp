CREATE OR REPLACE EXTERNAL TABLE `netflix-pipeline-gcp.netflix_raw.raw_belief_data`
(
    USERID STRING,
    MOVIEID STRING,
    ISSEEN STRING,
    WATCHDATE STRING,
    USERELICITRATING STRING,
    USERPREDICTRATING STRING,
    USERCERTAINTY STRING,
    TSTAMP STRING,
    MONTH_IDX STRING,
    SOURCE STRING,
    SYSTEMPREDICTRATING STRING
)
OPTIONS (
    format = 'CSV',
    uris = ['gs://netflix-pipeline-gcp-raw/bronze_movies/belief_data.csv'],
    skip_leading_rows = 1,
    allow_quoted_newlines = TRUE,
    allow_jagged_rows = TRUE
);
