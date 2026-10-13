# Section B chart data

Status: awaiting Oracle export.

Do not add manually typed or estimated sales figures to this directory. After
Q5 is verified, run `oracle_section_b_chart_extract.sql` with F5 to create:

- `q6_q1_promo_sales.csv`
- `q6_full_period_promo_sales.csv`
- `q7_monthly_product_category_sales.csv`

Then run `artifacts/section_b/build_charts.py`. The chart script validates the
expected headers and grain, rejects empty inputs, and records input hashes, row
counts, fields and period coverage in `chart_data_manifest.json`.
