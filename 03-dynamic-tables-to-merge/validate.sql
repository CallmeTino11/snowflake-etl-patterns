USE SCHEMA etl_patterns.demo;
-- 1. Totals reconcile to the fact table (should return no rows).
SELECT b.customer_code, b.total_amount, f.total
FROM customer_balance b
JOIN (SELECT customer_code, SUM(amount) AS total FROM fact_invoice GROUP BY customer_code) f
  ON f.customer_code = b.customer_code
WHERE b.total_amount <> f.total;
-- 2. One row per customer (should return no rows).
SELECT customer_code, COUNT(*) FROM customer_balance GROUP BY customer_code HAVING COUNT(*) > 1;
-- 3. Idempotent: CALL load_customer_balance() twice and confirm updated_at only changes when values change.
