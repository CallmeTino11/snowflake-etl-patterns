-- Snowflake setup for the demo. All objects hold synthetic data only.
CREATE DATABASE IF NOT EXISTS etl_patterns;
CREATE SCHEMA IF NOT EXISTS etl_patterns.demo;
USE SCHEMA etl_patterns.demo;

CREATE OR REPLACE TABLE stg_customer (
    customer_code STRING, customer_name STRING, region STRING, loaded_at TIMESTAMP_NTZ);

CREATE OR REPLACE TABLE stg_invoice (
    invoice_id NUMBER, customer_code STRING, amount NUMBER(12,2),
    invoice_ts TIMESTAMP_NTZ, loaded_at TIMESTAMP_NTZ);

CREATE OR REPLACE TABLE fact_invoice (
    invoice_id NUMBER, customer_code STRING, amount NUMBER(12,2), invoice_ts TIMESTAMP_NTZ);

-- Hash-keyed customer dimension (case 02, 03)
CREATE OR REPLACE TABLE dim_customer (
    customer_key STRING, customer_code STRING, customer_name STRING,
    region STRING, updated_at TIMESTAMP_NTZ);

-- Sequence-keyed customer dimension (case 02, the "before" version)
CREATE OR REPLACE SEQUENCE seq_customer;
CREATE OR REPLACE TABLE dim_customer_seq (
    customer_key NUMBER, customer_code STRING, customer_name STRING, region STRING);

CREATE OR REPLACE TABLE etl_watermark (process_name STRING, last_loaded_ts TIMESTAMP_NTZ);
INSERT INTO etl_watermark VALUES ('fact_invoice', '1900-01-01'::TIMESTAMP_NTZ);

-- Load the CSVs from data/ into stg_customer and stg_invoice
-- (Snowsight: Data > Add Data > Load data into a table, or PUT + COPY INTO).
