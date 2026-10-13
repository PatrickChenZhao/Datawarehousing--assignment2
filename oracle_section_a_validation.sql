-- COMP810 Section A - independent Oracle validation
-- Run with F5 only after createDW.sql completes.

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 500
SET LINESIZE 240
SET TAB OFF
SET TRIMSPOOL ON

SPOOL "/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment/evidence/section_a/desc_all_tables.txt"

PROMPT ===== EXPECTED TABLE PRESENCE =====
WITH expected_tables AS (
    SELECT 'PF_DATE_DIM' AS table_name FROM dual
    UNION ALL SELECT 'PF_STORE_DIM' FROM dual
    UNION ALL SELECT 'PF_CUSTOMER_DIM' FROM dual
    UNION ALL SELECT 'PF_PRODUCT_DIM' FROM dual
    UNION ALL SELECT 'PF_TRANSACTION_FACT' FROM dual
)
SELECT e.table_name,
       CASE WHEN u.table_name IS NULL THEN 'MISSING' ELSE 'PRESENT' END AS status
FROM expected_tables e
LEFT JOIN user_tables u
    ON u.table_name = e.table_name
ORDER BY e.table_name;

PROMPT ===== EXPECTED TABLE COUNT =====
SELECT COUNT(*) AS expected_table_count
FROM user_tables
WHERE table_name IN (
    'PF_DATE_DIM',
    'PF_STORE_DIM',
    'PF_CUSTOMER_DIM',
    'PF_PRODUCT_DIM',
    'PF_TRANSACTION_FACT'
);

PROMPT ===== COLUMN DEFINITIONS =====
SELECT table_name,
       column_id,
       column_name,
       data_type,
       data_length,
       data_precision,
       data_scale,
       nullable
FROM user_tab_columns
WHERE table_name IN (
    'PF_DATE_DIM',
    'PF_STORE_DIM',
    'PF_CUSTOMER_DIM',
    'PF_PRODUCT_DIM',
    'PF_TRANSACTION_FACT'
)
ORDER BY table_name, column_id;

PROMPT ===== PK, UK, FK AND CHECK CONSTRAINT COLUMNS =====
SELECT c.table_name,
       c.constraint_name,
       c.constraint_type,
       cc.position,
       cc.column_name,
       c.status,
       c.validated,
       c.r_constraint_name
FROM user_constraints c
LEFT JOIN user_cons_columns cc
    ON cc.owner = c.owner
   AND cc.constraint_name = c.constraint_name
   AND cc.table_name = c.table_name
WHERE c.table_name IN (
    'PF_DATE_DIM',
    'PF_STORE_DIM',
    'PF_CUSTOMER_DIM',
    'PF_PRODUCT_DIM',
    'PF_TRANSACTION_FACT'
)
  AND c.constraint_type IN ('P', 'U', 'R', 'C')
ORDER BY c.table_name, c.constraint_type, c.constraint_name, cc.position;

PROMPT ===== FOREIGN KEY TARGETS =====
SELECT child.table_name AS child_table,
       child.constraint_name AS foreign_key,
       child_col.column_name AS child_column,
       parent.table_name AS parent_table,
       parent_col.column_name AS parent_column
FROM user_constraints child
JOIN user_cons_columns child_col
    ON child_col.owner = child.owner
   AND child_col.constraint_name = child.constraint_name
   AND child_col.table_name = child.table_name
JOIN user_constraints parent
    ON parent.owner = child.r_owner
   AND parent.constraint_name = child.r_constraint_name
JOIN user_cons_columns parent_col
    ON parent_col.owner = parent.owner
   AND parent_col.constraint_name = parent.constraint_name
   AND parent_col.position = child_col.position
WHERE child.constraint_type = 'R'
  AND child.table_name = 'PF_TRANSACTION_FACT'
ORDER BY child.constraint_name, child_col.position;

PROMPT ===== CHECK EXPRESSIONS =====
SELECT table_name, constraint_name, search_condition
FROM user_constraints
WHERE table_name IN (
    'PF_DATE_DIM',
    'PF_STORE_DIM',
    'PF_CUSTOMER_DIM',
    'PF_PRODUCT_DIM',
    'PF_TRANSACTION_FACT'
)
  AND constraint_type = 'C'
ORDER BY table_name, constraint_name;

PROMPT ===== DESC OUTPUT FOR ALL TABLES =====
DESC PF_DATE_DIM
DESC PF_STORE_DIM
DESC PF_CUSTOMER_DIM
DESC PF_PRODUCT_DIM
DESC PF_TRANSACTION_FACT

PROMPT ===== VALIDATION COMPLETE =====
SPOOL OFF

