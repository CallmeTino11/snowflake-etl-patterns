-- AFTER: no row cap. Each call takes a snapshot upper bound, loads everything
-- between the watermark and that bound, then moves the watermark to the bound.
USE SCHEMA etl_patterns.demo;

CREATE OR REPLACE PROCEDURE load_fact_invoice_full_window()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  wm TIMESTAMP_NTZ;
  upper_bound TIMESTAMP_NTZ;
BEGIN
  wm := (SELECT last_loaded_ts FROM etl_watermark WHERE process_name = 'fact_invoice');
  upper_bound := (SELECT MAX(invoice_ts) FROM stg_invoice);

  IF (upper_bound IS NULL OR upper_bound <= wm) THEN
    RETURN 'nothing to load';
  END IF;

  INSERT INTO fact_invoice (invoice_id, customer_code, amount, invoice_ts)
  SELECT invoice_id, customer_code, amount, invoice_ts
  FROM stg_invoice
  WHERE invoice_ts > :wm AND invoice_ts <= :upper_bound;

  UPDATE etl_watermark SET last_loaded_ts = :upper_bound WHERE process_name = 'fact_invoice';
  RETURN 'watermark moved to ' || :upper_bound::STRING;
END;
$$;
