# Q6 and Q7 chart notes

Status: verified from real Q5 materialized-view exports on 14 October 2026 and
resynchronized after the clean final run recreated the MV.

## Q6

Verified extracts:

1. 1998-2001 total sales by promotion category.
2. January-March sales by calendar year and promotion category.

The final chart uses extract 2 as grouped bars. It is directly aligned with a
first-quarter 2002 decision and keeps year-to-year variation visible. The
all-period extract was retained as supporting context. Four real categories
were present, including the exact `NO PROMOTION` value, and the legend remains
readable.

Verified caption:

> Historical first-quarter sales by promotion category, 1998-2001. Source:
> `Promotion_Analysis_mv`; values are aggregated `amount_sold` in USD.

The PNG was checked at 1600 x 900. It has a zero baseline, USD-million axis,
value labels for non-zero bars, complete 1998-2001 coverage, a readable legend
and no clipping or overlap. The report must not claim promotion lift, profit,
ROI or causation from these sales totals alone.

## Q7

The final chart is a monthly line chart of total sales by product category.
It differs from Q6 by using product rather than promotion categories, monthly
rather than yearly/Q1 resolution, and a trend/seasonality purpose rather than a
promotion mix comparison.

Verified caption:

> Monthly sales by product category, January 1998 to December 2001. Source:
> `Promotion_Analysis_mv`; values are aggregated `amount_sold` in USD.

The PNG was checked at 1600 x 900. It contains all 48 chronological months and
five product-category series, quarterly tick labels, a USD-million axis and a
readable external legend. Colour distinction, clipping, overlap and resolution
all passed visual review.

## Data controls

- `q6_q1_promo_sales.csv`: 7 unique rows, four categories, 1998-2001.
- `q6_full_period_promo_sales.csv`: 4 unique promotion-category rows.
- `q7_monthly_product_category_sales.csv`: 240 unique rows, exactly 48 months
  by five categories, 1998-01 through 2001-12.
- `chart_data_manifest.json` records the exact fields, row counts, coverage,
  generation timestamps and SHA-256 hash of every input.
- The post-final-run export retained the same three hashes
  (`e9d42d19...`, `b52e464d...`, `6c77da1e...`), so the verified conclusions
  did not change. The manifest and charts were regenerated from those final
  files at 11:28:58 NZDT.
- The first export's malformed `PROMPT` headers were rejected before chart
  creation. The corrected unquoted headers were rerun from Oracle and passed
  the chart builder's strict field validation.
