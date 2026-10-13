# COMP810 Data Warehousing Project - Final Codex Prompts

Version: 2.0 - 14 October 2026

## 使用方式

按顺序建立三个独立 Codex 对话，并确保三个对话都打开同一个工作目录：

`/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment`

1. 保持已连接的 Oracle SQL Developer 打开，不要把密码发给 Codex。
2. 在对话 A 中粘贴“Prompt A”，完成 Section A 和 `createDW.sql`。Codex 应优先使用当前连接执行验证；若无法控制 SQL Developer，再让你代为按 F5 运行。
3. 在对话 B 中粘贴“Prompt B”，完成 Section B、`queriesDW.sql`、Q6/Q7 图表和证据，并优先使用当前连接逐题验证。
4. 在对话 C 中粘贴“Prompt C”，生成报告框架；由学生完成自己的分析文字后，再让同一对话进行校对、排版和最终 QA。

不要同时运行 A 和 B。B 可以与 A 的业务设计相互独立，但顺序执行更容易维护状态，也能避免文件互相覆盖。

---

## Prompt A - Section A 设计、ERD 与 createDW.sql

```text
你正在协助我完成 AUT COMP810 Data Warehousing and Big Data 的 Data Warehousing Project 2026 Section A。请在当前工作目录内持续工作，但必须遵守下面的证据、学术诚信和验证规则。

工作目录：
/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment

首要目标：
为 PhoneFix 设计一个合理、容易解释且适合本作业评分范围的数据仓库逻辑模型，制作清楚的 ERD，并生成可在 Oracle 中执行的 createDW.sql。最终结果必须由真实 Oracle 执行结果和 DESC 输出验证；如果你无法直接访问数据库，不得声称已经验证。

当前已知环境：

- 学校 Oracle 数据库已经在 Oracle SQL Developer 中连接成功并保持打开。
- 优先尝试使用当前已连接会话进行只读预检和后续验证，不要要求我提供或显示密码。
- 如果 Java/SQL Developer 界面无法被可靠控制，不要反复猜测点击；生成精确的运行脚本，告诉我用 F5/Run Script 执行，并读取我保存的完整 Script Output。

一、必须首先读取的权威材料

1. 完整阅读 Data Warehousing Project S2 2026.pdf，重点核对 A.1-A.6、Submission Requirements 和 GAI rules。
2. 视觉检查 PDF 第 3-4 页的源表图和要求，不要只依赖文字提取。
3. 阅读 SH_Schema.pdf 仅作 Section B 背景，不要把 SH 表误用为 PhoneFix Section A 的源表。
4. 检查工作目录中的现有文件。现有草稿不是权威答案，不要因文件已存在就默认其正确。
5. 如果目录中存在 Canvas rubric，则将它纳入核对；如果没有，明确记录“rubric 未提供”，不要猜测 rubric 的隐藏评分项。

资料优先级：作业 PDF > Canvas rubric（如果存在）> Oracle 真实输出 > 工作文件 > 模型推断。

二、不可违反的边界

- Section A 可以选择 STAR 或 SNOWFLAKE。优先考虑结构清楚、SQL 易实现、业务理由充分的 STAR schema；但必须先做简短比较，再根据 PhoneFix 需求作出决定。
- 不要求向 Section A 表中插入记录，所以 createDW.sql 不得包含虚构 INSERT 数据。
- 不得编造 Oracle 执行成功、DESC 输出或截图。
- 不得修改或删除两个原始 PDF。
- 只能删除/重建本项目明确创建的对象，绝不能对 SH schema 或未知对象执行 DROP、TRUNCATE、DELETE。
- 不得为了显得复杂而无依据地增加大量事实表、维度表或 SCD/ETL 实现。设计复杂度要与作业要求匹配。
- 为避免与账户中的其他作业对象冲突，PhoneFix 表和相关约束默认使用一致、简短的 `PF_` 前缀；Oracle identifier 尽量控制在 30 个字符以内，以兼容较旧版本。若要采用其他命名，必须在设计确认点说明理由。
- 因为本作业不插入数据，不要无必要地引入 sequences、triggers 或 identity 机制；surrogate key 可以定义为数值型 PK，并在设计说明中解释其用途。
- 与我沟通和解释时使用中文；表名、字段名、SQL 注释、ERD 标签和最终报告素材使用专业英文。
- 作业禁止直接复制 AI 生成的报告段落。本对话可以提供技术设计、要点和理由清单，但不要生成可直接提交的完整 Section A 论述段落。

三、共享状态文件

创建或更新 PROJECT_STATUS.md，至少包含：

- 当前阶段和状态：not started / draft / awaiting user confirmation / awaiting Oracle evidence / verified
- 已确认的事实表 grain
- 已确认的事实表、维度表及键
- 作出的设计决定和理由
- 生成的文件
- Oracle 验证命令、结果文件和未解决错误
- 明确列出 verified 与 unverified 项目
- 下一步操作

后续对话会依赖这个文件，所以每完成一个阶段都要更新它。不要在状态文件中保存用户名、密码或其他凭据。

四、执行阶段

阶段 A0 - 要求审计与数据库安全预检

先建立 section_a_requirements.md，逐项记录：

- PhoneFix 当前数据设计的已知问题；
- 总部希望进行的业务分析；
- Figure 2 中已有的源字段；
- 可以合理增加但必须解释的属性；
- A.6 的四项交付要求；
- Section A 解释与论证不超过 2 页（references 不计）；
- ERD、DDL、DESC 和报告之间必须保持一致。

如发现 PDF 与现有文件冲突，以 PDF 为准并记录冲突。

在不修改数据库的前提下，运行并保存以下预检证据：当前 `USER`、Oracle version、当前 schema 中名称以 `PF_` 开头的已有 tables/views/materialized views，以及与建表相关的可见 system privileges。保存到 `evidence/section_a/db_preflight.txt`。此阶段不得 DROP 或 CREATE 对象。若发现同名对象，列出准确名称并在设计确认点提醒我。

阶段 A1 - 设计提案与确认点

建立 section_a_design_spec.md，至少包含：

1. STAR 与 SNOWFLAKE 的简短比较，以及最终选择；
2. 明确声明 fact table grain，例如“一行具体代表什么”；
3. 每个 fact/dimension table 的业务用途；
4. 每列的英文名、Oracle datatype、nullable、PK/FK/UK/check 约束；
5. measures 的可加性及计算含义；
6. 日期、门店、客户、产品，以及销售/维修业务如何被表达；
7. surrogate key 与自然业务标识的处理；
8. 该设计怎样支持按时间、产品、客户、门店等角度聚合；
9. 当前设计缺陷、拟议设计优势和合理限制的要点清单。

设计原则：

- 保持一个明确、可评分、可实现的中心业务过程，不要含糊混合不同 grain。
- 如果销售和维修无法在同一个 grain 中合理表达，先比较“统一 transaction fact”和“两个 fact tables”的代价，再选择较易解释的方案。
- 避免把可计算的汇总值重复储存为维度属性。
- 所有 FK 必须指向存在且 datatype 相容的 PK/UK。
- 字段命名必须在 design spec、ERD 和 SQL 中完全一致。

完成设计提案后暂停，向我展示：推荐方案、grain、表清单、主要键和可能失分点。将状态写为 awaiting user confirmation。在我确认之前，不要锁定 ERD 和最终 DDL。

阶段 A2 - ERD

确认设计后，生成可编辑的 ERD 源文件和清晰的导出图。优先生成 draw.io/diagrams.net 可编辑文件；如环境不支持，则生成结构化 ERD 源文件，并给出用 Visio、ERDPlus 或 draw.io 完成导出的明确说明。

ERD 必须清楚显示：

- 全部 fact 和 dimension tables；
- PK、FK；
- 关键 attributes 和 measures；
- 表之间的连接；
- 一对多 cardinality；
- fact table grain 的图注或相邻说明；
- 字体可读，不能出现截断、重叠或模糊文字。

建议输出：

- artifacts/section_a/phonefix_dw_erd.drawio
- artifacts/section_a/phonefix_dw_erd.png 或 phonefix_dw_erd.pdf

生成后必须视觉检查导出图。

阶段 A3 - Oracle DDL

生成根目录 createDW.sql。要求：

- 采用 Oracle SQL 兼容语法；
- 按依赖顺序创建 dimensions，再创建 fact table(s)；
- 明确命名 PK、FK、UK 和必要的 CHECK constraints；
- 使用合理的 NUMBER、VARCHAR2、DATE 等 datatype 和长度；
- 包含清晰但不过度的英文注释；
- 不包含 INSERT；
- 末尾加入用于人工验证的 SELECT table_name 查询和每个表对应的 DESC 指令，或另建 oracle_section_a_validation.sql；
- 若实现可重复运行的 DROP 逻辑，只能精确针对本项目表，并正确处理依赖关系；不要使用危险的广泛删除。
- 不要依赖当前 session 的隐含日期、数字或字符设置；DDL 和验证查询应尽量明确。

静态核对 createDW.sql：

- ERD 中每张表都在 SQL 中；
- SQL 中每张表都在 ERD 中；
- 所有字段名和 datatype 与 design spec 一致；
- 每个 FK 的目标表和目标列存在；
- 所有 constraint names 在当前 schema 中不易冲突；
- 不使用 MySQL、PostgreSQL 或 SQL Server 专用语法。
- 通过 `USER_TABLES`、`USER_TAB_COLUMNS`、`USER_CONSTRAINTS` 和 `USER_CONS_COLUMNS` 准备独立核对，不只依赖脚本“没有弹出错误”。

阶段 A4 - Oracle 验证闭环

数据库已经连接。优先在当前 Oracle SQL Developer 会话中使用 F5/Run Script 执行，不读取、不显示也不保存密码。先确保 `evidence/section_a/` 存在，并保留完整 Script Output。执行后搜索 `ORA-`、`SP2-`、`PLS-` 和 `Warning`，任何未解释错误都视为失败。然后检查预期表数量、列、PK、FK、UK/CHECK 和每张表的 DESC。

如果无法可靠控制 SQL Developer 界面，则：

1. 不得把任务标记为 verified；
2. 生成 ORACLE_RUNBOOK_SECTION_A.md，告诉我按什么顺序打开文件、用 F5/Run Script 运行什么；
3. 要求我把完整 Script Output 保存为 evidence/section_a/createDW_run.txt；
4. 要求我把每张表的 DESC 输出保存为 evidence/section_a/desc_all_tables.txt，截图只能作为补充，不能替代可审计文字输出；
5. 等我提供输出后，读取全部错误，修复 createDW.sql，并要求重新从明确列出的本项目对象状态运行；
6. 修复后必须重新运行完整脚本，而不是只运行报错语句；
7. 只有当脚本无未处理错误、全部预期表存在、约束正确且 DESC 与设计一致时，才把状态改为 verified。

五、完成标准

只有同时满足以下条件才可以宣布 Prompt A 完成：

- section_a_requirements.md 完整；
- section_a_design_spec.md 已经由我确认；
- createDW.sql 存在且通过静态一致性检查；
- ERD 的可编辑源文件与清晰导出图存在；
- ERD、design spec、DDL 三者表名、列名和关系一致；
- 真实 Oracle 运行输出、数据字典约束核对和全部 DESC 证据存在；否则必须明确停在 awaiting Oracle evidence，不能宣布完成；
- PROJECT_STATUS.md 已更新；
- 给我一份简短总结：完成了什么、证据在哪里、仍需我做什么、当前有哪些风险。

如果缺少 rubric，不要猜测其隐藏评分项；继续按发布的 PDF 完成工作，并把 rubric 缺失记录为外部风险而不是伪造内容。如果当前已连接会话后来失效，完成所有不依赖连接的工作，再准确报告 blocker 和恢复连接后要运行的脚本。
```

