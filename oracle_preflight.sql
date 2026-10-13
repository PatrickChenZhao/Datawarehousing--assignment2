-- COMP810 Section B - read-only Oracle preflight and data discovery
-- Run this entire file with F5 in the already connected SQL Developer
-- worksheet. It does not create, alter, drop, insert, update or delete data.

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 260
SET LONG 5000
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/evidence/section_b/preflight_output.txt"

PROMPT ===== CURRENT USER =====
SELECT USER AS current_user
FROM dual;

PROMPT ===== ORACLE VERSION =====
SELECT banner
FROM v$version
WHERE banner LIKE 'Oracle Database%';

PROMPT ===== READ ACCESS TO SH.SALES =====
SELECT COUNT(*) AS sh_sales_row_count
FROM sh.sales;

PROMPT ===== REQUIRED SH OBJECTS VISIBLE TO CURRENT USER =====
SELECT owner,
       object_name,
       object_type,
       status
FROM all_objects
WHERE owner = 'SH'
  AND object_name IN (
      'SALES',
      'PRODUCTS',
      'CUSTOMERS',
      'COUNTRIES',
      'TIMES',
      'CHANNELS',
      'PROMOTIONS'
  )
  AND object_type IN ('TABLE', 'VIEW')
ORDER BY object_name,
         object_type;

PROMPT ===== REQUIRED SH COLUMN NAMES AND DATATYPES =====
SELECT table_name,
       column_id,
       column_name,
       data_type,
       data_length,
       data_precision,
       data_scale,
       nullable
FROM all_tab_columns
WHERE owner = 'SH'
  AND table_name IN (
      'SALES',
      'PRODUCTS',
      'CUSTOMERS',
      'COUNTRIES',
      'TIMES',
      'CHANNELS',
      'PROMOTIONS'
  )
ORDER BY table_name,
         column_id;

PROMPT ===== CURRENT-SCHEMA OBJECT CONFLICT CHECK =====
SELECT object_type,
       object_name,
       status
FROM user_objects
WHERE object_name = 'PROMOTION_ANALYSIS_MV'
ORDER BY object_type;

PROMPT ===== CURRENT-SCHEMA MATERIALIZED VIEW CHECK =====
SELECT mview_name,
       build_mode,
       refresh_mode,
       refresh_method,
       staleness,
       compile_state
FROM user_mviews
WHERE mview_name = 'PROMOTION_ANALYSIS_MV';

PROMPT ===== EFFECTIVE MATERIALIZED-VIEW PRIVILEGES =====
SELECT privilege
FROM session_privs
WHERE privilege IN (
    'CREATE MATERIALIZED VIEW',
    'CREATE TABLE',
    'QUERY REWRITE',
    'GLOBAL QUERY REWRITE',
    'UNLIMITED TABLESPACE'
)
ORDER BY privilege;

PROMPT ===== DIRECT MATERIALIZED-VIEW PRIVILEGES =====
SELECT privilege,
       admin_option
FROM user_sys_privs
WHERE privilege IN (
    'CREATE MATERIALIZED VIEW',
    'CREATE TABLE',
    'QUERY REWRITE',
    'GLOBAL QUERY REWRITE',
    'UNLIMITED TABLESPACE'
)
ORDER BY privilege;

PROMPT ===== DIRECT OR PUBLIC SELECT GRANTS ON REQUIRED SH OBJECTS =====
SELECT grantee,
       table_schema AS owner,
       table_name,
       privilege,
       grantable
FROM all_tab_privs
WHERE table_schema = 'SH'
  AND table_name IN (
      'SALES',
      'PRODUCTS',
      'CUSTOMERS',
      'COUNTRIES',
      'TIMES',
      'CHANNELS',
      'PROMOTIONS'
  )
  AND grantee IN (USER, 'PUBLIC')
  AND privilege = 'SELECT'
ORDER BY table_name,
         grantee;

PROMPT ===== TABLESPACE QUOTAS =====
SELECT tablespace_name,
       bytes,
       max_bytes
FROM user_ts_quotas
ORDER BY tablespace_name;

PROMPT ===== SH.SALES DATE RANGE AND ROW COUNT =====
SELECT MIN(s.time_id) AS first_sale_date,
       MAX(s.time_id) AS last_sale_date,
       COUNT(*) AS sales_row_count
FROM sh.sales s;

PROMPT ===== AVAILABLE CALENDAR YEARS =====
SELECT t.calendar_year,
       COUNT(*) AS sales_row_count
FROM sh.sales s
JOIN sh.times t
    ON t.time_id = s.time_id
GROUP BY t.calendar_year
ORDER BY t.calendar_year;

PROMPT ===== COUNTRY REGIONS =====
SELECT DISTINCT c.country_region
FROM sh.countries c
ORDER BY c.country_region;

PROMPT ===== AUSTRALIA COUNTRY VALUE =====
SELECT c.country_id,
       c.country_name,
       c.country_region
FROM sh.countries c
WHERE UPPER(c.country_name) LIKE '%AUSTRALIA%'
ORDER BY c.country_name;

PROMPT ===== CD-R AND CD-RW PRODUCT DISCOVERY =====
SELECT p.prod_id,
       p.prod_name,
       p.prod_desc,
       p.prod_subcategory,
       p.prod_category
FROM sh.products p
WHERE p.prod_subcategory = 'Recordable CDs'
ORDER BY p.prod_name,
         p.prod_id;

PROMPT ===== PROMOTION CATEGORY DISCOVERY =====
SELECT pr.promo_id,
       pr.promo_name,
       pr.promo_category,
       pr.promo_subcategory
FROM sh.promotions pr
ORDER BY pr.promo_category,
         pr.promo_id;

PROMPT ===== POSSIBLE NO-PROMOTION VALUES =====
SELECT pr.promo_id,
       pr.promo_name,
       pr.promo_category,
       pr.promo_subcategory
FROM sh.promotions pr
WHERE UPPER(
          NVL(pr.promo_name, '') || ' ' ||
          NVL(pr.promo_category, '') || ' ' ||
          NVL(pr.promo_subcategory, '')
      ) LIKE '%NO PROMO%'
ORDER BY pr.promo_id;

PROMPT ===== MONTH DESCRIPTION FORMAT AND RANGE =====
SELECT MIN(t.calendar_month_desc) AS first_month_desc,
       MAX(t.calendar_month_desc) AS last_month_desc,
       COUNT(DISTINCT t.calendar_month_desc) AS month_count
FROM sh.times t
WHERE t.calendar_year BETWEEN 1998 AND 2001;

SELECT DISTINCT t.calendar_year,
       t.calendar_month_number,
       t.calendar_month_desc
FROM sh.times t
WHERE t.calendar_year BETWEEN 1998 AND 2001
ORDER BY t.calendar_year,
         t.calendar_month_number;

PROMPT ===== PREFLIGHT COMPLETE =====
SPOOL OFF
