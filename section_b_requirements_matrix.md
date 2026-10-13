# Section B requirements and evidence matrix

Last reviewed: 14 October 2026

Authoritative-source order used here: assignment PDF, Canvas rubric, real Oracle
data dictionary/output, SH schema diagram, working drafts, inference.

## Source audit

- `Data Warehousing Project S2 2026.pdf`: all nine pages read; pages 5-6
  visually checked against the rendered page images.
- `SH_Schema.pdf`: its single page was visually checked in full. `COSTS` is
  excluded as directed by the assignment.
- Canvas assignment and rubric: available and checked on 14 October 2026.
  Q1-Q5 each allocate 4 marks to code/output and 2 marks to the written
  conclusion. Q6-Q7 each allocate 5 marks to code/chart and 5 marks to writing.
  No extra Section B technical condition appears in the rubric.
- Existing Section A files and `PROJECT_STATUS.md`: read as working history.
- Section B preflight outputs: reviewed from two real Oracle runs on 14 October
  2026. The core environment and discovery queries succeeded. A corrected
  supplemental query using `TABLE_SCHEMA` then confirmed direct `SELECT`
  grants on all seven required SH tables without an error or warning marker.
  B0, Q1-Q7 and the consolidated clean final run are verified from real
  executions, independent cross-checks, MV-based CSV extracts and visually
  reviewed charts. The post-final-run chart re-extraction produced the same
  three hashes, and both final PNGs passed repeat visual QA.

## SH joins and relevant fields

| From | To | Join key | Relevant fields |
|---|---|---|---|
| `sh.sales s` | `sh.products p` | `s.prod_id = p.prod_id` | `prod_name`, `prod_desc`, `prod_subcategory`, `prod_category` |
| `sh.sales s` | `sh.customers cu` | `s.cust_id = cu.cust_id` | `country_id` |
| `sh.customers cu` | `sh.countries c` | `cu.country_id = c.country_id` | `country_name`, `country_region` |
| `sh.sales s` | `sh.times t` | `s.time_id = t.time_id` | `calendar_month_desc`, `calendar_month_number`, `calendar_year` |
| `sh.sales s` | `sh.channels ch` | `s.channel_id = ch.channel_id` | `channel_desc` |
| `sh.sales s` | `sh.promotions pr` | `s.promo_id = pr.promo_id` | `promo_name`, `promo_subcategory`, `promo_category` |

The measures used are `sh.sales.amount_sold` and `sh.sales.quantity_sold`.

## Question matrix

| Question | Assignment requirement | Required SQL/analysis technique | Exact output columns | Filters and grouping | Ordering/ranking | Validation evidence | Status |
|---|---|---|---|---|---|---|---|
| Q1 | Top five countries by total `amount_sold` in 2000 and 2001; show region, country and sales formatted like `$123,456,789.00`. | ANSI joins; grouped `SUM`; analytic `ROW_NUMBER`; numeric rounding before display formatting. | `Region`, `Country Name`, `Sales` | `calendar_year BETWEEN 2000 AND 2001`; group by region and country. | Total sales descending, then country and region for a deterministic five rows. | `evidence/section_b/q1_output.txt`: five formatted answer rows agree with the raw numeric ranking and rounded totals; clean completion marker and no error/warning text. | **verified** |
| Q2 | Using `GROUP BY ROLLUP`, show European sales for every real CD-R/CD-RW product type; decimal characters must be literal `xx`. | `ROLLUP`; `GROUPING`/`GROUPING_ID`; numeric aggregation before text formatting. | `COUNTRY_REGION`, `COUNTRY_NAME`, `TOTAL_SALES` | Europe only; confirmed canonical filter `prod_subcategory = 'Recordable CDs'`. | Detail rows, region subtotal, grand total; deterministic label ordering. | `evidence/section_b/q2_output.txt`: seven matched products; eight details reconcile to the 477,592.90 ordinary total and `$477,593.xx` ROLLUP total; clean completion. | **verified** |
| Q3 | Nested query finding the product sold in the greatest quantity in Australia in each year 1998-2001 inclusive. | Nested grouped query plus `DENSE_RANK` so tied maxima are not silently discarded. | `CALENDAR_YEAR`, `PROD_ID`, `PROD_NAME`, `TOTAL_QUANTITY` | Australia; years 1998-2001; group by year, product id and product name. | One or more rank-1 products per year; final order by year and product id. | `evidence/section_b/q3_output.txt`: four answer rows agree with independent yearly maxima; one maximum product per year and complete year coverage; clean completion. | **verified** |
| Q4 | Top three channels by quantity for non-European countries whose 1999 country sales exceeded $500,000. | CTE identifying eligible countries first; subsequent channel aggregation; analytic `ROW_NUMBER`. | `CHANNEL_DESC`, `TOTAL_QUANTITY` | 1999; country region not Europe; country-level `HAVING SUM(amount_sold) > 500000`. | Quantity descending, channel description as deterministic tie-breaker; exactly three rows if at least three channels qualify. | `evidence/section_b/q4_output.txt`: five eligible countries; the three-row answer equals the complete all-channel cross-check; clean completion. | **verified** |
| Q5 | Create `Promotion_Analysis_mv` for monthly 1998-2001 sales by the displayed promotion/product fields; show ordered first ten records. | Materialized view; `BUILD IMMEDIATE`; `REFRESH COMPLETE ON DEMAND`; grouped `SUM(amount_sold)`; separate ordered top-ten query. | `CALENDAR_MONTH_DESC`, `PROMO_ID`, `PROMO_CATEGORY`, `PROD_NAME`, `PROD_CATEGORY`, `TOTAL_SALES` | Years 1998-2001; group grain exactly matches the five non-aggregate columns. | Full order by month ascending, sales descending, then promotion id and product name; limit only after sorting. | `evidence/section_b/q5_output.txt`: FRESH/VALID MV, six correct columns, 3,629 rows covering 1998-01 to 2001-12, zero duplicate grains and zero source-total difference; clean completion. | **verified** |
| Q6 | Chart comparing sales under each promotion category and support a recommendation for 2002 Q1. | Aggregate the verified Q5 MV only. Inspect both all-period category totals and historical Q1 totals by year/category before finalising the chart. | Chart extraction: `CALENDAR_YEAR`, `PROMO_CATEGORY`, `TOTAL_SALES`; supporting extraction: `PROMO_CATEGORY`, `TOTAL_SALES`. | Q1 means month numbers 01-03 for each historical year. Preserve any actual no-promotion category rather than inventing one. | Chronological year; within-year totals descending in SQL; grouped bars in chart. | Two real CSVs and manifest: 7 Q1 year/category rows and 4 full-period category rows; 1998-2001 grouped-bar PNG visually passed at 1600 x 900. | **verified** |
| Q7 | A time-based chart using Q5 information that is significantly different from Q6, plus usefulness and management recommendations. | Aggregate the verified Q5 MV by month and product category; monthly multi-series trend chart. | `CALENDAR_MONTH_DESC`, `PROD_CATEGORY`, `TOTAL_SALES` | All months 1998-2001; product category rather than promotion category. | True chronological month order; readable tick interval and stable category legend. | Real CSV and manifest: exactly 240 unique rows covering 48 months by 5 categories; monthly line-chart PNG visually passed at 1600 x 900. | **verified** |

