# 01. Staging loader batching

## Problem
A staging loader was capped at a fixed number of rows per call, so each call
processed only part of the available data.

## Approach
Remove the cap. Each call takes a snapshot upper bound, loads the whole window
between the watermark and that bound, and moves the watermark to the bound.

## Why it matters
With a cap, the watermark has to be set to the last row loaded. If several rows
share that timestamp and the cap cuts through them, the next call filters on
`>` and skips the remainder. `tests/simulate_watermark_ties.py` reproduces this
with SQLite and shows the missing rows. Draining the full window avoids the
problem, because every row inside the window is loaded in the same call.

## Trade-offs
- A single large call uses more warehouse time and a larger transaction.
- Late-arriving rows with an older timestamp are a separate issue. Filtering on
  a load timestamp such as `loaded_at` is safer than a business timestamp.

## Files
| File | Purpose |
|---|---|
| `loader_capped.sql` | Before: capped loader |
| `loader_full_window.sql` | After: full-window loader |
| `validate.sql` | Reconciliation checks |

## Status
Measured results: none recorded. This case documents design reasoning, not a
benchmark. The SQL is written for Snowflake and has not been run against a live account here.
