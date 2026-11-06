-- Read-only inputs for notebooks/01_data_analysis.ipynb.
-- Each SELECT has a stable order and retains all original records and columns.

SELECT BookingDate, FlightDate, FlightMarketCluster, Tix, Revenue
FROM workspace.ewh_dev.raw_actuals
ORDER BY BookingDate, FlightDate, FlightMarketCluster;

SELECT Date, FlightMarketCluster, Tix, Revenue
FROM workspace.ewh_dev.raw_booking_forecast
ORDER BY Date, FlightMarketCluster;

SELECT Date, FlightMarketCluster, Tix, Revenue
FROM workspace.ewh_dev.raw_flight_forecast
ORDER BY Date, FlightMarketCluster;
