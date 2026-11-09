-- BEFORE: a Dynamic Table with a null-safe join. Set REFRESH_MODE explicitly so
-- the statement fails at creation if the query cannot refresh incrementally,
-- instead of silently falling back to full refreshes.
-- Replace <warehouse> with a warehouse you own.
USE SCHEMA etl_patterns.demo;

CREATE OR REPLACE DYNAMIC TABLE dt_customer_balance
  TARGET_LAG = '1 hour'
  WAREHOUSE = <warehouse>
  REFRESH_MODE = INCREMENTAL
AS
SELECT c.customer_code,
       COUNT(i.invoice_id) AS invoice_count,
       COALESCE(SUM(i.amount), 0) AS total_amount
FROM dim_customer c
LEFT JOIN fact_invoice i ON c.customer_code IS NOT DISTINCT FROM i.customer_code
GROUP BY c.customer_code;

-- Check what the table actually got:
-- SHOW DYNAMIC TABLES LIKE 'dt_customer_balance';  (see refresh_mode)
