-- Q5 materialized-view creation and validation
-- Run with F5 only after preflight confirms that the exact name is safe and
-- the current user has CREATE MATERIALIZED VIEW.

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 260
SET LONG 5000
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/evidence/section_b/q5_output.txt"

PROMPT ===== Q5 EXISTING CURRENT-SCHEMA OBJECT CHECK =====
SELECT object_type, object_name, status
FROM user_objects
WHERE object_name = 'PROMOTION_ANALYSIS_MV'
ORDER BY object_type;

PROMPT ===== Q5 DROP EXISTING CURRENT-USER MATERIALIZED VIEW ONLY =====
DECLARE
    mv_count PLS_INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO mv_count
    FROM user_mviews
    WHERE mview_name = 'PROMOTION_ANALYSIS_MV';

    IF mv_count = 1 THEN
        EXECUTE IMMEDIATE
            'DROP MATERIALIZED VIEW Promotion_Analysis_mv';
    END IF;
END;
/

PROMPT ===== Q5 CREATE MATERIALIZED VIEW =====
CREATE MATERIALIZED VIEW Promotion_Analysis_mv
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT t.calendar_month_desc AS CALENDAR_MONTH_DESC,
       pr.promo_id AS PROMO_ID,
       pr.promo_category AS PROMO_CATEGORY,
       p.prod_name AS PROD_NAME,
       p.prod_category AS PROD_CATEGORY,
       SUM(s.amount_sold) AS TOTAL_SALES
FROM sh.sales s
JOIN sh.times t ON t.time_id = s.time_id
JOIN sh.promotions pr ON pr.promo_id = s.promo_id
JOIN sh.products p ON p.prod_id = s.prod_id
WHERE t.calendar_year BETWEEN 1998 AND 2001
GROUP BY t.calendar_month_desc,
         pr.promo_id,
         pr.promo_category,
         p.prod_name,
         p.prod_category;

PROMPT ===== Q5 MATERIALIZED VIEW METADATA =====
SELECT mview_name,
       build_mode,
       refresh_mode,
       refresh_method,
       staleness,
       compile_state
FROM user_mviews
WHERE mview_name = 'PROMOTION_ANALYSIS_MV';

PROMPT ===== Q5 COLUMN DEFINITIONS =====
SELECT column_id,
       column_name,
       data_type,
       data_length,
       data_precision,
       data_scale,
       nullable
FROM user_tab_columns
WHERE table_name = 'PROMOTION_ANALYSIS_MV'
ORDER BY column_id;

PROMPT ===== Q5 DESC OUTPUT =====
DESC Promotion_Analysis_mv

PROMPT ===== Q5 ROW COUNT AND MONTH RANGE =====
SELECT COUNT(*) AS materialized_view_row_count,
       MIN(calendar_month_desc) AS first_month,
       MAX(calendar_month_desc) AS last_month
FROM Promotion_Analysis_mv;

PROMPT ===== Q5 DUPLICATE-GRAIN CHECK; EXPECT ZERO ROWS =====
SELECT calendar_month_desc,
       promo_id,
       promo_category,
       prod_name,
       prod_category,
       COUNT(*) AS duplicate_count
FROM Promotion_Analysis_mv
GROUP BY calendar_month_desc,
         promo_id,
         promo_category,
         prod_name,
         prod_category
HAVING COUNT(*) > 1
ORDER BY calendar_month_desc,
         promo_id,
         prod_name;

PROMPT ===== Q5 ORDERED FIRST TEN ROWS =====
SELECT calendar_month_desc AS CALENDAR_MONTH_DESC,
       promo_id AS PROMO_ID,
       promo_category AS PROMO_CATEGORY,
       prod_name AS PROD_NAME,
       prod_category AS PROD_CATEGORY,
       total_sales AS TOTAL_SALES
FROM (
    SELECT calendar_month_desc,
           promo_id,
           promo_category,
           prod_name,
           prod_category,
           total_sales
    FROM Promotion_Analysis_mv
    ORDER BY calendar_month_desc ASC,
             total_sales DESC,
             promo_id ASC,
             prod_name ASC
)
WHERE ROWNUM <= 10
ORDER BY calendar_month_desc ASC,
         total_sales DESC,
         promo_id ASC,
         prod_name ASC;

PROMPT ===== Q5 SOURCE-TO-MV TOTAL CHECK =====
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

PROMPT ===== Q5 VALIDATION COMPLETE =====
SPOOL OFF
