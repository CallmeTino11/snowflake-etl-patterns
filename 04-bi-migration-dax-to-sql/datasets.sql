-- Virtual datasets for Superset (SQL Lab > Save as dataset). Synthetic data only.

-- Monthly sales with previous-year comparison
SELECT DATE_TRUNC('month', invoice_ts) AS month,
       SUM(amount) AS total_sales,
       LAG(SUM(amount), 12) OVER (ORDER BY DATE_TRUNC('month', invoice_ts)) AS sales_prev_year
FROM etl_patterns.demo.fact_invoice
GROUP BY 1;

-- Sales share by region
SELECT c.region,
       SUM(i.amount) AS total_sales,
       RATIO_TO_REPORT(SUM(i.amount)) OVER () AS share_of_total
FROM etl_patterns.demo.fact_invoice i
JOIN etl_patterns.demo.dim_customer c ON c.customer_code = i.customer_code
GROUP BY c.region;

-- Ageing buckets by days since invoice
SELECT CASE WHEN DATEDIFF('day', invoice_ts, CURRENT_DATE) <= 30 THEN '0-30'
            WHEN DATEDIFF('day', invoice_ts, CURRENT_DATE) <= 60 THEN '31-60'
            ELSE '61+' END AS age_bucket,
       COUNT(*) AS invoices, SUM(amount) AS total_amount
FROM etl_patterns.demo.fact_invoice
GROUP BY 1;
