# COMP810 Data Warehousing Project Status

Last updated: 14 October 2026

## Overall Section A state

- Current stage: A4 complete
- Status: **verified**
- Design substatus: **confirmed by the user on 14 October 2026**
- Database substatus: **verified against real Oracle output on 14 October 2026**
- Prompt A completion criteria are satisfied.

## Authoritative material audit

Verified locally:

- all pages of `Data Warehousing Project S2 2026.pdf` read;
- assignment pages 3-4 visually checked;
- `SH_Schema.pdf` visually checked and restricted to Section B background;
- existing working files inspected;
- no Canvas rubric file found - **rubric not provided**.

## Fact grain

User-confirmed grain:

> One row in `PF_TRANSACTION_FACT` represents one accessory sale line or one repair-service line, for one product/service, one customer, one store and one calendar date, within one source transaction.

## Confirmed tables and keys

| Role | Table | Primary key | Important alternate/foreign keys |
|---|---|---|---|
| Dimension | `PF_DATE_DIM` | `DATE_KEY` | UK `FULL_DATE` |
| Dimension | `PF_STORE_DIM` | `STORE_KEY` | UK `STORE_ID` |
| Dimension | `PF_CUSTOMER_DIM` | `CUSTOMER_KEY` | UK `CUSTOMER_ID` |
| Dimension | `PF_PRODUCT_DIM` | `PRODUCT_KEY` | UK `PRODUCT_ID` |
| Fact | `PF_TRANSACTION_FACT` | `TRANSACTION_KEY` | UK `(STORE_KEY, SOURCE_TRANSACTION_ID, TRANSACTION_LINE_NO)`; FKs to all four dimensions |

## Design decisions and reasons

- Confirmed STAR rather than SNOWFLAKE: fewer joins, clearer ERD and aggregation, proportionate to the assignment.
- Confirmed one unified transaction fact rather than separate sales/repair facts: both activities share the supported line-level measures; Figure 2 contains no repair-operational fields.
- Confirmed repairs as `PF_PRODUCT_DIM` rows with `PRODUCT_TYPE = 'REPAIR_SERVICE'`; accessories use `ACCESSORY`.
- Confirmed surrogate dimension/fact keys plus unique business identifiers; no sequences, triggers or identity columns.
- Confirmed event-level sales and cost measures so gross profit/loss can be derived.
- Excluded inventory stock quantity from the transaction fact because it has a periodic snapshot grain.
- All confirmed project tables and constraints use the `PF_` prefix and identifiers of at most 30 characters.

## Generated files

- `section_a_requirements.md` - A0 evidence-based requirements audit
- `section_a_design_spec.md` - confirmed and locked A1 specification
- `oracle_section_a_preflight.sql` - read-only preflight that spools evidence
- `createDW.sql` - portable Oracle DDL plus table listing and all `DESC` commands
- `oracle_section_a_execute.sql` - local F5 wrapper that spools the complete DDL run
- `oracle_section_a_validation.sql` - independent data-dictionary and `DESC` validation
- `oracle_section_a_cleanup.sql` - recovery-only cleanup of exactly the five project tables
- `ORACLE_RUNBOOK_SECTION_A.md` - ordered F5 instructions and recovery controls
- `artifacts/section_a/phonefix_dw_erd.drawio` - editable diagrams.net source
- `artifacts/section_a/phonefix_dw_erd.svg` - editable vector export source
- `artifacts/section_a/phonefix_dw_erd.png` - visually inspected 2200 x 1450 export
- `evidence/section_a/static_consistency_check.txt` - local static/visual QA evidence
- `evidence/section_a/db_preflight.txt` - complete read-only preflight output
- `evidence/section_a/createDW_run.txt` - complete Oracle DDL and first `DESC` output
- `evidence/section_a/desc_all_tables.txt` - complete independent dictionary and second `DESC` output
- `evidence/section_a/oracle_verification_summary.md` - final evidence audit
- `PROJECT_STATUS.md` - this shared state file

## Oracle validation commands and evidence

Prepared command file:

- `oracle_section_a_preflight.sql`
- `oracle_section_a_execute.sql`
- `oracle_section_a_validation.sql`

