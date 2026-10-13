-- Q1 answer and independent numeric cross-check
-- Run with F5 after oracle_preflight.sql has been reviewed.

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 220
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/evidence/section_b/q1_output.txt"

PROMPT ===== Q1 ANSWER =====
WITH country_totals AS (
    SELECT c.country_region,
           c.country_name,
           SUM(s.amount_sold) AS total_sales
    FROM sh.sales s
    JOIN sh.times t ON t.time_id = s.time_id
    JOIN sh.customers cu ON cu.cust_id = s.cust_id
    JOIN sh.countries c ON c.country_id = cu.country_id
    WHERE t.calendar_year BETWEEN 2000 AND 2001
    GROUP BY c.country_region, c.country_name
),
ranked_countries AS (
    SELECT country_region,
           country_name,
           total_sales,
           ROW_NUMBER() OVER (
               ORDER BY total_sales DESC,
                        country_name ASC,
                        country_region ASC
           ) AS sales_rank
    FROM country_totals
)
SELECT country_region AS "Region",
       country_name AS "Country Name",
       TO_CHAR(
           ROUND(total_sales),
           'FM$999,999,999,999,990.00',
           'NLS_NUMERIC_CHARACTERS=''.,'''
       ) AS "Sales"
FROM ranked_countries
WHERE sales_rank <= 5
ORDER BY sales_rank;

PROMPT ===== Q1 INDEPENDENT RAW-NUMBER CROSS-CHECK =====
WITH country_totals AS (
    SELECT c.country_region,
           c.country_name,
           SUM(s.amount_sold) AS total_sales
    FROM sh.sales s
    JOIN sh.times t ON t.time_id = s.time_id
    JOIN sh.customers cu ON cu.cust_id = s.cust_id
    JOIN sh.countries c ON c.country_id = cu.country_id
    WHERE t.calendar_year IN (2000, 2001)
    GROUP BY c.country_region, c.country_name
)
SELECT sales_rank,
       country_region,
       country_name,
       total_sales,
       ROUND(total_sales) AS rounded_sales
FROM (
    SELECT country_totals.*,
           ROW_NUMBER() OVER (
               ORDER BY total_sales DESC,
                        country_name ASC,
                        country_region ASC
           ) AS sales_rank
    FROM country_totals
)
WHERE sales_rank <= 5
ORDER BY sales_rank;

PROMPT ===== Q1 RETURNED ROW COUNT CHECK =====
WITH country_totals AS (
    SELECT c.country_region,
           c.country_name,
           SUM(s.amount_sold) AS total_sales
    FROM sh.sales s
    JOIN sh.times t ON t.time_id = s.time_id
    JOIN sh.customers cu ON cu.cust_id = s.cust_id
    JOIN sh.countries c ON c.country_id = cu.country_id
    WHERE t.calendar_year BETWEEN 2000 AND 2001
    GROUP BY c.country_region, c.country_name
),
ranked_countries AS (
    SELECT ROW_NUMBER() OVER (
               ORDER BY total_sales DESC,
                        country_name ASC,
                        country_region ASC
           ) AS sales_rank
    FROM country_totals
)
SELECT COUNT(*) AS expected_five_rows
FROM ranked_countries
WHERE sales_rank <= 5;

PROMPT ===== Q1 VALIDATION COMPLETE =====
SPOOL OFF
