# DAX measures translated to Snowflake SQL

Examples use the synthetic `fact_invoice` and `dim_customer` tables. Each SQL
block can be saved as a Superset virtual dataset (see `datasets.sql`).

| DAX measure | Snowflake SQL | Note |
|---|---|---|
| `Total Sales = SUM(Invoice[amount])` | `SUM(amount)` | Superset metric |
| `Customers = DISTINCTCOUNT(Invoice[customer_code])` | `COUNT(DISTINCT customer_code)` | |
| `Sales YTD = TOTALYTD([Total Sales], 'Date'[Date])` | `SUM(daily_total) OVER (PARTITION BY YEAR(day) ORDER BY day)` | aggregate by day first, then window |
| `Sales PY = CALCULATE([Total Sales], SAMEPERIODLASTYEAR('Date'[Date]))` | `LAG(month_total, 12) OVER (ORDER BY month)` | needs a gap-free month series |
| `% of Total = DIVIDE([Total Sales], CALCULATE([Total Sales], ALL(Region)))` | `RATIO_TO_REPORT(SUM(amount)) OVER ()` | |
| `Age Bucket = SWITCH(TRUE(), days <= 30, "0-30", days <= 60, "31-60", "61+")` | `CASE WHEN days <= 30 THEN '0-30' WHEN days <= 60 THEN '31-60' ELSE '61+' END` | |

## Things that do not translate one to one
- **Filter context.** DAX measures re-evaluate for every visual. In SQL the grain is fixed by the query, so each grain needs its own dataset or a metric defined in Superset.
- **Date tables and time intelligence.** Build a calendar table so month and year comparisons have no gaps.
- **Row-level security.** Power BI roles do not carry over. Use Superset roles and row-level security filters.
- **Visuals.** Each Power BI visual needs a Superset chart rebuilt by hand.