Verified Oracle output:

- `evidence/section_a/db_preflight.txt`
- `evidence/section_a/createDW_run.txt`
- `evidence/section_a/desc_all_tables.txt`

Verified Oracle evidence shows:

- current `USER` is `GWC5419`;
- Oracle Database 19c Enterprise Edition;
- zero current-schema `PF_` tables, views or materialized views before creation;
- effective and direct `CREATE TABLE` and `UNLIMITED TABLESPACE` privileges.
- all five tables explicitly reported as created;
- all five tables present in `USER_TABLES`;
- 50 column definitions returned from `USER_TAB_COLUMNS`;
- 27 explicit named constraints present, including 5 PK, 5 UK, 4 FK and 13 business checks;
- all four FKs enabled, validated and linked to the expected parent columns;
- both complete sets of `DESC` output match the locked specification;
- no `ORA-`, `SP2-`, `PLS-` or `Warning` marker in any of the three logs.

Unresolved Oracle errors: none.

## Verified items

- Published Section A requirements and four A.6 deliverables.
- Figure 2 field names and visually underlined primary keys.
- Two-page maximum for Section A explanation/justification, excluding references.
- Section A does not require inserted records.
- Submission requires `createDW.sql`, report evidence, captions and an AI Use Log.
- The confirmed specification is internally type-compatible and uses Oracle datatypes.
- User approval of the five-table STAR and transaction-line grain.
- ERD, design specification and DDL contain the same five tables and matching columns.
- All four DDL foreign keys are type-compatible with their referenced primary keys.
- All explicit identifiers are at most 30 characters; the longest constraint name is 18 characters.
- The ERD PNG passed visual inspection for legibility, clipping, overlap, grain annotation and 1:N relationships.
- The DDL contains no inserted data and passed the recorded local static checks.
- Oracle preflight completed without an `ORA-`, `SP2-` or `PLS-` error.
- The current schema contained no conflicting `PF_` objects, so the first DDL run is safe to proceed without cleanup.
- The current user has the privileges needed to create the Section A tables.
- Oracle explicitly created all five tables.
- Independent data-dictionary checks confirmed all expected tables, columns and constraints.
- All `DESC` outputs match the design specification, ERD and DDL.
- Full Oracle evidence contains no unhandled error or warning marker.

## Unverified items / external risks

- No Section A technical deliverable remains unverified.
- The Canvas rubric was not provided, so rubric-specific hidden expectations cannot be checked.
- The student must still write the final report explanation in their own words and include an accurate AI Use Log.

## Next actions

1. Preserve the three original Oracle evidence files without editing.
2. Use the ERD image and relevant `DESC` evidence in the report, with appropriate captions.
3. Write the two-page maximum Section A explanation in the student's own words using `section_a_requirements.md` and `section_a_design_spec.md` as technical notes.
4. Include an honest AI Use Log describing design, SQL and proofreading assistance and how the work was verified.
5. Do not run `oracle_section_a_cleanup.sql` unless these project tables genuinely need to be removed for a later full rerun.

## Overall Section B state

- Current stage: B4 complete.
- Overall status: **verified**
- SQL Developer is open and the school connection is reported as active, but
  the running Java window could not be bound reliably to the available UI
  automation interface on 14 October 2026.
- Q1-Q5 outputs, Q6-Q7 MV-based CSV/chart evidence and the clean consolidated
  run are verified. The three chart CSVs were re-extracted from the MV
  recreated by the final run; their hashes were unchanged, and both charts
  were rebuilt and visually rechecked.
- Real preflight confirms Oracle 19c, 918,843 SH sales rows, the complete
  1998-2001 date range, all seven required SH tables, direct `CREATE
  MATERIALIZED VIEW`, no target-name conflict, the exact `NO PROMOTION` value,
  and `YYYY-MM` month descriptions.
- The corrected supplemental run confirms direct `SELECT` grants to `GWC5419`
  on all seven required SH tables. Its 65-line evidence log completed with
  seven rows and no error or warning marker.
