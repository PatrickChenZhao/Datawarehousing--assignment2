# Section A Requirements Audit

Audit date: 14 October 2026  
Scope: COMP810 Data Warehousing Project 2026, Section A only  
Status: A0 complete and Oracle preflight verified

## 1. Authority and evidence reviewed

Priority used for this audit:

1. `Data Warehousing Project S2 2026.pdf`
2. Canvas rubric, if supplied
3. Real Oracle output
4. Working files
5. Explicitly labelled modelling assumptions

Evidence reviewed:

- All nine pages of `Data Warehousing Project S2 2026.pdf` were read.
- Pages 3 and 4 were rendered and visually inspected. This confirmed the three Figure 2 source tables, their displayed columns, and the underlined primary keys.
- `SH_Schema.pdf` was rendered and visually inspected. It describes the Oracle SH sample schema for Section B and is not a PhoneFix Section A source.
- Existing working file `CODEX_PROMPTS.md` was inspected. It restates the work instructions but contains no competing Section A design or Oracle evidence.
- No Canvas rubric file is present in the working directory. **Rubric not provided.** Hidden criteria have not been inferred.

No conflict was found between the assignment PDF and existing working files. The assignment PDF remains authoritative.

## 2. Authoritative Section A requirements

- Design a logical PhoneFix data warehouse schema.
- Choose either a STAR or SNOWFLAKE schema.
- Explain deficiencies in the current design.
- Justify the schema choice and the composition of fact and dimension tables.
- Explain advantages of the proposed design over the current design.
- Support aggregation for business activities, including products sold and sales value by time, product and client/customer.
- Draw the schema with data-modelling software and ensure all required ERD elements are clear.
- Create the proposed tables in Oracle.
- Do not insert records for Section A.
- Submit SQL code and `DESC` output for every created table.

Section A is worth 42 marks. The explanation and justification must be concise and no more than two pages, excluding references.

## 3. PhoneFix business context and intended analysis

Facts stated by the assignment:

- PhoneFix sells mobile-phone accessories and repairs mobile phones.
- It has more than ten Auckland stores.
- Each store is independently run by a different owner.
- Owners currently choose their own data-storage methods.
- At each quarter end, owners send Excel files containing income/loss, transactions and inventories to headquarters.
- Headquarters wants to compare store performance and analyse customer behaviour.
- The assignment specifically suggests totals such as products sold and sales value, aggregated by time, product and client/customer.

Analysis the logical model should directly support:

- quantity sold and sales value by date, month, quarter and year;
- sales and cost by product, product category and product type;
- comparison of stores;
- customer purchasing behaviour by customer, geography, income range and occupation;
- accessory sales versus repair-service revenue;
- derived gross profit/loss as aggregated sales amount minus aggregated cost amount.

## 4. Figure 2 source fields

The primary keys below are the fields visually shown as underlined in Figure 2.

### Transaction

- `TRANSACTION_ID` - displayed primary key
- `PRODUCT_ID`
- `CLIENT_ID`
- `CLIENT_NAME`
- `DATE`
- `QUANTITY`
- `PRICE`

### Client

- `CLIENT_ID` - displayed primary key
- `CLIENT_NAME`
- `ADDRESS`
- `DATE_OF_BIRTH`
- `INCOME_RANGE`
- `OCCUPATION`

### Inventory

- `PRODUCT_ID` - displayed primary key
- `SUPPLIER_ID`
- `SUPPLIER_NAME`
- `COST`
- `QUANTITY`
- `PRICE`

## 5. Deficiencies in the current design

Directly evidenced or strongly implied by the case:

