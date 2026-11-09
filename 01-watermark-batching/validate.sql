USE SCHEMA etl_patterns.demo;
-- 1. Row counts must match once the loader has drained the window.
SELECT (SELECT COUNT(*) FROM stg_invoice)  AS staged_rows,
       (SELECT COUNT(*) FROM fact_invoice) AS loaded_rows;

-- 2. Staged rows that never reached the fact table (should return no rows).
SELECT s.invoice_id
FROM stg_invoice s
LEFT JOIN fact_invoice f ON f.invoice_id = s.invoice_id
WHERE f.invoice_id IS NULL;

-- 3. No duplicates were loaded (should return no rows).
SELECT invoice_id, COUNT(*) FROM fact_invoice GROUP BY invoice_id HAVING COUNT(*) > 1;