- The original log retains one historical `ORA-00904` from using `OWNER`
  rather than `TABLE_SCHEMA` in `ALL_TAB_PRIVS`; the successful corrected run
  resolves that check without altering the original evidence.
- The 709-line `queriesDW_final_run.txt` contains the complete Q1-Q7 run,
  successful MV recreation, FRESH/VALID metadata, the correct six-column
  order, a zero source-to-MV difference and the final completion marker.
- A marker scan finds only the old explanatory comment on line 9 that names
  the strings `ORA-`, `SP2-`, `PLS-` and `Warning`; it is not an Oracle error.
  That comment was removed after review without changing any SQL statement.

## Section B authoritative material audit

- All nine pages of `Data Warehousing Project S2 2026.pdf` were read.
- Assignment pages 5-6 were visually checked for Q1-Q7 wording and displayed
  output column names.
- The single page of `SH_Schema.pdf` was visually checked in full; `COSTS` is
  excluded for this assessment.
- The live Canvas assignment and rubric were checked. The rubric exists and
  confirms 4 marks code/output plus 2 marks writing for Q1-Q5, and 5 marks
  code/chart plus 5 marks writing for Q6-Q7. It adds no contrary SQL condition.

## Section B question status

| Question | Status | Current evidence |
|---|---|---|
| Q1 | **verified** | Real output returned exactly five rows; the formatted values match the rounded raw totals, and the log is error-free. |
| Q2 | **verified** | Seven intended products were used; eight country details reconcile to the ROLLUP subtotal/grand total, and the log is error-free. |
| Q3 | **verified** | All four years returned one independently confirmed maximum product each, with no ties and no log errors. |
| Q4 | **verified** | Five countries qualified; the top-three answer matches the complete all-channel cross-check, and the log is error-free. |
| Q5 | **verified** | MV is FRESH/VALID with 3,629 rows, correct six-column grain and month range, zero duplicate groups, and a zero source-to-MV total difference. |
| Q6 | **verified** | Real MV exports passed field/grain checks; the 1998-2001 Q1 grouped-bar chart passed visual QA and supports a cautious 2002 Q1 recommendation. |
| Q7 | **verified** | The 240-row, 48-month-by-five-category export passed validation; the monthly line chart passed visual QA and supports evidence-based management notes. |

## Section B generated files

- `section_b_requirements_matrix.md`
- `queriesDW.sql` - explicitly marked draft until a clean final Oracle run
- `oracle_preflight.sql`
- `oracle_preflight_direct_grants.sql`
- `oracle_section_b_q1_validation.sql` through `oracle_section_b_q5_validation.sql`
- `oracle_section_b_chart_extract.sql`
- `oracle_section_b_final_validation.sql`
- `ORACLE_RUNBOOK_SECTION_B.md`
- `q4_interpretation_note.md`
- `artifacts/section_b/build_charts.py`
- `artifacts/section_b/chart_notes.md`
- `artifacts/section_b/data/README.md`
- `artifacts/section_b/data/q6_q1_promo_sales.csv`
- `artifacts/section_b/data/q6_full_period_promo_sales.csv`
- `artifacts/section_b/data/q7_monthly_product_category_sales.csv`
- `artifacts/section_b/data/chart_data_manifest.json`
- `artifacts/section_b/charts/README.md`
- `artifacts/section_b/charts/q6_historical_q1_promotion_sales.svg`
- `artifacts/section_b/charts/q6_historical_q1_promotion_sales.png`
- `artifacts/section_b/charts/q7_monthly_product_category_sales.svg`
- `artifacts/section_b/charts/q7_monthly_product_category_sales.png`
- `evidence/section_b/conclusion_evidence_bullets.md`
- `evidence/section_b/canvas_rubric_audit.md`
- `evidence/section_b/static_check.txt`
- `evidence/section_b/queriesDW_final_run.txt`
- `evidence/section_b/final_oracle_verification_summary.md`

## Section B next action

No further Oracle execution is required for the verified Section B workflow.
Preserve the original logs, CSVs, manifest and charts. Use the evidence bullets
to write the report conclusions in the student's own words, add figure/table
captions, and include an accurate AI Use Log before submission.
