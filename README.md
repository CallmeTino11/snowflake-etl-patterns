# Snowflake ETL Patterns

Four short case studies on load-pattern decisions in a Snowflake data warehouse,
rebuilt from scratch on synthetic data. Each one explains the problem, the
change, the reason for it, the trade-offs and the queries used to validate it.

All data is synthetic. Nothing here comes from an employer or client.

| # | Topic | Decision |
|---|---|---|
| 01 | [Staging loader batching](01-watermark-batching) | Drain the full watermark window instead of capping rows per call |
| 02 | [Sequence vs hash keys](02-sequence-vs-hash-keys) | Deterministic hash keys instead of a sequence inside an insert-if-missing |
| 03 | [Dynamic Tables to MERGE](03-dynamic-tables-to-merge) | MERGE procedures instead of Dynamic Tables |
| 04 | [BI migration](04-bi-migration-dax-to-sql) | DAX measures translated to SQL, dashboards rebuilt in Apache Superset |

## Run it
1. Generate data: `python data/generate_synthetic_data.py data/`
2. Run `sql/00_setup.sql` in Snowflake and load the two CSV files into the staging tables.
3. Run each case folder's SQL, then its `validate.sql`.
4. Optional: `python tests/simulate_watermark_ties.py` shows the failure in case 01 without a Snowflake account.

## Status
The SQL targets Snowflake and has not been benchmarked. Case studies describe design reasoning, not measured speed-ups.
