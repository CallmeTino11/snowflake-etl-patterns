# 02. Sequence overhead in insert-if-missing loads

## Problem
A sequence call sat in the same `SELECT` as a `NOT EXISTS` filter. Sequence
values can be consumed for rows that the filter then discards, so every
evaluated row can burn a value.

## Approach
Separate the two concerns and move to hash-based surrogate keys built from the
natural key (`MD5(UPPER(TRIM(customer_code)))`). The key no longer depends on a
sequence, so the same customer always gets the same key.

## Why
The main reason is key stability: a deterministic key is the same across
reruns, environments and parallel loads, which avoids key collisions and
mismatches between tables. Speed was not the driver and is not claimed.

## Trade-offs
- Hash keys are wider than integers, which costs storage and join width.
- The natural key must be cleaned (case, whitespace) before hashing, and a
  natural-key change creates a new key.
- Collisions are extremely unlikely with MD5 on short business keys, but
  `validate.sql` checks for them anyway.

## Status
Measured results: none recorded. Design reasoning only. Not run against a live Snowflake account here.
