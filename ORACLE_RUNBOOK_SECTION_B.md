# Oracle Runbook - Section B

Current state: B0 preflight, Q1-Q7, the B4 clean final run and the post-run
chart synchronization are verified. No further Oracle execution is required
unless the submitted SQL is intentionally changed.

The SQL Developer process is open, but its Java window could not be bound
reliably to the available automation interface on 14 October 2026. No Section B
query has therefore been represented as executed or verified.

Use the existing school Oracle connection. Do not disclose, copy or type the
password into chat.

## B0 read-only preflight

1. Open `oracle_preflight.sql` in the worksheet attached to the existing school
   connection.
2. Press **F5 / Run Script** once. Do not use Run Statement on selected text.
3. Wait for `===== PREFLIGHT COMPLETE =====`.
4. Confirm this file exists:

   `evidence/section_b/preflight_output.txt`

5. If `SPOOL` cannot write the file, use SQL Developer's Save button in Script
   Output and save the complete output under that exact name.
6. Search the saved output for `ORA-`, `SP2-`, `PLS-` and `Warning`.
7. Stop before Q1-Q5 if any required SH object/column is missing, `sh.sales`
   cannot be read, or the output is incomplete.
8. Confirm the CD-R/CD-RW discovery shows the canonical `Recordable CDs`
   subcategory. The reviewed preflight showed seven intended products and six
   false-matched CD-ROM drives; the final Q2 filter now uses the subcategory.
9. Record the Oracle version, month format, actual no-promotion label and
   current-schema `PROMOTION_ANALYSIS_MV` state in the requirements matrix.

The preflight is read-only. It does not create, drop or change an object.

The first real preflight run on 14 October 2026 completed but its
`ALL_TAB_PRIVS` query used the unsupported column `OWNER`. The corrected
supplemental file `oracle_preflight_direct_grants.sql` was then run with F5.
Its retained output, `evidence/section_b/preflight_direct_grants_output.txt`,
confirms direct `SELECT` grants on all seven required SH tables and contains no
error or warning marker. B0 is complete.

## B1 Q1-Q4 answer and cross-check runs

Run these files one at a time, in order, with F5:

1. `oracle_section_b_q1_validation.sql`
2. `oracle_section_b_q2_validation.sql`
3. `oracle_section_b_q3_validation.sql`
4. `oracle_section_b_q4_validation.sql`

Each script writes one complete evidence file:

- `evidence/section_b/q1_output.txt`
- `evidence/section_b/q2_output.txt`
- `evidence/section_b/q3_output.txt`
- `evidence/section_b/q4_output.txt`

After every run:

1. Wait for the question-specific `VALIDATION COMPLETE` marker.
2. Search the saved text for `ORA-`, `SP2-`, `PLS-` and `Warning`.
3. Confirm the answer and independent cross-check agree before proceeding.
4. Keep the complete output. A cropped screenshot may supplement it but must
   not replace it.

Special checks:

- Q1 must return five rows and the formatted values must match the rounded raw
  values.
- Q2's ROLLUP detail total must agree with the ordinary-grouping grand total.
- Q3 must cover 1998, 1999, 2000 and 2001; tied maxima are valid extra rows.
- Q4's top three must match the first three rows of the all-channel cross-check,
  and the eligible-country list must reflect country-level 1999 sales.

## B2 Q5 materialized view

Only proceed after the preflight shows:

- no unrelated object owns the name `PROMOTION_ANALYSIS_MV`; and
- the current session has `CREATE MATERIALIZED VIEW`.

Then open `oracle_section_b_q5_validation.sql` and press F5 once. It may drop
only the current user's existing materialized view of the exact required name.
It writes:

`evidence/section_b/q5_output.txt`

Confirm all of the following:

- Oracle explicitly creates the materialized view;
- the six column names and order match the assignment;
- month coverage is 1998-2001;
- the duplicate-grain query returns zero rows;
- the source total and MV total are equal, with a zero difference;
- the first ten rows are sorted by month ascending and sales descending;
- no unhandled error or warning marker appears.

If Oracle reports an error, preserve the complete output. In particular, do
not replace the materialized view with an ordinary view. A privilege failure
blocks Q5-Q7 until the tutor or DBA grants the required capability.

## B3 Q6/Q7 CSV and charts

Only after Q5 is verified:

1. Open `oracle_section_b_chart_extract.sql` and press F5 once.
2. Confirm the three real CSV files appear in
   `artifacts/section_b/data/`.
3. Open the CSVs as plain text and verify the header, non-zero data-row count,
   chronological periods and absence of SQL error text.
4. From the project root run:

   ```bash
   /Users/chen/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3 artifacts/section_b/build_charts.py
   ```

5. Inspect the two PNGs visually at normal size and confirm there is no
   clipping, overlap or unreadable legend.
6. Check `artifacts/section_b/data/chart_data_manifest.json` for the recorded
   input hashes, fields, row counts and period coverage.
7. Use the verified outputs to replace the pending lines in
   `evidence/section_b/conclusion_evidence_bullets.md` with concise English
   evidence bullets. Do not turn those bullets into a submission paragraph.

## B4 clean final run

After Q1-Q7 have passed their individual checks:

1. Remove the draft warning from `queriesDW.sql` only after its Q2 predicate
   and Q6/Q7 chart choices have been confirmed from real data.
2. Open `oracle_section_b_final_validation.sql` and press F5 once.
3. Wait for `===== FINAL RUN COMPLETE =====`.
4. Confirm this complete log exists:

   `evidence/section_b/queriesDW_final_run.txt`

5. Search the entire file for `ORA-`, `SP2-`, `PLS-` and `Warning`. Every match
   must be resolved or explicitly explained; do not infer success merely from
   a displayed result table.
6. Re-run the CSV extraction if the clean final run recreated the materialized
   view, then confirm that the hashes and charts correspond to the final MV.
7. Update `PROJECT_STATUS.md` and the matrix from `awaiting Oracle` to
   `verified` only for questions supported by complete evidence.

Completion record: the 709-line final log passed review. The chart extraction
was rerun from the recreated MV, all three SHA-256 hashes matched the earlier
verified exports, and both 1600 x 900 PNGs passed repeat visual inspection.

## Files to return for evidence review

Return or keep available these files after each stage:

- `evidence/section_b/preflight_output.txt`
- `evidence/section_b/preflight_direct_grants_output.txt`
- `evidence/section_b/q1_output.txt` through `q5_output.txt`
- `evidence/section_b/queriesDW_final_run.txt`
- all three CSV exports
- `chart_data_manifest.json`
- both final PNG charts

Do not send a password, connection string or cropped-only database evidence.
