# Section B conclusion evidence bullets

Status: Q1-Q7, the clean final `queriesDW.sql` run and the post-final-run chart
extracts are verified. A finding, value or recommendation is recorded only
after its corresponding evidence is verified.

## Q1

- Across 2000 and 2001 combined, the United States of America ranked first with
  raw sales of 28,181,851.80, displayed as `$28,181,852.00` after the required
  whole-dollar rounding.
- The remaining verified ranking was Germany (`$4,880,282.00`), Japan
  (`$3,779,264.00`), the United Kingdom (`$3,226,975.00`) and Italy
  (`$2,496,667.00`).
- The result describes aggregate country sales in the selected two-year period;
  it does not by itself explain the causes of the differences between countries.

## Q2

- The exact `Recordable CDs` subcategory contains seven CD-R/CD-RW products and
  excludes the false-matched CD-ROM drives identified during preflight.
- Germany had the largest European country total at 157,476.51 (displayed as
  `$157,477.xx`), followed by the United Kingdom at 110,375.37 (displayed as
  `$110,375.xx`).
- The independent ordinary aggregation produced a European grand total of
  477,592.90, which agrees with the ROLLUP result displayed as `$477,593.xx`.
- The region subtotal and grand total are equal because the query filters the
  source rows to Europe before applying `ROLLUP`; `.xx` is the required display
  placeholder rather than a statement of the precise cents.

## Q3

- Australia's unique annual quantity leaders were product 40, `O/S
  Documentation Set - English` (325) in 1998; product 37, `Envoy External 8X
  CD-ROM` (349) in 1999; product 31, `1.44MB External 3.5" Diskette` (325) in
  2000; and product 48, `Keyboard Wrist Rest` (346) in 2001.
- All four requested years are present, and the independent maximum check found
  exactly one product at the maximum in every year, so there were no ties.

## Q4

- Five non-European countries exceeded 500,000 in 1999 sales: the United States
  of America, Japan, Australia, Singapore and Canada.
- For those eligible countries, the verified channel ranking by quantity was
  Direct Sales (106,698), Partners (52,482) and Internet (21,486).
- The all-channel cross-check returned the same three rows in the same order.
  Country eligibility is based on sales amount, whereas the final channel
  ranking is based on quantity sold; these measures should not be conflated.

## Q5

- `PROMOTION_ANALYSIS_MV` was created successfully with `BUILD IMMEDIATE` and
  `REFRESH COMPLETE ON DEMAND`; Oracle reported it as `FRESH` and `VALID`.
- The materialized view contains 3,629 rows and covers `1998-01` through
  `2001-12`. Each row represents one month, promotion id/category and product
  name/category combination, with summed sales at that grain.
- The duplicate-grain check returned zero rows. Source sales and the sum of the
  MV measure were both 98,205,831.20, producing a zero difference.
- The required first-ten display is produced by a separate ordered query rather
  than assuming a materialized view stores presentation order. Its first row
  was January 1998, promotion 999 (`NO PROMOTION`), `Envoy Ambassador`, with
  total sales of 476,206.96.

## Q6

- First-quarter `NO PROMOTION` sales ranged from 5,944,078.01 to 6,427,288.63
  across 1998-2001 and were much larger than any observed promoted-category
  total. This should be treated as baseline volume, not evidence that avoiding
  promotion caused higher sales.
- Among the promotion categories observed in historical first quarters, TV in
  2001 had the largest total at 250,385.81, compared with post at 53,395.37 in
  1998 and internet at 40,811.48 in 2000.
- Across the full 1998-2001 period, internet had the largest promoted-category
  total at 2,199,380.90, ahead of TV at 1,224,503.26 and post at 277,426.26.
  The all-period and first-quarter views therefore answer different planning
  questions.
- For 2002 Q1, TV is the leading candidate for a controlled test based on the
  available Q1 sales comparison. Management should retain a no-promotion
  holdout and assess incremental sales, cost and profit before a wider rollout.
- The historical categories were not all observed in every first quarter, and
  sales totals alone do not establish causal promotion lift, ROI, profit or
  cost effectiveness.

## Q7

- Peripherals and Accessories contributed 31,163,988.41 across 1998-2001,
  representing 31.73% of total sales, and was the highest-sales category in 42
  of the 48 months.
- Electronics annual sales increased from 1,775,688.87 in 1998 to 4,704,850.95
  in 2001 (165.0%), while Photo increased from 3,414,323.88 to 6,333,628.91
  (85.5%). Over the same comparison, Hardware decreased by 17.0% and
  Peripherals and Accessories decreased by 13.4%.
- Total monthly sales ranged from 1,573,272.66 in April 1999 to 2,547,042.11 in
  December 2001. The monthly category view exposes changes and volatility that
  the annual promotion chart cannot show.
- Management can use the chart to maintain core capacity for Peripherals and
  Accessories while reviewing higher 2002 inventory and campaign support for
  the growing Electronics and Photo categories. Hardware's volatility and
  lower 2001 annual total warrant closer product-level investigation before
  committing stock.
- The descriptive time series does not identify causes or guarantee 2002
  demand; inventory decisions should incorporate margin, stock, lead-time and
  newer demand information.
