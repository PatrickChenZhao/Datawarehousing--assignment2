# PhoneFix Section A Design Specification

Version: A1 confirmed design, 14 October 2026  
Decision status: **confirmed by the user on 14 October 2026**  
This is the locked specification for the Section A ERD and DDL.

## 1. STAR versus SNOWFLAKE

| Criterion | STAR | SNOWFLAKE |
|---|---|---|
| Structure | One central fact linked directly to denormalised dimensions | Dimensions are further normalised into related subdimensions |
| Query clarity | Fewer joins and simpler aggregation queries | More joins and a more complex diagram/query path |
| Redundancy | Some controlled repetition in descriptive attributes | Less descriptive redundancy |
| Fit for PhoneFix | Strong fit for a small, explainable warehouse and the assignment's aggregation examples | Useful if large reusable hierarchies require independent governance, which is not evidenced here |

**Recommendation: STAR.** It gives PhoneFix a clear centre for transaction-line measures, makes store/customer/product/time aggregation easy to explain, and keeps the Oracle implementation proportionate to the assessment. Supplier details remain denormalised in the product dimension rather than creating a supplier snowflake branch.

## 2. One transaction fact versus separate sales and repair facts

| Option | Benefit | Cost/risk |
|---|---|---|
| Unified transaction-line fact | Sales and repair-service revenue share the same date, store, customer, item, quantity, price and cost structure; cross-business totals are simple | Cannot hold repair-specific facts such as technician, fault or turnaround time |
| Separate sales and repair facts | Can model repair jobs at a specialised repair grain | Figure 2 supplies no repair-job fields; it would require substantially more assumed attributes and duplicate shared measures/dimensions |

**Recommendation: one unified transaction-line fact.** Repair services are represented as product-dimension rows with `PRODUCT_TYPE = 'REPAIR_SERVICE'`; accessories use `PRODUCT_TYPE = 'ACCESSORY'`. This preserves one clear grain and avoids inventing an unsupported repair process. A specialised repair fact can be added later if PhoneFix begins collecting repair-operational data.

## 3. Declared fact grain

One row in `PF_TRANSACTION_FACT` represents **one accessory sale line or one repair-service line, for one product/service, one customer, one store and one calendar date, within one source transaction**.

`SOURCE_TRANSACTION_ID` is retained as a degenerate transaction identifier. `TRANSACTION_LINE_NO` allows future multi-line transactions even though Figure 2 shows `TRANSACTION_ID` as the source primary key. The proposed alternate key `(STORE_KEY, SOURCE_TRANSACTION_ID, TRANSACTION_LINE_NO)` prevents collisions between independently operated stores.

## 4. Proposed logical STAR

- Fact: `PF_TRANSACTION_FACT`
- Dimensions: `PF_DATE_DIM`, `PF_STORE_DIM`, `PF_CUSTOMER_DIM`, `PF_PRODUCT_DIM`
- Direct relationships: each dimension has a one-to-many relationship to `PF_TRANSACTION_FACT`
- All table and constraint identifiers are 30 characters or fewer.

## 5. Column-level specification

### 5.1 `PF_DATE_DIM`

Purpose: consistent calendar filtering and aggregation without relying on session-specific date formatting.

| Column | Oracle datatype | Nullable | Key/constraint | Meaning |
|---|---|---:|---|---|
| `DATE_KEY` | `NUMBER(8)` | No | PK `PF_DATE_PK` | Surrogate date key, conventionally `YYYYMMDD` |
| `FULL_DATE` | `DATE` | No | UK `PF_DATE_FULL_UK` | Actual calendar date |
| `DAY_OF_MONTH` | `NUMBER(2)` | No | CK `PF_DATE_DAY_CK`: 1-31 | Calendar day number |
| `DAY_NAME` | `VARCHAR2(9)` | No | - | English day name loaded by ETL |
| `WEEK_OF_YEAR` | `NUMBER(2)` | No | CK `PF_DATE_WEEK_CK`: 1-53 | Agreed warehouse week number |
| `MONTH_NUMBER` | `NUMBER(2)` | No | CK `PF_DATE_MONTH_CK`: 1-12 | Calendar month number |
| `MONTH_NAME` | `VARCHAR2(9)` | No | - | English month name loaded by ETL |
| `QUARTER_NUMBER` | `NUMBER(1)` | No | CK `PF_DATE_QTR_CK`: 1-4 | Calendar quarter number |
| `CALENDAR_YEAR` | `NUMBER(4)` | No | - | Calendar year |
| `WEEKEND_FLAG` | `CHAR(1)` | No | CK `PF_DATE_WEND_CK`: `Y`/`N` | Weekend indicator |

