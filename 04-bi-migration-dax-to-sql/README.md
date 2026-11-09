# 04. BI migration to an open-source tool over Snowflake

## Problem
High recurring BI licence cost.

## Approach
A proof of concept: rebuild a set of dashboards in Apache Superset on top of
Snowflake, using synthetic data, translating DAX measures into SQL.

## Contents
| File | Purpose |
|---|---|
| `dax_to_sql.md` | DAX measures and their Snowflake SQL equivalents, plus what does not translate |
| `datasets.sql` | Example Superset virtual datasets |
| `superset/` | Dockerfile and Compose file to run Superset with the Snowflake driver |

## Run it
```bash
cd superset
docker compose up --build        # Superset at http://localhost:8088 (admin / admin, demo only)
```
In Superset add a database with the URI
`snowflake://<user>:<password>@<account>/etl_patterns/demo?warehouse=<wh>&role=<role>`.
Never commit credentials; keep them in a local `.env` file, which `.gitignore` excludes.

## Status
This is a proof of concept on synthetic data. The cost goal is the motivation;
no measured saving is recorded. The Compose file has not been run in the environment where this was written.
