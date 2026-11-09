# 03. Dynamic Tables to MERGE procedures

## Problem
Two things clashed with Dynamic Tables:
1. A null-safe join pattern (`IS NOT DISTINCT FROM`) prevented incremental refresh.
2. Truncate-and-reload staging did not fit with a Dynamic Table sitting on top of it.

## Approach
Replace the Dynamic Tables with MERGE-based loading procedures that are called
by the pipeline after staging completes. `NOT EQUAL_NULL` keeps the null-safe
comparison, but only for deciding whether a row changed.

## Why
Compatibility and control, not speed. Check `SHOW DYNAMIC TABLES` (column
`refresh_mode`) to see whether a Dynamic Table is refreshing incrementally, and
read Snowflake's current documentation for which query constructs are supported.

## Trade-offs
- You now own the scheduling and ordering of loads. Dynamic Tables did this for you.
- MERGE needs a unique join key in the source, or it can fail or duplicate rows.

## Status
Measured results: none recorded. Design reasoning only. Not run against a live Snowflake account here.