### 5.2 `PF_STORE_DIM`

Purpose: compare stores and retain store/owner/location context absent from Figure 2.

| Column | Oracle datatype | Nullable | Key/constraint | Meaning |
|---|---|---:|---|---|
| `STORE_KEY` | `NUMBER(10)` | No | PK `PF_STORE_PK` | Warehouse surrogate key |
| `STORE_ID` | `VARCHAR2(20)` | No | UK `PF_STORE_ID_UK` | Stable PhoneFix store business identifier |
| `STORE_NAME` | `VARCHAR2(100)` | No | - | Store display name |
| `OWNER_NAME` | `VARCHAR2(100)` | No | - | Independent owner name |
| `ADDRESS_LINE` | `VARCHAR2(200)` | Yes | - | Street/address text |
| `SUBURB` | `VARCHAR2(80)` | Yes | - | Auckland suburb |
| `CITY` | `VARCHAR2(80)` | No | - | City, expected to be Auckland for current stores |
| `POSTCODE` | `VARCHAR2(10)` | Yes | - | Postal code retained as text |
| `OPEN_DATE` | `DATE` | Yes | - | Store opening date if available |
| `STORE_STATUS` | `VARCHAR2(10)` | No | CK `PF_STORE_STATUS_CK`: `ACTIVE`/`INACTIVE` | Current operating status |

### 5.3 `PF_CUSTOMER_DIM`

Purpose: analyse customer behaviour and demographic/geographic groupings.

| Column | Oracle datatype | Nullable | Key/constraint | Meaning |
|---|---|---:|---|---|
| `CUSTOMER_KEY` | `NUMBER(10)` | No | PK `PF_CUSTOMER_PK` | Warehouse surrogate key |
| `CUSTOMER_ID` | `VARCHAR2(30)` | No | UK `PF_CUSTOMER_ID_UK` | Standardised customer business identifier |
| `CUSTOMER_NAME` | `VARCHAR2(120)` | No | - | Source `CLIENT_NAME`, standardised by ETL |
| `ADDRESS_LINE` | `VARCHAR2(200)` | Yes | - | Source customer address |
| `SUBURB` | `VARCHAR2(80)` | Yes | - | Derived/standardised address component |
| `CITY` | `VARCHAR2(80)` | Yes | - | Derived/standardised address component |
| `DATE_OF_BIRTH` | `DATE` | Yes | - | Source date of birth |
| `INCOME_RANGE` | `VARCHAR2(40)` | Yes | - | Source income band |
| `OCCUPATION` | `VARCHAR2(100)` | Yes | - | Source occupation |

`CUSTOMER_ID` is a head-office-standardised business identifier. Where store-local client IDs collide, ETL must resolve them using the source store plus local client ID before assigning `CUSTOMER_KEY`. The assignment explicitly allows ETL to be assumed manageable.

### 5.4 `PF_PRODUCT_DIM`

Purpose: describe the accessory or repair service being transacted and retain supplier context from `Inventory`.

