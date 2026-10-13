-- Q4 answer plus independent eligible-country and channel checks

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 240
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/evidence/section_b/q4_output.txt"

PROMPT ===== Q4 ELIGIBLE COUNTRIES =====
SELECT c.country_id,
       c.country_region,
       c.country_name,
       SUM(s.amount_sold) AS country_total_sales
FROM sh.sales s
JOIN sh.times t ON t.time_id = s.time_id
JOIN sh.customers cu ON cu.cust_id = s.cust_id
JOIN sh.countries c ON c.country_id = cu.country_id
WHERE t.calendar_year = 1999
  AND c.country_region <> 'Europe'
GROUP BY c.country_id, c.country_region, c.country_name
HAVING SUM(s.amount_sold) > 500000
ORDER BY country_total_sales DESC, c.country_name;

PROMPT ===== Q4 ANSWER =====
WITH eligible_countries AS (
    SELECT c.country_id
    FROM sh.sales s
    JOIN sh.times t ON t.time_id = s.time_id
    JOIN sh.customers cu ON cu.cust_id = s.cust_id
    JOIN sh.countries c ON c.country_id = cu.country_id
    WHERE t.calendar_year = 1999
      AND c.country_region <> 'Europe'
    GROUP BY c.country_id
    HAVING SUM(s.amount_sold) > 500000
),
channel_totals AS (
    SELECT ch.channel_desc,
           SUM(s.quantity_sold) AS total_quantity
    FROM sh.sales s
    JOIN sh.times t ON t.time_id = s.time_id
    JOIN sh.channels ch ON ch.channel_id = s.channel_id
    JOIN sh.customers cu ON cu.cust_id = s.cust_id
    JOIN eligible_countries ec ON ec.country_id = cu.country_id
    WHERE t.calendar_year = 1999
    GROUP BY ch.channel_desc
),
ranked_channels AS (
    SELECT channel_desc,
           total_quantity,
           ROW_NUMBER() OVER (
               ORDER BY total_quantity DESC, channel_desc ASC
           ) AS channel_rank
    FROM channel_totals
)
SELECT channel_desc AS CHANNEL_DESC,
       total_quantity AS TOTAL_QUANTITY
FROM ranked_channels
WHERE channel_rank <= 3
ORDER BY channel_rank;

PROMPT ===== Q4 ALL-CHANNEL RAW-NUMBER CROSS-CHECK =====
WITH eligible_countries AS (
    SELECT c.country_id
    FROM sh.sales s
    JOIN sh.times t ON t.time_id = s.time_id
    JOIN sh.customers cu ON cu.cust_id = s.cust_id
    JOIN sh.countries c ON c.country_id = cu.country_id
    WHERE t.calendar_year = 1999
      AND c.country_region <> 'Europe'
    GROUP BY c.country_id
    HAVING SUM(s.amount_sold) > 500000
)
SELECT ch.channel_desc,
       SUM(s.quantity_sold) AS total_quantity
FROM sh.sales s
JOIN sh.times t ON t.time_id = s.time_id
JOIN sh.channels ch ON ch.channel_id = s.channel_id
JOIN sh.customers cu ON cu.cust_id = s.cust_id
JOIN eligible_countries ec ON ec.country_id = cu.country_id
WHERE t.calendar_year = 1999
GROUP BY ch.channel_desc
ORDER BY total_quantity DESC, ch.channel_desc ASC;

PROMPT ===== Q4 VALIDATION COMPLETE =====
SPOOL OFF
