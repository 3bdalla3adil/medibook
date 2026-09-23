# Reports API Contract

Reports are read-only backend aggregations.

The client must not calculate business analytics by downloading raw records and aggregating them locally.

Every report endpoint defines organization/clinic scope, date range, filters, pagination, aggregation semantics, timezone, authorization permission and maximum query window.

Examples: appointment volume, cancellation rate, clinician utilization, invoice totals and payment status summary.

The backend remains authoritative for all report values.
