-- Q2 ROLLUP answer and ordinary-aggregation cross-check
-- The CD-R/CD-RW predicate must be compared with preflight product discovery.

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 240
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/evidence/section_b/q2_output.txt"

PROMPT ===== Q2 MATCHED PRODUCT TYPES =====
SELECT p.prod_id,
       p.prod_name,
       p.prod_desc,
       p.prod_subcategory,
       p.prod_category
FROM sh.products p
WHERE p.prod_subcategory = 'Recordable CDs'
ORDER BY p.prod_name, p.prod_id;

PROMPT ===== Q2 ANSWER USING GROUP BY ROLLUP =====
WITH rollup_sales AS (
    SELECT CASE
               WHEN GROUPING(c.country_region) = 1 THEN 'ALL REGIONS'
               ELSE c.country_region
           END AS country_region,
           CASE
               WHEN GROUPING(c.country_region) = 1
                AND GROUPING(c.country_name) = 1 THEN 'GRAND TOTAL'
               WHEN GROUPING(c.country_name) = 1 THEN 'REGION TOTAL'
               ELSE c.country_name
           END AS country_name,
           ROUND(SUM(s.amount_sold)) AS rounded_sales,
           GROUPING_ID(c.country_region, c.country_name) AS group_level
    FROM sh.sales s
    JOIN sh.products p ON p.prod_id = s.prod_id
    JOIN sh.customers cu ON cu.cust_id = s.cust_id
    JOIN sh.countries c ON c.country_id = cu.country_id
    WHERE c.country_region = 'Europe'
      AND p.prod_subcategory = 'Recordable CDs'
    GROUP BY ROLLUP(c.country_region, c.country_name)
)
SELECT country_region AS COUNTRY_REGION,
       country_name AS COUNTRY_NAME,
       TO_CHAR(
           rounded_sales,
           'FM$999,999,999,999,990',
           'NLS_NUMERIC_CHARACTERS=''.,'''
       ) || '.xx' AS TOTAL_SALES
FROM rollup_sales
ORDER BY group_level, country_region, country_name;

PROMPT ===== Q2 ORDINARY-GROUP-BY CROSS-CHECK =====
WITH detail_totals AS (
    SELECT c.country_name,
           SUM(s.amount_sold) AS total_sales
    FROM sh.sales s
    JOIN sh.products p ON p.prod_id = s.prod_id
    JOIN sh.customers cu ON cu.cust_id = s.cust_id
    JOIN sh.countries c ON c.country_id = cu.country_id
    WHERE c.country_region = 'Europe'
      AND p.prod_subcategory = 'Recordable CDs'
    GROUP BY c.country_name
)
SELECT country_name,
       total_sales,
       ROUND(total_sales) AS rounded_sales,
       SUM(total_sales) OVER () AS grand_total_check
FROM detail_totals
ORDER BY country_name;

PROMPT ===== Q2 VALIDATION COMPLETE =====
SPOOL OFF
