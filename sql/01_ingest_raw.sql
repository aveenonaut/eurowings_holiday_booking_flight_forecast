-- DEV only. Run every statement in order on a Databricks SQL warehouse.
-- Source files stay unchanged in the shared managed volume.
-- No DROP, TRUNCATE, overwrite, forced reload or automatic schema evolution.

CREATE SCHEMA IF NOT EXISTS workspace.ewh_dev
COMMENT 'Development tables for the Eurowings Holidays forecasting case study';

CREATE TABLE IF NOT EXISTS workspace.ewh_dev.raw_actuals (
    BookingDate DATE NOT NULL,
    FlightDate DATE NOT NULL,
    FlightMarketCluster STRING NOT NULL,
    Tix BIGINT NOT NULL,
    Revenue DECIMAL(18, 2) NOT NULL
)
USING DELTA
COMMENT 'Uncleaned historical observations from EWH_DummyActuals.csv';

CREATE TABLE IF NOT EXISTS workspace.ewh_dev.raw_booking_forecast (
    Date DATE NOT NULL,
    FlightMarketCluster STRING NOT NULL,
    Tix DECIMAL(18, 2) NOT NULL,
    Revenue DECIMAL(18, 2) NOT NULL
)
USING DELTA
COMMENT 'Uncleaned booking-date forecast from EWH_DummyBookingPeriodFc.csv';

CREATE TABLE IF NOT EXISTS workspace.ewh_dev.raw_flight_forecast (
    Date DATE NOT NULL,
    FlightMarketCluster STRING NOT NULL,
    Tix BIGINT NOT NULL,
    Revenue DECIMAL(18, 2) NOT NULL
)
USING DELTA
COMMENT 'Uncleaned flight-date forecast from EWH_DummyFlightPeriodFc.csv';

-- Parse source fields as strings, then explicitly cast to the target types.
-- Fractional booking forecast Tix are retained exactly to two decimal places.
-- Bad input fails rather than being dropped or replaced with nulls.

COPY INTO workspace.ewh_dev.raw_actuals
FROM (
    SELECT
        CAST(BookingDate AS DATE) AS BookingDate,
        CAST(FlightDate AS DATE) AS FlightDate,
        FlightMarketCluster,
        CAST(Tix AS BIGINT) AS Tix,
        CAST(Revenue AS DECIMAL(18, 2)) AS Revenue
    FROM '/Volumes/workspace/default/ewh_source_data/EWH_DummyActuals.csv'
)
FILEFORMAT = CSV
FORMAT_OPTIONS (
    'header' = 'true',
    'delimiter' = ';',
    'inferSchema' = 'false',
    'encoding' = 'UTF-8',
    'dateFormat' = 'yyyy-MM-dd',
    'mode' = 'FAILFAST'
)
COPY_OPTIONS ('force' = 'false', 'mergeSchema' = 'false');

COPY INTO workspace.ewh_dev.raw_booking_forecast
FROM (
    SELECT
        CAST(Date AS DATE) AS Date,
        FlightMarketCluster,
        CAST(Tix AS DECIMAL(18, 2)) AS Tix,
        CAST(Revenue AS DECIMAL(18, 2)) AS Revenue
    FROM '/Volumes/workspace/default/ewh_source_data/EWH_DummyBookingPeriodFc.csv'
)
FILEFORMAT = CSV
FORMAT_OPTIONS (
    'header' = 'true',
    'delimiter' = ';',
    'inferSchema' = 'false',
    'encoding' = 'UTF-8',
    'dateFormat' = 'yyyy-MM-dd',
    'mode' = 'FAILFAST'
)
COPY_OPTIONS ('force' = 'false', 'mergeSchema' = 'false');

COPY INTO workspace.ewh_dev.raw_flight_forecast
FROM (
    SELECT
        CAST(Date AS DATE) AS Date,
        FlightMarketCluster,
        CAST(Tix AS BIGINT) AS Tix,
        CAST(Revenue AS DECIMAL(18, 2)) AS Revenue
    FROM '/Volumes/workspace/default/ewh_source_data/EWH_DummyFlightPeriodFc.csv'
)
FILEFORMAT = CSV
FORMAT_OPTIONS (
    'header' = 'true',
    'delimiter' = ';',
    'inferSchema' = 'false',
    'encoding' = 'UTF-8',
    'dateFormat' = 'yyyy-MM-dd',
    'mode' = 'FAILFAST'
)
COPY_OPTIONS ('force' = 'false', 'mergeSchema' = 'false');
