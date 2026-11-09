-- AFTER: deterministic key derived from the natural key. No sequence call, so
-- reruns and parallel loads produce the same key for the same customer.
USE SCHEMA etl_patterns.demo;

INSERT INTO dim_customer (customer_key, customer_code, customer_name, region, updated_at)
SELECT MD5(UPPER(TRIM(s.customer_code))) AS customer_key,
       s.customer_code, s.customer_name, s.region, CURRENT_TIMESTAMP()
FROM stg_customer s
WHERE NOT EXISTS (
    SELECT 1 FROM dim_customer d WHERE d.customer_code = s.customer_code
)
QUALIFY ROW_NUMBER() OVER (PARTITION BY s.customer_code ORDER BY s.loaded_at DESC) = 1;
