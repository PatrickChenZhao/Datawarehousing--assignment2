-- COMP810 Data Warehousing Project 2026 - Section B
-- Status: ORACLE VERIFIED ON 14 OCTOBER 2026
-- Run the whole script with F5 / Run Script in the existing school Oracle
-- connection. The retained clean-run evidence is
-- evidence/section_b/queriesDW_final_run.txt.

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 240
SET TAB OFF
SET TRIMSPOOL ON

PROMPT ===== Q1: TOP FIVE COUNTRIES BY SALES, 2000-2001 COMBINED =====

WITH country_totals AS (
    SELECT c.country_region,
           c.country_name,
           SUM(s.amount_sold) AS total_sales
    FROM sh.sales s
    JOIN sh.times t
        ON t.time_id = s.time_id
    JOIN sh.customers cu
        ON cu.cust_id = s.cust_id
    JOIN sh.countries c
        ON c.country_id = cu.country_id
    WHERE t.calendar_year BETWEEN 2000 AND 2001
    GROUP BY c.country_region,
             c.country_name
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

PROMPT ===== Q2: EUROPEAN CD-R/CD-RW SALES WITH ROLLUP =====

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
    JOIN sh.products p
        ON p.prod_id = s.prod_id
    JOIN sh.customers cu
        ON cu.cust_id = s.cust_id
    JOIN sh.countries c
        ON c.country_id = cu.country_id
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
ORDER BY group_level,
         country_region,
         country_name;

PROMPT ===== Q3: TOP-QUANTITY PRODUCT IN AUSTRALIA BY YEAR =====

SELECT calendar_year AS CALENDAR_YEAR,
       prod_id AS PROD_ID,
       prod_name AS PROD_NAME,
       total_quantity AS TOTAL_QUANTITY
FROM (
    SELECT product_year_totals.*,
           DENSE_RANK() OVER (
               PARTITION BY calendar_year
               ORDER BY total_quantity DESC
           ) AS quantity_rank
    FROM (
        SELECT t.calendar_year,
               p.prod_id,
               p.prod_name,
               SUM(s.quantity_sold) AS total_quantity
        FROM sh.sales s
        JOIN sh.times t
            ON t.time_id = s.time_id
        JOIN sh.products p
            ON p.prod_id = s.prod_id
        JOIN sh.customers cu
            ON cu.cust_id = s.cust_id
        JOIN sh.countries c
            ON c.country_id = cu.country_id
        WHERE c.country_name = 'Australia'
          AND t.calendar_year BETWEEN 1998 AND 2001
        GROUP BY t.calendar_year,
                 p.prod_id,
                 p.prod_name
    ) product_year_totals
)
WHERE quantity_rank = 1
ORDER BY calendar_year,
         prod_id;

PROMPT ===== Q4: TOP THREE CHANNELS FOR QUALIFYING NON-EUROPEAN COUNTRIES =====

WITH eligible_countries AS (
    SELECT c.country_id
    FROM sh.sales s
    JOIN sh.times t
        ON t.time_id = s.time_id
    JOIN sh.customers cu
        ON cu.cust_id = s.cust_id
    JOIN sh.countries c
        ON c.country_id = cu.country_id
    WHERE t.calendar_year = 1999
      AND c.country_region <> 'Europe'
    GROUP BY c.country_id
    HAVING SUM(s.amount_sold) > 500000
),
channel_totals AS (
    SELECT ch.channel_desc,
           SUM(s.quantity_sold) AS total_quantity
    FROM sh.sales s
    JOIN sh.times t
        ON t.time_id = s.time_id
    JOIN sh.channels ch
        ON ch.channel_id = s.channel_id
    JOIN sh.customers cu
        ON cu.cust_id = s.cust_id
    JOIN eligible_countries ec
        ON ec.country_id = cu.country_id
    WHERE t.calendar_year = 1999
    GROUP BY ch.channel_desc
),
ranked_channels AS (
    SELECT channel_desc,
           total_quantity,
           ROW_NUMBER() OVER (
               ORDER BY total_quantity DESC,
                        channel_desc ASC
           ) AS channel_rank
    FROM channel_totals
)
SELECT channel_desc AS CHANNEL_DESC,
       total_quantity AS TOTAL_QUANTITY
FROM ranked_channels
WHERE channel_rank <= 3
ORDER BY channel_rank;

PROMPT ===== Q5: PROMOTION_ANALYSIS_MV =====

-- This block drops only the current user's materialized view of the exact
-- required name. A same-named table or ordinary view is not dropped.
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
JOIN sh.times t
    ON t.time_id = s.time_id
JOIN sh.promotions pr
    ON pr.promo_id = s.promo_id
JOIN sh.products p
    ON p.prod_id = s.prod_id
WHERE t.calendar_year BETWEEN 1998 AND 2001
GROUP BY t.calendar_month_desc,
         pr.promo_id,
         pr.promo_category,
         p.prod_name,
         p.prod_category;

-- A materialized view has no guaranteed display order. This separate query
-- performs the complete sort first and then limits the result to ten rows.
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

PROMPT ===== Q6: HISTORICAL FIRST-QUARTER PROMOTION SALES =====

SELECT SUBSTR(calendar_month_desc, 1, 4) AS CALENDAR_YEAR,
       NVL(promo_category, '(NULL)') AS PROMO_CATEGORY,
       SUM(total_sales) AS TOTAL_SALES
FROM Promotion_Analysis_mv
WHERE SUBSTR(calendar_month_desc, 6, 2) IN ('01', '02', '03')
GROUP BY SUBSTR(calendar_month_desc, 1, 4),
         NVL(promo_category, '(NULL)')
ORDER BY calendar_year,
         total_sales DESC,
         promo_category;

-- Supporting all-period comparison used to contextualise the Q1 chart.
SELECT NVL(promo_category, '(NULL)') AS PROMO_CATEGORY,
       SUM(total_sales) AS TOTAL_SALES
FROM Promotion_Analysis_mv
GROUP BY NVL(promo_category, '(NULL)')
ORDER BY total_sales DESC,
         promo_category;

PROMPT ===== Q7: MONTHLY PRODUCT-CATEGORY SALES AGAINST TIME =====

SELECT calendar_month_desc AS CALENDAR_MONTH_DESC,
       NVL(prod_category, '(NULL)') AS PROD_CATEGORY,
       SUM(total_sales) AS TOTAL_SALES
FROM Promotion_Analysis_mv
GROUP BY calendar_month_desc,
         NVL(prod_category, '(NULL)')
ORDER BY calendar_month_desc,
         prod_category;

PROMPT ===== END OF SECTION B QUERIES =====