- Independent store owners can use inconsistent structures, identifiers, formats and definitions.
- Quarterly Excel delivery makes reporting delayed rather than current.
- Joining separate store files creates duplicate, missing and inconsistent-record risks.
- Store context is absent from the three example tables, so the same identifiers from different stores may collide after integration.
- `CLIENT_NAME` is duplicated in `Transaction` and `Client`, which creates update inconsistency and unnecessary redundancy.
- `Inventory` mixes product, supplier, price, cost and stock quantity in one operational table.
- The transaction field named `DATE` has no reusable calendar hierarchy for month, quarter or year analysis.
- The current tables are operational structures, not a fact-and-dimension model optimised for consistent aggregation.

Reasonable modelling risks that require an explicit assumption:

- Store-local `TRANSACTION_ID`, `PRODUCT_ID` and `CLIENT_ID` values may not be globally unique.
- Current price, cost and inventory values may overwrite history.
- Figure 2 contains no explicit repair-specific fields even though repair is a stated business activity.
- Inventory quantity is a point-in-time stock measure and therefore has a different grain from transaction-line quantity.
- The quarterly income/loss files have a summary grain different from individual transaction lines.

## 6. Reasonable additions and why they are needed

The assignment permits attributes beyond Figure 2. The proposed additions remain limited to analytical needs:

- Store identifiers and descriptive attributes: required to compare independently operated stores.
- Calendar attributes: required for day/month/quarter/year aggregation.
- Product name, category, brand, model and type: required for meaningful product analysis and to distinguish `ACCESSORY` from `REPAIR_SERVICE`.
- A warehouse transaction-line surrogate key and line number: permits multi-line transactions and prevents dependence on store-local identifiers.
- Standardised product and customer business identifiers: ETL can resolve store-local identifier collisions; the assignment says ETL may be assumed manageable.
- Transaction-time unit cost and additive sales/cost amounts: preserves the event values needed for revenue and gross-profit analysis.
- Store/source transaction/line uniqueness: prevents duplicate loading without assuming transaction IDs are unique across all stores.

The following are deliberately not added to the initial model:

- repair technician, fault, device serial number and turnaround measures, because Figure 2 provides no such source data;
- a periodic inventory snapshot fact, because its grain differs from a transaction line and the stated examples emphasise products sold and sales value;
- sequences, triggers, identity columns, SCD implementation or ETL code, because Section A only requires empty table definitions.

## 7. A.6 deliverables

Section A requires all four of the following:

1. concise explanations and justifications of the design, no more than two pages excluding references;
2. a diagram representing the logical data warehouse schema;
3. Oracle SQL code that creates the tables;
4. descriptions produced with `DESC` for every table created.

## 8. Submission and academic-integrity controls

- The overall submission must contain a professional Word/PDF report for Sections A and B.
- A separate script named `createDW.sql` is required for Section A.
- Figures and tables need captions and must be referenced in the student's own report text.
- An honest AI Use Log is mandatory in the appendix, even if no AI was used.
- AI may support ideas, explanations, troubleshooting and proofreading, but generated report paragraphs must not be copied directly.
- The student must write the final Section A narrative in their own words, verify claims, and record how AI assistance was checked or revised.

## 9. Cross-artifact consistency gate

Before Section A can be marked complete:

- every table in the design specification must appear in the ERD and DDL;
- every column name and datatype must match between the design specification and DDL;
- all ERD relationships must match actual foreign keys;
- every foreign key must reference an existing type-compatible primary/unique key;
- Oracle `DESC` output must match the created tables;
- data-dictionary output must confirm tables, columns and constraints independently of `DESC`;
- no real Oracle execution result may be claimed until complete Script Output exists and is checked for `ORA-`, `SP2-`, `PLS-` and `Warning` messages.

## 10. External evidence result

- Canvas rubric: not provided; this remains an external marking risk.
- The read-only Oracle preflight was completed on 14 October 2026.
- Verified user: `GWC5419`.
- Verified database: Oracle Database 19c Enterprise Edition.
- Verified pre-create `PF_` object count: 0.
- Verified effective relevant privileges: `CREATE TABLE` and `UNLIMITED TABLESPACE`.
- Full evidence is stored in `evidence/section_a/db_preflight.txt`.
