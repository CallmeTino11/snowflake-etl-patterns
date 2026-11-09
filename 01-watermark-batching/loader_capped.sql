-- BEFORE: each call loads at most 1000 rows, then moves the watermark to the
-- highest timestamp loaded. Rows that share that timestamp but fall beyond the
-- cap are skipped on the next call, because the next call filters on ">".
USE SCHEMA etl_patterns.demo;

CREATE OR REPLACE PROCEDURE load_fact_invoice_capped()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  wm TIMESTAMP_NTZ;
  new_wm TIMESTAMP_NTZ;
BEGIN
  wm := (SELECT last_loaded_ts FROM etl_watermark WHERE process_name = 'fact_invoice');

  INSERT INTO fact_invoice (invoice_id, customer_code, amount, invoice_ts)
  SELECT invoice_id, customer_code, amount, invoice_ts
  FROM stg_invoice
  WHERE invoice_ts > :wm
  ORDER BY invoice_ts, invoice_id
  LIMIT 1000;

  new_wm := (SELECT MAX(invoice_ts) FROM fact_invoice);
  UPDATE etl_watermark SET last_loaded_ts = :new_wm WHERE process_name = 'fact_invoice';
  RETURN 'watermark moved to ' || :new_wm::STRING;
END;
$$;
