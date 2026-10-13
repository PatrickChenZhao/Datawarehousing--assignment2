-- Q3 nested-query answer, tie handling and yearly maximum cross-check

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 220
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/evidence/section_b/q3_output.txt"

PROMPT ===== Q3 ANSWER; DENSE_RANK RETAINS TIES =====
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
        JOIN sh.times t ON t.time_id = s.time_id
        JOIN sh.products p ON p.prod_id = s.prod_id
        JOIN sh.customers cu ON cu.cust_id = s.cust_id
        JOIN sh.countries c ON c.country_id = cu.country_id
        WHERE c.country_name = 'Australia'
          AND t.calendar_year BETWEEN 1998 AND 2001
        GROUP BY t.calendar_year, p.prod_id, p.prod_name
    ) product_year_totals
)
WHERE quantity_rank = 1
ORDER BY calendar_year, prod_id;

PROMPT ===== Q3 INDEPENDENT YEARLY-MAXIMUM CROSS-CHECK =====
WITH product_year_totals AS (
    SELECT t.calendar_year,
           p.prod_id,
           p.prod_name,
           SUM(s.quantity_sold) AS total_quantity
    FROM sh.sales s
    JOIN sh.times t ON t.time_id = s.time_id
    JOIN sh.products p ON p.prod_id = s.prod_id
    JOIN sh.customers cu ON cu.cust_id = s.cust_id
    JOIN sh.countries c ON c.country_id = cu.country_id
    WHERE c.country_name = 'Australia'
      AND t.calendar_year IN (1998, 1999, 2000, 2001)
    GROUP BY t.calendar_year, p.prod_id, p.prod_name
),
yearly_maximum AS (
    SELECT calendar_year,
           MAX(total_quantity) AS maximum_quantity
    FROM product_year_totals
    GROUP BY calendar_year
)
SELECT ym.calendar_year,
       ym.maximum_quantity,
       COUNT(*) AS products_tied_at_maximum
FROM yearly_maximum ym
JOIN product_year_totals pyt
    ON pyt.calendar_year = ym.calendar_year
   AND pyt.total_quantity = ym.maximum_quantity
GROUP BY ym.calendar_year, ym.maximum_quantity
ORDER BY ym.calendar_year;

PROMPT ===== Q3 YEAR COVERAGE CHECK =====
SELECT t.calendar_year,
       COUNT(*) AS australia_sales_rows
FROM sh.sales s
JOIN sh.times t ON t.time_id = s.time_id
JOIN sh.customers cu ON cu.cust_id = s.cust_id
JOIN sh.countries c ON c.country_id = cu.country_id
WHERE c.country_name = 'Australia'
  AND t.calendar_year BETWEEN 1998 AND 2001
GROUP BY t.calendar_year
ORDER BY t.calendar_year;

PROMPT ===== Q3 VALIDATION COMPLETE =====
SPOOL OFF
