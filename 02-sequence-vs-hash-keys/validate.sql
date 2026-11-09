USE SCHEMA etl_patterns.demo;
-- 1. One row per natural key (should return no rows).
SELECT customer_code, COUNT(*) FROM dim_customer GROUP BY customer_code HAVING COUNT(*) > 1;
-- 2. One key per natural key (should return no rows). Detects hash collisions.
SELECT customer_key, COUNT(DISTINCT customer_code) FROM dim_customer
GROUP BY customer_key HAVING COUNT(DISTINCT customer_code) > 1;
-- 3. Rerun safety: run the insert twice, row count must not change.
SELECT COUNT(*) FROM dim_customer;
-- 4. Keys are reproducible: this should match the stored key.
SELECT COUNT(*) AS mismatches FROM dim_customer
WHERE customer_key <> MD5(UPPER(TRIM(customer_code)));