---

## Prompt B - Section B 查询、物化视图、图表与 queriesDW.sql

```text
你正在协助我完成 AUT COMP810 Data Warehousing and Big Data 的 Data Warehousing Project 2026 Section B。请在当前工作目录中完成 SQL 设计、真实数据库验证、结果证据整理和 Q6/Q7 图表，但不要编造任何数据或运行结果。

工作目录：
/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment

首要目标：
基于 Oracle SH sample schema 完成 Q1-Q7，生成结构清楚的 queriesDW.sql；所有答案必须与作业指定的技术、列名和格式一致，并由真实 Oracle 输出验证。Q6/Q7 的图表只能由 Q5 物化视图的真实导出数据制作。

当前已知环境：

- 学校 Oracle 数据库已经在 Oracle SQL Developer 中连接成功并保持打开。
- 优先尝试使用当前连接执行只读查询和在我自己的 schema 中创建 Q5 物化视图；不要要求我提供或显示密码。
- 如果 Java/SQL Developer 界面无法被可靠控制，不要声称查询已运行，也不要反复猜测点击。请生成一个明确的运行队列，让我用 F5/Run Script 执行，再读取我保存的完整输出。

一、必须首先读取的材料

1. 完整阅读 Data Warehousing Project S2 2026.pdf 的 B.1-B.3、Submission Requirements 和 GAI rules。
2. 视觉检查 PDF 第 5-6 页，准确抄录每题要求和示例输出列名。
3. 完整视觉检查 SH_Schema.pdf，记录 SALES、PRODUCTS、CUSTOMERS、COUNTRIES、TIMES、CHANNELS、PROMOTIONS 的连接键和相关字段；本作业忽略 COSTS。
4. 阅读 PROJECT_STATUS.md 和当前目录已有 SQL/证据，但把它们视作待验证草稿。
5. 如果 Canvas rubric 存在则读取；如果不存在，明确记录，不要杜撰评分细则。

资料优先级：作业 PDF > Canvas rubric（如果存在）> Oracle 数据字典和真实查询输出 > SH_Schema.pdf > 工作草稿 > 模型推断。

二、不可违反的边界

- 只读取 sh.* 数据，不得修改 SH schema；禁止 INSERT、UPDATE、DELETE、TRUNCATE、DROP sh.*。
- 唯一需要创建的数据库对象是 Q5 要求的 Promotion_Analysis_mv，且必须创建在我自己的 schema 中。
- 不得编造结果行、总销售额、排名、图表数据或 SQL Developer 截图。
- 如果查询没有经过真实 Oracle 运行，只能标记为 draft/unverified。
- 使用 ANSI explicit JOIN 和清楚的 table aliases；避免不必要的 `SELECT *`，最终查询只输出题目要求的列。
- 行数限制必须在排序之后执行。根据预检到的 Oracle version 选择兼容的 `FETCH FIRST` 或外层 `ROWNUM` 写法，不能在排序前截断。
- 金额格式必须稳定，不应因 session 的 NLS 设置变成错误的小数点或千位符；必要时在 `TO_CHAR` 中明确数字格式/NLS 参数。
- 与我沟通使用中文；SQL、别名、图表文字、结论要点使用专业英文。
- 可以生成技术结论要点，但不要生成让我直接复制提交的完整分析段落；最终 3-4 句推荐需要我基于证据自行改写。

三、共享状态与证据结构

读取并更新 PROJECT_STATUS.md。为 Section B 增加每题状态：draft / awaiting Oracle / failed / verified。

建立以下目录（如尚不存在）：

- evidence/section_b/
- artifacts/section_b/charts/
- artifacts/section_b/data/

建立 section_b_requirements_matrix.md，逐题记录：题目要求、必须使用的 SQL 技术、指定输出列、过滤条件、排序/排名、验证证据和状态。

四、执行阶段

阶段 B0 - 只读预检与数据发现

生成 oracle_preflight.sql，至少检查：

- SELECT USER FROM dual；
- 当前 Oracle version；
- 是否可以 SELECT sh.sales；
- 相关 sh tables/views 是否存在且可访问；
- 相关列名和 datatype；
- 自己 schema 中是否已有 PROMOTION_ANALYSIS_MV，以及可见的 CREATE MATERIALIZED VIEW 权限信息；
- sales 中日期范围与总行数；
- 与题目有关的 country_region、产品名称/描述、promotion category 和年月的 distinct 样本。

数据发现查询只能用于确认真实数据值和过滤模式，不能把预期值写死。例如，Q2 必须先确认 CD-R/CD-RW 在 prod_name 或 prod_desc 中的实际表示，再决定过滤表达式。

数据库已经连接，因此先尝试直接运行预检并把完整结果保存为 `evidence/section_b/preflight_output.txt`。如果无法控制 SQL Developer，生成 ORACLE_RUNBOOK_SECTION_B.md，并让我用 F5/Run Script 运行。没有真实预检输出时，可以设计查询，但不能声称验证。

运行脚本时启用清楚的 echo、feedback、heading、pagesize 和 linesize 设置。若 SQL Developer 的 `SPOOL` 在当前环境中可用，将日志写入 evidence 目录；若不可用，让我保存完整 Script Output。证据不能只保留被截断的截图。

阶段 B1 - Q1 至 Q4

逐题执行“理解 -> 写草稿 -> 运行 -> 检查 -> 修复 -> 保存证据”，不要一次性假定所有查询正确。

Q1 必须检查：

- 使用 amount_sold；
- 年份为 2000 和 2001；
- 返回最高的五个国家；
- 输出列为 Region、Country Name、Sales；
- Sales 四舍五入到最近的 dollar，但按示例显示 `$123,456,789.00`；
- 排名与最终显示顺序确定且可重复；
- 根据示例没有 `CALENDAR_YEAR` 输出列这一证据，默认将 2000 和 2001 合并统计；把这一解释写入 requirements matrix。如 rubric/教师资料明确要求逐年，则按权威资料调整；
- 用一个不含显示格式的独立数值核对查询确认前五名和排序，不以格式化字符串排序。

Q2 必须检查：

- 确实使用 GROUP BY ROLLUP，而不是普通 GROUP BY 或 UNION 模拟；
- 仅 Europe；
- 包含所有真实数据中属于 CD-R 或 CD-RW 的产品类型；
- 输出 COUNTRY_REGION、COUNTRY_NAME、TOTAL_SALES；
- decimal places 显示为字面值 xx，例如 `$123,456,789.xx`；
- 用 GROUPING/GROUPING_ID 清楚标识 subtotal/grand total，避免 NULL 标签含糊；
- 排序能合理展示 detail、subtotal 和 total；
- 用独立普通聚合查询核对 ROLLUP 的 detail totals 和 grand total；
- 数字部分先按最近 dollar 处理，再显示字面值 `.xx`，不能对已格式化字符串进行数值计算。

Q3 必须检查：

- 使用 nested query；
- Australia；
- 1998-2001 inclusive；
- 先按 year/product 汇总 quantity_sold，再找每年最大值；
- 输出 CALENDAR_YEAR、PROD_ID、PROD_NAME、TOTAL_QUANTITY；
- 对并列第一有明确、可辩护的处理，不能静默丢失 ties；
- 每年结果和最大值可用独立核对查询复核；
- 确认 1998、1999、2000、2001 每年均有结果；如缺失，先诊断 join/filter，不得补造行。

Q4 必须检查：

- 1999；
- 排除 Europe；
- 默认解释“countries ... that had a total sales amount greater than $500,000”为：先按国家识别 1999 年总销售额超过门槛且不在 Europe 的国家，再对这些合格国家的 channel quantity 汇总。因为题意可能有歧义，应同时制作简短 interpretation note，并用中间结果列出合格国家；
- 返回 quantity_sold 最高的三个 channel；
- 输出 CHANNEL_DESC、TOTAL_QUANTITY；
- 使用确定性排序；
- 用独立核对查询确认合格国家、各 channel quantity 和 top 3；
- 如果 rubric 或教师说明给出不同解释，记录并改用该解释，不要同时在最终答案保留两个版本。

每题保存：

- 最终 SQL；
- 完整文本输出或 spool 输出；
- 行数和关键值核对；
- 独立 cross-check 的结果；
- 一组英文 conclusion evidence bullets，说明结果显示了什么，但不写成可直接提交的完整段落。

建议证据文件：evidence/section_b/q1_output.txt 至 q4_output.txt。

阶段 B2 - Q5 物化视图

创建名为 Promotion_Analysis_mv 的 materialized view。必须严格对照作业示例保留并命名以下列：

- CALENDAR_MONTH_DESC
- PROMO_ID
- PROMO_CATEGORY
- PROD_NAME
- PROD_CATEGORY
- TOTAL_SALES

要求：

- 数据范围 1998-2001 inclusive；
- total sales 使用 amount_sold 的正确聚合；
- GROUP BY 粒度与上述非聚合列完全匹配；
- 处理对象已存在时，只删除自己 schema 中的 PROMOTION_ANALYSIS_MV；
- 选择与学校 Oracle 权限兼容的 BUILD/REFRESH 选项，不要假设拥有额外权限；
- 物化视图本身不保证查询顺序，所以另外使用 SELECT ... FROM Promotion_Analysis_mv ORDER BY calendar_month_desc ASC, total_sales DESC 获取截图结果；
- 前十行必须从“先完整排序、再限制行数”的查询得到，写法需兼容预检出的 Oracle version；
- 保存创建结果、结构信息、COUNT(*) 和有序前十行；
- 截图裁剪到前十条记录，但同时保存文字输出作为审计证据。

如 CREATE MATERIALIZED VIEW 报权限或其他错误，保存完整 ORA 错误，不要悄悄改成普通 VIEW。先诊断，再告诉我需要 tutor/DBA 处理的具体权限或配置。

阶段 B3 - Q6 和 Q7 图表

只能从已验证的 Promotion_Analysis_mv 导出数据制作图表。保留用于图表的 SQL 和 CSV。

Q6：

- 对比 promotion category 的 total sales；
- 为“2002 first quarter 应关注哪类 promotion（或不促销）”提供有依据的历史比较；
- 先分别检查“1998-2001 全期间按 promotion category 汇总”和“历史第一季度（Jan-Mar）按年份及 promotion category 汇总”。选择最能支持 2002 Q1 决策、同时不会掩盖年份差异的图表设计，并在 chart notes 中记录选择理由；
- 识别并正确处理 no promotion 类别（如果真实数据存在），说明仅凭销售额无法证明 promotion 的因果效果或 ROI；
- 输出可复现的 extraction SQL、CSV 和清晰图表；
- 图表标题、轴、单位、legend 和类别标签完整；
- 生成 3-4 句所需的 evidence bullets：主要发现、推荐、限制。不得虚构营销成本或利润。

Q7：

- 必须 against time；
- 信息要与 Q6 significantly different；
- 在查看真实 MV 数据后比较候选分析，例如“按月的 product category 销售趋势/季节性”或其他可由 Q5 列支持的时间序列；选择一个与 Q6 指标和图表目的明显不同、且不会因类别过多而不可读的方案；
- 输出可复现的 extraction SQL、CSV 和清晰图表；
- 避免标签重叠，月份按真实时间顺序；
- 生成 3-4 句所需的 evidence bullets，分别覆盖“为何有用”和“管理建议”；
- 说明数据能支持什么、不能支持什么。

图表必须视觉检查：无裁切、无重叠、分辨率清楚、颜色可区分、caption 草案准确。

保留可复现的图表生成脚本，例如 `artifacts/section_b/build_charts.py`，脚本只能读取保存的真实 CSV，不得内嵌或手工改写结果数字。记录 CSV 行数、字段和生成时间，确保报告中的图可以追溯到 extraction SQL。

阶段 B4 - 汇总 queriesDW.sql

在根目录生成最终 queriesDW.sql，至少包含：

- 清楚的 Q1-Q7 分节注释；
- Q1-Q4 最终查询；
- Q5 创建 Promotion_Analysis_mv 和获取有序前十行的查询；
- Q6/Q7 用于图表数据导出的查询；
- 只保留提交需要的 SQL，不把调试垃圾混入最终文件；
- Oracle SQL Developer 使用 F5/Run Script 时可以理解地运行；
- 不包含用户名、密码或连接字符串。

对 queriesDW.sql 做静态检查，再从头进行一次最终 Oracle 验证。运行后搜索 `ORA-`、`SP2-`、`PLS-` 和 `Warning`，逐项解释或修复；不能只凭结果表出现就判定成功。将最终完整运行日志保存为 evidence/section_b/queriesDW_final_run.txt。

五、完成标准

只有以下条件全部满足，才可以宣布 Prompt B 完成：

- section_b_requirements_matrix.md 覆盖 Q1-Q7；
- Q1-Q5 的 SQL 已在真实 Oracle 上验证，并保存输出；
- Q1-Q4 均有独立 cross-check，Q5 有结构、行数和排序后前十行核对；
- Promotion_Analysis_mv 的列、日期范围、聚合 grain 和排序查询符合 PDF；
- Q6/Q7 的 extraction SQL、真实 CSV 和最终图表齐全；
- 每题都有基于真实结果的 conclusion/recommendation evidence bullets；
- queriesDW.sql 完整且最终运行无未处理错误；
- PROJECT_STATUS.md 已更新，并区分 verified 与 unverified；
- 最后向我报告每题状态、输出文件、仍需人工完成的报告文字和任何风险。

如当前已连接会话后来失效，完成可完成的静态设计和运行包，然后停在 awaiting Oracle evidence；不要把草稿包装成最终答案。若只有 CREATE MATERIALIZED VIEW 权限缺失，Q1-Q4 可以分别标记 verified，但 Q5-Q7 必须保持 blocked/unverified 并保留完整 ORA 错误。
```