| Column | Oracle datatype | Nullable | Key/constraint | Meaning |
|---|---|---:|---|---|
| `PRODUCT_KEY` | `NUMBER(10)` | No | PK `PF_PRODUCT_PK` | Warehouse surrogate key |
| `PRODUCT_ID` | `VARCHAR2(30)` | No | UK `PF_PRODUCT_ID_UK` | Standardised product/service business identifier |
| `PRODUCT_NAME` | `VARCHAR2(120)` | No | - | Human-readable product or repair-service name |
| `PRODUCT_TYPE` | `VARCHAR2(20)` | No | CK `PF_PRODUCT_TYPE_CK`: `ACCESSORY`/`REPAIR_SERVICE` | Distinguishes the two stated PhoneFix activities |
| `CATEGORY_NAME` | `VARCHAR2(80)` | No | - | Product/service category |
| `BRAND_NAME` | `VARCHAR2(80)` | Yes | - | Brand when applicable |
| `MODEL_NAME` | `VARCHAR2(80)` | Yes | - | Product or compatible phone model when applicable |
| `SUPPLIER_ID` | `VARCHAR2(30)` | Yes | - | Source supplier identifier |
| `SUPPLIER_NAME` | `VARCHAR2(120)` | Yes | - | Source supplier name, denormalised for the STAR |

`PRODUCT_ID` is standardised across stores during ETL. Store-local IDs remain source-system values and are not assumed globally unique.

### 5.5 `PF_TRANSACTION_FACT`

Purpose: store additive measures for accessory and repair-service transaction lines.

| Column | Oracle datatype | Nullable | Key/constraint | Meaning |
|---|---|---:|---|---|
| `TRANSACTION_KEY` | `NUMBER(12)` | No | PK `PF_TXN_PK` | Warehouse surrogate key |
| `SOURCE_TRANSACTION_ID` | `VARCHAR2(30)` | No | Part of UK `PF_TXN_SRC_LINE_UK` | Transaction identifier supplied by the store |
| `TRANSACTION_LINE_NO` | `NUMBER(4)` | No | UK; CK `PF_TXN_LINE_CK`: > 0 | Line number within the source transaction |
| `DATE_KEY` | `NUMBER(8)` | No | FK `PF_TXN_DATE_FK` -> `PF_DATE_DIM.DATE_KEY` | Transaction date |
| `STORE_KEY` | `NUMBER(10)` | No | FK `PF_TXN_STORE_FK` -> `PF_STORE_DIM.STORE_KEY`; part of UK | Store performing the transaction |
| `CUSTOMER_KEY` | `NUMBER(10)` | No | FK `PF_TXN_CUST_FK` -> `PF_CUSTOMER_DIM.CUSTOMER_KEY` | Customer involved |
| `PRODUCT_KEY` | `NUMBER(10)` | No | FK `PF_TXN_PRODUCT_FK` -> `PF_PRODUCT_DIM.PRODUCT_KEY` | Accessory or repair-service item |
| `QUANTITY` | `NUMBER(10)` | No | CK `PF_TXN_QTY_CK`: > 0 | Units sold or repair-service count |
| `UNIT_SELLING_PRICE` | `NUMBER(12,2)` | No | CK `PF_TXN_UPRICE_CK`: >= 0 | Selling price per unit at the event time |
| `UNIT_COST` | `NUMBER(12,2)` | No | CK `PF_TXN_UCOST_CK`: >= 0 | Unit cost at the event time |
| `SALES_AMOUNT` | `NUMBER(14,2)` | No | CK `PF_TXN_SALES_CK`: >= 0 | Loaded line revenue, normally `QUANTITY * UNIT_SELLING_PRICE` |
| `COST_AMOUNT` | `NUMBER(14,2)` | No | CK `PF_TXN_COST_CK`: >= 0 | Loaded line cost, normally `QUANTITY * UNIT_COST` |

The alternate key is `(STORE_KEY, SOURCE_TRANSACTION_ID, TRANSACTION_LINE_NO)`. No sequence, trigger or identity clause is proposed; the later ETL process would supply surrogate-key values.

## 6. Measures and additivity

| Measure | Additivity | Correct use |
|---|---|---|
| `QUANTITY` | Fully additive | Sum across dates, stores, customers and products |
| `SALES_AMOUNT` | Fully additive | Sum for revenue totals at any supported aggregation level |
| `COST_AMOUNT` | Fully additive | Sum for cost totals at any supported aggregation level |
| `UNIT_SELLING_PRICE` | Non-additive | Use a weighted average or inspect at line level; do not sum |
| `UNIT_COST` | Non-additive | Use a weighted average or inspect at line level; do not sum |
| Gross profit/loss | Derived additive measure | `SUM(SALES_AMOUNT) - SUM(COST_AMOUNT)`; not redundantly stored |

