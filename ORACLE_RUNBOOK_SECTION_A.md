# Oracle Runbook - Section A

Status: completed and verified on 14 October 2026.

Verified evidence files:

- `evidence/section_a/db_preflight.txt`
- `evidence/section_a/createDW_run.txt`
- `evidence/section_a/desc_all_tables.txt`
- `evidence/section_a/oracle_verification_summary.md`

All three Oracle outputs completed without `ORA-`, `SP2-`, `PLS-` or `Warning` markers. The sections below are retained as a reproducible runbook.

## A0 read-only preflight

1. Keep the existing school Oracle connection open in SQL Developer. Do not disclose or copy the password.
2. Open `oracle_section_a_preflight.sql` from this project directory.
3. Confirm the worksheet is attached to the intended existing connection.
4. Press **F5 / Run Script** once to run the complete file. Do not use Run Statement on selected fragments.
5. Wait for the `===== PREFLIGHT COMPLETE =====` message.
6. Confirm that the following file now exists:

   `evidence/section_a/db_preflight.txt`

7. Save the full Script Output separately if SQL Developer reports that `SPOOL` could not write the file.
8. Do not run any `DROP`, `CREATE`, `ALTER`, `TRUNCATE`, `INSERT`, `UPDATE` or `DELETE` statement during this preflight.

The preflight records only:

- current Oracle `USER`;
- Oracle version;
- existing current-schema tables, views and materialized views whose names begin with `PF_`;
- effective and directly granted system privileges relevant to creating tables.

If `PF_` objects are listed, stop before any later DDL is run. Their exact names must be compared with the confirmed design so that unrelated objects are not overwritten.

## A3/A4 creation and validation

Only continue after `evidence/section_a/db_preflight.txt` has been read and any listed `PF_` objects have been resolved.

### Clean first execution

1. Open `oracle_section_a_execute.sql` in the same connected worksheet.
2. Press **F5 / Run Script** once. This runs the complete `createDW.sql` and writes the complete output to:

   `evidence/section_a/createDW_run.txt`

3. Do not run individual highlighted statements as a substitute for the complete script.
4. Search the saved output for `ORA-`, `SP2-`, `PLS-` and `Warning`. Any unexplained match means the run is not verified.
5. Confirm that the output lists exactly the five expected tables and contains `DESC` output for each.
6. Open `oracle_section_a_validation.sql` and press **F5 / Run Script** once. It writes independent data-dictionary and `DESC` evidence to:

   `evidence/section_a/desc_all_tables.txt`

7. Return both complete evidence files for checking. Screenshots may supplement but must not replace them.

### Recovery after a partial or failed run

`oracle_section_a_cleanup.sql` drops exactly the five confirmed project tables, fact first and then dimensions. Run it only if:

- the preflight has been reviewed;
- every same-named object is confirmed to belong to this PhoneFix project; and
- a complete rerun is required after a partial/failed attempt.

After cleanup, rerun the whole `oracle_section_a_execute.sql`, then rerun the whole `oracle_section_a_validation.sql`. Do not validate a mixture of old and newly created tables.
