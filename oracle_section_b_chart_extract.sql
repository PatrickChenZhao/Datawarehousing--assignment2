-- Q6/Q7 CSV extraction from the verified Promotion_Analysis_mv only.
-- Run with F5 after Q5 has been verified. Each CSV is quoted explicitly so
-- commas in labels cannot break the file structure.

SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET PAGESIZE 0
SET LINESIZE 1000
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/artifacts/section_b/data/q6_q1_promo_sales.csv"
PROMPT CALENDAR_YEAR,PROMO_CATEGORY,TOTAL_SALES
SELECT '"' || REPLACE(calendar_year, '"', '""') || '","' ||
       REPLACE(promo_category, '"', '""') || '","' ||
       TO_CHAR(
           total_sales,
           'FM9999999999999990D00',
           'NLS_NUMERIC_CHARACTERS=''.,'''
       ) || '"'
FROM (
    SELECT SUBSTR(calendar_month_desc, 1, 4) AS calendar_year,
           NVL(promo_category, '(NULL)') AS promo_category,
           SUM(total_sales) AS total_sales
    FROM Promotion_Analysis_mv
    WHERE SUBSTR(calendar_month_desc, 6, 2) IN ('01', '02', '03')
    GROUP BY SUBSTR(calendar_month_desc, 1, 4),
             NVL(promo_category, '(NULL)')
)
ORDER BY calendar_year,
         total_sales DESC,
         promo_category;
SPOOL OFF

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/artifacts/section_b/data/q6_full_period_promo_sales.csv"
PROMPT PROMO_CATEGORY,TOTAL_SALES
SELECT '"' || REPLACE(promo_category, '"', '""') || '","' ||
       TO_CHAR(
           total_sales,
           'FM9999999999999990D00',
           'NLS_NUMERIC_CHARACTERS=''.,'''
       ) || '"'
FROM (
    SELECT NVL(promo_category, '(NULL)') AS promo_category,
           SUM(total_sales) AS total_sales
    FROM Promotion_Analysis_mv
    GROUP BY NVL(promo_category, '(NULL)')
)
ORDER BY total_sales DESC,
         promo_category;
SPOOL OFF

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/artifacts/section_b/data/q7_monthly_product_category_sales.csv"
PROMPT CALENDAR_MONTH_DESC,PROD_CATEGORY,TOTAL_SALES
SELECT '"' || REPLACE(calendar_month_desc, '"', '""') || '","' ||
       REPLACE(prod_category, '"', '""') || '","' ||
       TO_CHAR(
           total_sales,
           'FM9999999999999990D00',
           'NLS_NUMERIC_CHARACTERS=''.,'''
       ) || '"'
FROM (
    SELECT calendar_month_desc,
           NVL(prod_category, '(NULL)') AS prod_category,
           SUM(total_sales) AS total_sales
    FROM Promotion_Analysis_mv
    GROUP BY calendar_month_desc,
             NVL(prod_category, '(NULL)')
)
ORDER BY calendar_month_desc,
         prod_category;
SPOOL OFF

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 240

PROMPT ===== Q6/Q7 CSV EXTRACTION COMPLETE =====