## 7. Source-to-target interpretation

| Figure 2/source concept | Proposed target treatment |
|---|---|
| `Transaction.TRANSACTION_ID` | `PF_TRANSACTION_FACT.SOURCE_TRANSACTION_ID` |
| `Transaction.DATE` | Look up `PF_DATE_DIM.DATE_KEY` |
| `Transaction.QUANTITY` | `PF_TRANSACTION_FACT.QUANTITY` |
| `Transaction.PRICE` | `PF_TRANSACTION_FACT.UNIT_SELLING_PRICE` |
| `Transaction.CLIENT_ID` | Standardise and look up `PF_CUSTOMER_DIM.CUSTOMER_KEY` |
| `Transaction.PRODUCT_ID` | Standardise and look up `PF_PRODUCT_DIM.PRODUCT_KEY` |
| `Client` descriptive fields | `PF_CUSTOMER_DIM` |
| `Inventory.SUPPLIER_ID/NAME` | Denormalised attributes in `PF_PRODUCT_DIM` |
| `Inventory.COST` | Transaction-time `UNIT_COST`, with `COST_AMOUNT` calculated during ETL |
| `Inventory.PRICE` | Validation/reference for transaction selling price, not a current-price dimension attribute |
| `Inventory.QUANTITY` | Not mixed into this fact; it would require a later periodic inventory snapshot fact |
| Store file/source context | `PF_STORE_DIM` and `PF_TRANSACTION_FACT.STORE_KEY` |
| Quarterly income/loss | Derived from transaction facts where detail is available; not mixed into a different-grain fact |

## 8. Supported aggregation paths

- Time: `FULL_DATE`, `MONTH_NUMBER`, `QUARTER_NUMBER`, `CALENDAR_YEAR`.
- Product: product/service, type, category, brand and model.
- Customer: customer, location, income range and occupation.
- Store: store, owner and location.
- Combined examples: monthly sales by store, annual accessory quantity by category, repair-service revenue by store, and customer spending by income range.

## 9. Advantages over the current design

- One declared fact grain prevents transaction, inventory snapshot and quarterly summary measures from being mixed.
- Conformed dimensions give every store the same analytical definitions.
- Surrogate keys isolate the warehouse from store-local identifiers and future source changes.
- The store dimension makes store comparison explicit.
- The date dimension gives reusable calendar hierarchies.
- Customer descriptions are stored once rather than repeated in every transaction.
- Transaction-time price and cost preserve event-level economics for revenue and profit analysis.
- Denormalised dimensions keep aggregation queries and the ERD easy to understand.

## 10. Limitations and possible marking risks

- The Canvas rubric is not available, so rubric-specific expectations cannot yet be checked.
- Repairs are represented as service products. This is intentionally simple but does not support technician, fault, device or turnaround analysis.
- Inventory stock quantity is excluded because it has a snapshot grain. A marker expecting inventory-level analysis may want a second periodic snapshot fact, although the assignment's explicit examples focus on sales.
- Customer and product natural identifiers require ETL standardisation across stores; that process is assumed rather than implemented, as permitted by A.2.2.
- Returns, discounts, tax and payment methods are not shown in Figure 2 and are outside this initial scope.
- The proposed checks do not enforce `SALES_AMOUNT = QUANTITY * UNIT_SELLING_PRICE` or `COST_AMOUNT = QUANTITY * UNIT_COST`; ETL must validate these calculations and any future discount rules.
- The design has not yet been checked against real current-schema `PF_` object names because the read-only Oracle preflight is pending.

## 11. Confirmation record

The user confirmed the recommended five-table STAR on 14 October 2026:

- one unified transaction-line fact;
- four dimensions for date, store, customer and product;
- repair services represented as `PF_PRODUCT_DIM` rows with `PRODUCT_TYPE = 'REPAIR_SERVICE'`;
- no periodic inventory snapshot fact in the initial Section A scope.