---

## Prompt C - 报告框架、证据整合、校对与最终 QA

```text
你正在协助我整理 AUT COMP810 Data Warehousing and Big Data 的 Data Warehousing Project 2026 最终报告。你的职责是核对证据、建立报告结构、插入已验证的 SQL/输出/图表、检查一致性，并在我写完自己的分析后做 proofreading 和排版。你不得替我生成可以直接复制提交的完整分析段落。

工作目录：
/Users/chen/Downloads/AUT/Bigdata_warehousing/data_warehousing/datawarehousing- assignment

首要目标：
制作一个专业、完整、可审计的报告工作稿，并在我提供自己的解释和推荐文字后，输出最终 Word 和/或 PDF。报告必须与 createDW.sql、queriesDW.sql、ERD 和真实 Oracle 输出一致，不得含虚构结果或未标记占位内容。

当前已知环境：

- Oracle 数据库已经连接，但本阶段原则上不重新分析或改写 SQL。
- 优先使用 A/B 已保存的最终证据；只有发现缺失或不一致时，才回到 Oracle 做最小范围复核，并把复核结果保存到原 evidence 目录。

一、首先读取和核对

1. 完整阅读 Data Warehousing Project S2 2026.pdf，特别是 A.6、B.1-B.3、Submission Requirements、Plagiarism 和 GAI rules。
2. 读取 SH_Schema.pdf。
3. 读取 PROJECT_STATUS.md、section_a_requirements.md、section_a_design_spec.md、section_b_requirements_matrix.md。
4. 读取 createDW.sql、queriesDW.sql、最终 ERD、全部 Oracle 证据、Q6/Q7 CSV 和图表。
5. 如果 Canvas rubric 文件存在则读取并制作 rubric mapping；如果不存在，在报告 QA 中标为外部风险并提醒我从 Canvas 下载，不得猜测 rubric。rubric 缺失不阻止按已发布 PDF 组装报告，但不能声称已完成 rubric-specific 核对。

资料优先级：作业 PDF > Canvas rubric（如果存在）> 真实 Oracle 输出/导出 CSV > 最终 SQL/ERD > 工作笔记 > 模型推断。

二、学术诚信边界

- 作业明确禁止学生把 AI 生成的段落直接复制进报告。因此，你可以建立结构、证据表、分析问题、bullet points、表格/图注草案，以及校对我已经写好的文字，但不要替我生成完整的 Section A justification 或 Q1-Q7 conclusion/recommendation paragraphs。
- 对我提供的文字可以检查 grammar、punctuation、clarity、flow 和是否得到证据支持，但不要在不提示的情况下改变我的技术含义。
- 不得添加未经验证的数字、结果、引用或截图。
- 必须保留诚实且具体的 AI Use Log。不要声称未使用 AI。
- 如引用外部资料，只使用可核实来源，并留下完整 reference details；不要制造引用。

三、阶段 C0 - 完整性审计

先建立 final_evidence_matrix.md，每一行对应一个要求，至少包括：

- PDF/rubric 要求；
- 报告中的目标章节；
- 对应 SQL 文件和位置；
- 对应真实输出/截图/图表文件；
- 状态：present / missing / inconsistent / unverified；
- 修复动作。

必须检查：

- Section A 四项交付内容齐全；
- Section A explanation/justification 不超过 2 页（references 不计）；
- Q1-Q5 每题都有 query、output 和 conclusion；
- Q6-Q7 每题都有 code、chart 和 3-4 句 writing；
- 图表和表格有 caption，正文中被引用；
- report、ERD、createDW.sql、queriesDW.sql 名称和内容一致；
- `submission/createDW.sql` 与根目录已验证版本逐字节一致，`submission/queriesDW.sql` 与根目录已验证版本逐字节一致；可使用 `cmp` 或 SHA-256 验证，不要手工复制后假定一致；
- AI Use Log 存在；
- References section 在需要时存在；
- 没有密码、连接字符串、调试输出或个人敏感信息。

发现 missing/inconsistent/unverified 项目时先列出，不要用猜测填补。

四、阶段 C1 - 生成报告模板，不生成代写段落

生成 report_content_plan.md，并建立专业的 Word 报告模板。建议结构：

- Cover page
- Table of Contents（如篇幅适合）
- Section A - Data Warehouse Schema: Design and Implementation
  - Current design deficiencies
  - Schema choice and justification
  - Fact grain, dimensions and measures
  - Comparative advantages and limitations
  - Logical DW schema/ERD
  - Oracle DDL and table descriptions
- Section B - Multidimensional Data Analysis
  - Q1 至 Q5：Question / SQL / Output / Student conclusion
  - Q6 至 Q7：Extraction SQL / Chart / Student recommendation
- References（如有）
- Appendix A - AI Use Log
- 可选 Appendix B - Additional evidence（只有确有必要时）

模板可以自动插入：

- 已验证的 SQL code blocks；
- ERD；
- 已验证的结果截图/经过排版的结果表；
- Q6/Q7 图表；
- figure/table numbers、captions 草案和交叉引用；
- 每段需要回答的问题和 evidence bullets；
- 明显标记的 `[STUDENT TO WRITE]` 区域。

模板不得把 evidence bullets 伪装成学生完成的段落。

阶段 C2 - 学生写作检查点

生成 student_writing_checklist.md，逐项告诉我要用自己的话完成什么，例如：

- Section A 为什么选择该 schema；
- 为什么该 grain 和 dimensions 支持 PhoneFix 决策；
- Q1-Q5 结果意味着什么；
- Q6/Q7 的 3-4 句建议及限制。

创建模板后暂停，列出所有 `[STUDENT TO WRITE]` 项。等我填写并明确要求继续后，再进入 C3。不要自行删除这些占位符。

阶段 C3 - Proofreading 与格式化

读取我写入的文字并执行：

- 修正 grammar、spelling、punctuation 和明显不通顺处；
- 标记任何与数据证据不一致、过度因果推断或无法验证的说法；
- 对重大技术改写使用 comments/change log，让我知道改了什么；
- 保持学生本人的分析含义和语气；
- 统一 heading、font、spacing、margins、code formatting、caption 和 page numbering；
- 确保图表清晰、未裁切、正文引用正确。

如果环境提供文档和 PDF 专用工作流，必须使用它们创建/检查 `.docx` 和 PDF，并在每次重要修改后重新渲染检查，而不是只检查源文件文字。

AI Use Log 至少真实记录：

- Tool：Codex/OpenAI；
- Sections used：Section A technical design support、Section B SQL troubleshooting/data visualisation、report proofreading/formatting 等实际用途；
- Purpose；
- How output was verified or revised，例如 Oracle execution、manual review、rewritten in student's own words。

阶段 C4 - 最终 QA 与导出

在导出前执行两轮检查：

第一轮，内容一致性：

- 报告中的 SQL 与提交脚本一致；
- 报告中的数字与真实输出/CSV 一致；
- ERD 与 createDW.sql 一致；
- Q5-Q7 之间数据 lineage 一致；
- 每一个结果表/图表都能追溯到具体 SQL 和 evidence 文件；
- 所有题目均已回答；
- 没有未解释的 NULL、空结果或失败输出。

第二轮，视觉和提交检查：

- 渲染 Word/PDF 的每一页并视觉检查；
- 没有文字/表格/代码/图片被裁切或重叠；
- captions、页码、目录和 section transitions 正确；
- 搜索并消除所有 TODO、TBD、PLACEHOLDER、[STUDENT TO WRITE]；
- 文件名清楚；
- 最终提交包包含 report、createDW.sql、queriesDW.sql；
- 用 `cmp` 或 SHA-256 确认提交目录的两个 SQL 与已验证根目录版本一致；
- 提醒我在 Canvas 上传后查看 Turnitin Similarity Report。

建议最终输出：

- submission/COMP810_DW_Project_Report.docx
- submission/COMP810_DW_Project_Report.pdf
- submission/createDW.sql
- submission/queriesDW.sql
- final_submission_checklist.md

五、完成标准

只有以下条件全部满足才可宣布 Prompt C 完成：

- final_evidence_matrix.md 没有影响 PDF 明示要求的 unresolved missing/inconsistent/unverified 项；若 rubric 仍未取得，单独标为 external risk，不能伪装成已经核对；
- 学生已经完成并确认自己的分析文字；
- 报告包含全部要求且与真实证据一致；
- Section A 页数限制经过实际版面检查；
- AI Use Log 真实、具体且存在；
- Word/PDF 已逐页渲染并检查；
- submission 文件夹包含三个要求的提交文件；
- final_submission_checklist.md 明确显示 PASS，或准确列出剩余 blocker。

若任何真实 Oracle 结果缺失或学生文字未完成，完成其余可做工作后暂停，并明确告诉我缺什么。rubric 未取得时继续按 PDF 完成，但在最终检查表突出标记这一外部风险。不得为了“完成”而编造或隐藏缺口。
```

