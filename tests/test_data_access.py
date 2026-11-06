"""Guard against partial SQL extracts and loss of exact monetary values."""

import unittest
from decimal import Decimal
from unittest.mock import patch

from ewh_forecast.data_access import query_dataframe


def response(*, total=2, truncated=False):
    return {
        "statement_id": "test-statement",
        "status": {"state": "SUCCEEDED"},
        "manifest": {
            "total_row_count": total,
            "truncated": truncated,
            "schema": {
                "columns": [
                    {"name": "Date", "type_name": "DATE"},
                    {"name": "Revenue", "type_name": "DECIMAL"},
                ]
            },
        },
        "result": {
            "data_array": [["2025-01-01", "0.10"]],
            "next_chunk_internal_link": "/api/2.0/sql/statements/test-statement/result/chunks/1",
        },
    }


class SqlResultTests(unittest.TestCase):
    @patch.dict("os.environ", {"DATABRICKS_CLI": "test-cli"})
    @patch("ewh_forecast.data_access._api")
    def test_all_chunks_are_read_and_decimal_totals_stay_exact(self, request):
        request.side_effect = [
            response(),
            {"data_array": [["2025-01-02", "0.20"]]},
        ]
        frame = query_dataframe(
            "SELECT Date, Revenue FROM example", warehouse_id="test"
        )
        self.assertEqual(len(frame), 2)
        self.assertEqual(sum(frame.Revenue), Decimal("0.30"))
        self.assertEqual(frame.Date.dt.day.tolist(), [1, 2])
        self.assertEqual(frame.attrs["statement_id"], "test-statement")

    @patch.dict("os.environ", {"DATABRICKS_CLI": "test-cli"})
    @patch("ewh_forecast.data_access._api")
    def test_truncated_results_cannot_be_used_as_complete_data(self, request):
        request.return_value = response(truncated=True)
        with self.assertRaisesRegex(RuntimeError, "truncated"):
            query_dataframe("SELECT 1", warehouse_id="test")

    @patch.dict("os.environ", {"DATABRICKS_CLI": "test-cli"})
    @patch("ewh_forecast.data_access._api")
    def test_missing_rows_cannot_silently_change_analysis_population(self, request):
        request.side_effect = [response(total=3), {"data_array": []}]
        with self.assertRaisesRegex(RuntimeError, "row count"):
            query_dataframe("SELECT 1", warehouse_id="test")

    @patch.dict("os.environ", {"DATABRICKS_CLI": "test-cli"})
    @patch("ewh_forecast.data_access._api")
    def test_sql_error_is_not_interpreted_as_empty_dataset(self, request):
        request.return_value = {
            "statement_id": "test-statement",
            "status": {"state": "FAILED", "error": {"message": "Missing table"}},
        }
        with self.assertRaisesRegex(RuntimeError, "SQL failed"):
            query_dataframe("SELECT 1", warehouse_id="test")


if __name__ == "__main__":
    unittest.main()
