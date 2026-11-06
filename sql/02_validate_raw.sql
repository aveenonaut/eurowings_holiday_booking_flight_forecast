-- Read-only DEV ingestion checks against the supplied, fixed case-study files.
-- Run after 01_ingest_raw.sql, including after any rerun of ingestion.
-- EXCEPT ALL checks every typed value and preserves duplicate multiplicity.
-- Known business anomalies remain raw; this checks faithful ingestion.

WITH raw_rows AS (
    SELECT
        'raw_actuals' AS table_name,
        BookingDate,
        FlightDate,
        FlightMarketCluster,
        CAST(Tix AS DECIMAL(18, 2)) AS Tix,
        Revenue
    FROM workspace.ewh_dev.raw_actuals

    UNION ALL

    SELECT
        'raw_booking_forecast', Date, CAST(NULL AS DATE),
        FlightMarketCluster, Tix, Revenue
    FROM workspace.ewh_dev.raw_booking_forecast

    UNION ALL

    SELECT
        'raw_flight_forecast', CAST(NULL AS DATE), Date,
        FlightMarketCluster, CAST(Tix AS DECIMAL(18, 2)), Revenue
    FROM workspace.ewh_dev.raw_flight_forecast
),
source_rows AS (
    SELECT
        'raw_actuals' AS table_name,
        BookingDate,
        FlightDate,
        FlightMarketCluster,
        CAST(Tix AS DECIMAL(18, 2)) AS Tix,
        Revenue
    FROM read_files(
        '/Volumes/workspace/default/ewh_source_data/EWH_DummyActuals.csv',
        format => 'csv',
        schema => 'BookingDate DATE, FlightDate DATE, FlightMarketCluster STRING, Tix BIGINT, Revenue DECIMAL(18,2)',
        header => true,
        delimiter => ';',
        encoding => 'UTF-8',
        dateFormat => 'yyyy-MM-dd',
        mode => 'FAILFAST',
        enforceSchema => false,
        schemaEvolutionMode => 'none'
    )

    UNION ALL

    SELECT
        'raw_booking_forecast', Date, CAST(NULL AS DATE),
        FlightMarketCluster, Tix, Revenue
    FROM read_files(
        '/Volumes/workspace/default/ewh_source_data/EWH_DummyBookingPeriodFc.csv',
        format => 'csv',
        schema => 'Date DATE, FlightMarketCluster STRING, Tix DECIMAL(18,2), Revenue DECIMAL(18,2)',
        header => true,
        delimiter => ';',
        encoding => 'UTF-8',
        dateFormat => 'yyyy-MM-dd',
        mode => 'FAILFAST',
        enforceSchema => false,
        schemaEvolutionMode => 'none'
    )

    UNION ALL

    SELECT
        'raw_flight_forecast', CAST(NULL AS DATE), Date,
        FlightMarketCluster, CAST(Tix AS DECIMAL(18, 2)), Revenue
    FROM read_files(
        '/Volumes/workspace/default/ewh_source_data/EWH_DummyFlightPeriodFc.csv',
        format => 'csv',
        schema => 'Date DATE, FlightMarketCluster STRING, Tix BIGINT, Revenue DECIMAL(18,2)',
        header => true,
        delimiter => ';',
        encoding => 'UTF-8',
        dateFormat => 'yyyy-MM-dd',
        mode => 'FAILFAST',
        enforceSchema => false,
        schemaEvolutionMode => 'none'
    )
),
table_only AS (
    SELECT * FROM raw_rows
    EXCEPT ALL
    SELECT * FROM source_rows
),
source_only AS (
    SELECT * FROM source_rows
    EXCEPT ALL
    SELECT * FROM raw_rows
),
differences AS (
    SELECT table_name FROM table_only
    UNION ALL
    SELECT table_name FROM source_only
),
difference_counts AS (
    SELECT table_name, COUNT(*) AS source_mismatch_rows
    FROM differences
    GROUP BY table_name
),
stats AS (
    SELECT
        table_name,
        COUNT(*) AS actual_rows,
        COUNT(*) - COUNT(DISTINCT STRUCT(
            BookingDate, FlightDate, FlightMarketCluster
        )) AS duplicate_key_rows,
        COUNT_IF(
            FlightMarketCluster IS NULL OR TRIM(FlightMarketCluster) = ''
            OR Tix IS NULL OR Revenue IS NULL
            OR (table_name != 'raw_flight_forecast' AND BookingDate IS NULL)
            OR (table_name != 'raw_booking_forecast' AND FlightDate IS NULL)
        ) AS invalid_required_rows,
        SUM(Tix) AS total_tix,
        SUM(Revenue) AS total_revenue_eur
    FROM raw_rows
    GROUP BY table_name
),
expected AS (
    SELECT * FROM VALUES
        ('raw_actuals', 20142, 45453.00, 33314149.00),
        ('raw_booking_forecast', 2452, 23012.74, 18988449.00),
        ('raw_flight_forecast', 2083, 22413.00, 18330715.00)
    AS expected(table_name, expected_rows, expected_tix, expected_revenue)
)
SELECT
    expected.table_name,
    expected.expected_rows,
    COALESCE(stats.actual_rows, 0) AS actual_rows,
    stats.total_tix,
    stats.total_revenue_eur,
    stats.duplicate_key_rows,
    stats.invalid_required_rows,
    COALESCE(difference_counts.source_mismatch_rows, 0) AS source_mismatch_rows,
    ASSERT_TRUE(
        COALESCE(stats.actual_rows, 0) = expected.expected_rows
        AND COALESCE(stats.duplicate_key_rows, -1) = 0
        AND COALESCE(stats.invalid_required_rows, -1) = 0
        AND COALESCE(stats.total_tix = expected.expected_tix, false)
        AND COALESCE(stats.total_revenue_eur = expected.expected_revenue, false)
        AND COALESCE(difference_counts.source_mismatch_rows, 0) = 0,
        CONCAT('Raw ingestion validation failed for ', expected.table_name)
    ) AS validation_assertion
FROM expected
LEFT JOIN stats USING (table_name)
LEFT JOIN difference_counts USING (table_name)
ORDER BY expected.table_name;