---

## 三个 Prompt 的预期输出

### Prompt A

- `PROJECT_STATUS.md`
- `section_a_requirements.md`
- `section_a_design_spec.md`
- `createDW.sql`
- 可编辑 ERD 和清晰导出图
- `ORACLE_RUNBOOK_SECTION_A.md`（若 Codex 无法直接运行 Oracle）
- Oracle 运行日志和全部 `DESC` 证据（需要真实数据库连接）

### Prompt B

- `section_b_requirements_matrix.md`
- `oracle_preflight.sql`
- `queriesDW.sql`
- Q1-Q5 的真实输出证据
- Q6/Q7 的 extraction SQL、CSV 和图表
- 每题的 evidence bullets，供学生自行写结论
- `ORACLE_RUNBOOK_SECTION_B.md`（若 Codex 无法直接运行 Oracle）

### Prompt C

- `final_evidence_matrix.md`
- `report_content_plan.md`
- 带 SQL、输出、图表和写作占位区的 Word 报告模板
- `student_writing_checklist.md`
- 学生完成文字后，经校对和版面检查的最终 Word/PDF
- 真实 AI Use Log
- `submission/` 中的三个要求提交文件
- `final_submission_checklist.md`

## 最终版自动检查结果与外部依赖

已纳入最终版的优化：

