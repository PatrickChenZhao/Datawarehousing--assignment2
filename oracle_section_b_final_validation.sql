-- Final Section B run wrapper. Run with F5 only after the individual Q1-Q5
-- validation files and Q6/Q7 CSV/chart checks have passed.

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 260
SET LONG 5000
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/evidence/section_b/queriesDW_final_run.txt"

PROMPT ===== BEGIN CLEAN FINAL RUN OF queriesDW.sql =====
@"/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/queriesDW.sql"

PROMPT ===== FINAL MATERIALIZED VIEW METADATA =====
SELECT mview_name,
       build_mode,
       refresh_mode,
       refresh_method,
       staleness,
       compile_state
FROM user_mviews
WHERE mview_name = 'PROMOTION_ANALYSIS_MV';

PROMPT ===== FINAL MATERIALIZED VIEW COLUMN ORDER =====
SELECT column_id,
       column_name,
       data_type,
       data_precision,
       data_scale
FROM user_tab_columns
WHERE table_name = 'PROMOTION_ANALYSIS_MV'
ORDER BY column_id;

PROMPT ===== FINAL MATERIALIZED VIEW CONTROL TOTAL =====
SELECT source_totals.source_total_sales,
       mv_totals.mv_total_sales,
       source_totals.source_total_sales - mv_totals.mv_total_sales
           AS total_sales_difference
FROM (
    SELECT SUM(s.amount_sold) AS source_total_sales
    FROM sh.sales s
    JOIN sh.times t ON t.time_id = s.time_id
    WHERE t.calendar_year BETWEEN 1998 AND 2001
) source_totals
CROSS JOIN (
    SELECT SUM(total_sales) AS mv_total_sales
    FROM Promotion_Analysis_mv
) mv_totals;

PROMPT ===== FINAL RUN COMPLETE =====
SPOOL OFF
