-- COMP810 Section A - read-only Oracle safety preflight
-- Run this entire file in the already connected SQL Developer worksheet with F5.
-- This script does not create, alter, drop, truncate, insert, update or delete anything.

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 220
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/evidence/section_a/db_preflight.txt"

PROMPT ===== CURRENT USER =====
SELECT USER AS current_user
FROM dual;

PROMPT ===== ORACLE VERSION =====
SELECT banner
FROM v$version
WHERE banner LIKE 'Oracle Database%';

PROMPT ===== EXISTING PF_ TABLES, VIEWS AND MATERIALIZED VIEWS =====
SELECT object_type, object_name
FROM (
    SELECT 'TABLE' AS object_type, table_name AS object_name
    FROM user_tables
    WHERE table_name LIKE 'PF\_%' ESCAPE '\'
    UNION ALL
    SELECT 'VIEW' AS object_type, view_name AS object_name
    FROM user_views
    WHERE view_name LIKE 'PF\_%' ESCAPE '\'
    UNION ALL
    SELECT 'MATERIALIZED VIEW' AS object_type, mview_name AS object_name
    FROM user_mviews
    WHERE mview_name LIKE 'PF\_%' ESCAPE '\'
)
ORDER BY object_type, object_name;

PROMPT ===== EFFECTIVE SESSION PRIVILEGES RELATED TO TABLE CREATION =====
SELECT privilege
FROM session_privs
WHERE privilege IN (
    'CREATE TABLE',
    'CREATE ANY TABLE',
    'ALTER ANY TABLE',
    'DROP ANY TABLE',
    'UNLIMITED TABLESPACE'
)
ORDER BY privilege;

PROMPT ===== DIRECTLY GRANTED SYSTEM PRIVILEGES RELATED TO TABLE CREATION =====
SELECT privilege, admin_option
FROM user_sys_privs
WHERE privilege IN (
    'CREATE TABLE',
    'CREATE ANY TABLE',
    'ALTER ANY TABLE',
    'DROP ANY TABLE',
    'UNLIMITED TABLESPACE'
)
ORDER BY privilege;

PROMPT ===== PREFLIGHT COMPLETE =====
SPOOL OFF

