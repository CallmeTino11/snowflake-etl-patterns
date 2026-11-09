-- BEFORE: sequence call and NOT EXISTS filter in the same SELECT.
-- Sequence values can be consumed for rows the filter later discards, so keys
-- have gaps, and the key for a customer depends on load order and rerun history.
USE SCHEMA etl_patterns.demo;

INSERT INTO dim_customer_seq (customer_key, customer_code, customer_name, region)
SELECT seq_customer.NEXTVAL, s.customer_code, s.customer_name, s.region
FROM stg_customer s
WHERE NOT EXISTS (
    SELECT 1 FROM dim_customer_seq d WHERE d.customer_code = s.customer_code
);
