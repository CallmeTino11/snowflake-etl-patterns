-- AFTER: a plain table loaded by a MERGE procedure. Works with
-- truncate-and-reload staging and gives explicit control over when it runs.
USE SCHEMA etl_patterns.demo;

CREATE OR REPLACE TABLE customer_balance (
    customer_code STRING, invoice_count NUMBER, total_amount NUMBER(18,2), updated_at TIMESTAMP_NTZ);

CREATE OR REPLACE PROCEDURE load_customer_balance()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  MERGE INTO customer_balance t
  USING (
      SELECT c.customer_code,
             COUNT(i.invoice_id) AS invoice_count,
             COALESCE(SUM(i.amount), 0) AS total_amount
      FROM dim_customer c
      LEFT JOIN fact_invoice i ON c.customer_code = i.customer_code
      GROUP BY c.customer_code
  ) s
  ON t.customer_code = s.customer_code
  WHEN MATCHED AND (NOT EQUAL_NULL(t.invoice_count, s.invoice_count)
                 OR NOT EQUAL_NULL(t.total_amount, s.total_amount)) THEN
    UPDATE SET invoice_count = s.invoice_count, total_amount = s.total_amount,
               updated_at = CURRENT_TIMESTAMP()
  WHEN NOT MATCHED THEN
    INSERT (customer_code, invoice_count, total_amount, updated_at)
    VALUES (s.customer_code, s.invoice_count, s.total_amount, CURRENT_TIMESTAMP());
  RETURN 'merge complete';
END;
$$;
