-- Local evidence wrapper for createDW.sql.
-- Run this file with F5 after the read-only preflight has been reviewed.

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 220
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/evidence/section_a/createDW_run.txt"

@"/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/createDW.sql"

SPOOL OFF

