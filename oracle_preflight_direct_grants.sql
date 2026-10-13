-- Section B supplemental read-only preflight.
-- The original preflight used OWNER instead of TABLE_SCHEMA in ALL_TAB_PRIVS.
-- Run this short file with F5; it does not change any database object or data.

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 200
SET LINESIZE 220
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/evidence/section_b/preflight_direct_grants_output.txt"

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

PROMPT ===== SUPPLEMENTAL PREFLIGHT COMPLETE =====
SPOOL OFF