1. 已将“Oracle 已连接”写入 Prompt A/B，并要求优先进行真实数据库预检和验证。
2. 已加入 Oracle version、权限、对象冲突和 SH 访问检查。
3. 已加入 `PF_` 对象命名前缀、30 字符兼容边界和安全删除范围。
4. 已加入 Q1-Q4 的独立 cross-check，以及排序后再限制行数的规则。
5. 已加强 Q1/Q2 金额格式、NLS 稳定性、Q3 ties、Q4 题意解释和 Q5 物化视图排序验证。
6. 已要求 Q6/Q7 保留 extraction SQL、真实 CSV、可复现图表脚本和数据 lineage。
7. 已要求最终脚本扫描 `ORA-`、`SP2-`、`PLS-`、`Warning`，修复后全量重跑。
8. 已要求提交目录 SQL 与已验证根目录 SQL 使用 `cmp`/SHA-256 核对。
9. 已保留学生写作检查点，以符合 PDF 中的 GAI 使用限制。

当前唯一重要的外部缺口是 Canvas rubric 尚未出现在工作目录中。三个 Prompt 可以依据已发布 PDF 完成任务，但取得 rubric 后仍应在对应对话中补做 rubric mapping。Section A 的最终 schema grain 以及 Q2/Q4/Q6 的数据相关选择不是 Prompt 漏洞，而是刻意保留的证据驱动确认点。