## Interpretation decisions

- Q1: the sample output does not include `CALENDAR_YEAR`. The default
  interpretation is therefore one combined 2000-2001 country total, followed
  by a single top-five ranking. The Canvas rubric adds no contrary instruction.
- Q2: real discovery showed seven intended products in the canonical
  `Recordable CDs` subcategory. The earlier text regex also matched six CD-ROM
  drives because `CD-ROM` begins with `CD-R`; it has been replaced by the exact
  subcategory filter.
- Q3: `DENSE_RANK` is used deliberately. If two products have the same yearly
  maximum, both are valid answers and neither is silently discarded.
- Q4: “countries ... that had a total sales amount greater than $500,000” is
  interpreted as a country-level eligibility test before the eligible
  countries' channel quantities are combined. The rubric does not supply a
  different interpretation.
- Q5: ordering is not treated as a persistent materialized-view property. The
  screenshot query applies the required sort and then limits the result.
- Q6: the confirmed chart is historical Q1 promotion-category sales by year,
  because it aligns directly with the 2002 Q1 decision and does not hide annual
  variation. The all-period comparison remains supporting context.
- Q7: monthly product-category sales is materially different from Q6 in its
  subject, time resolution and management use. The real export confirmed five
  readable category series across all 48 months.

## Verified preflight facts

- Current user: `GWC5419`.
- Oracle Database 19c Enterprise Edition.
- `sh.sales` is readable and contains 918,843 rows.
- All seven required SH tables are visible and valid.
- Sales cover 1 January 1998 through 31 December 2001; the four yearly row
  counts are present.
- `Australia` is the exact country name and belongs to `Oceania`.
- `Europe` is an exact `country_region` value.
- `calendar_month_desc` uses `YYYY-MM`, with 48 months from `1998-01` through
  `2001-12`.
- Promotion id 999 is `NO PROMOTION #`, category `NO PROMOTION`.
- `PROMOTION_ANALYSIS_MV` does not currently exist and no same-named object is
  present in the current schema.
- `CREATE MATERIALIZED VIEW`, `CREATE TABLE` and `UNLIMITED TABLESPACE` are
  effective and directly granted.
- Direct `SELECT` grants to `GWC5419` are confirmed on `SH.CHANNELS`,
  `SH.COUNTRIES`, `SH.CUSTOMERS`, `SH.PRODUCTS`, `SH.PROMOTIONS`, `SH.SALES`
  and `SH.TIMES`.
- The original direct-object-grant query's preserved `ORA-00904` was caused by
  this database exposing `TABLE_SCHEMA`, not `OWNER`, in `ALL_TAB_PRIVS`. The
  corrected supplemental output selected seven rows and completed cleanly.

## Submission and GAI controls

- The report must include code, output and a conclusion for each question.
- Figures and tables need appropriate captions and must be referred to in the
  report.
- The separate submission file must be named `queriesDW.sql`.
- The student must write the final analysis in their own words. The technical
  evidence bullets are not a substitute for that writing.
- An honest AI Use Log is mandatory. It must identify the tool, affected
  sections, purpose, and how the output was verified or revised.
