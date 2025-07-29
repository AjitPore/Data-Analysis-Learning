# 🧪 Practice & Learning — PostgreSQL

This folder is dedicated to building and reinforcing SQL skills using PostgreSQL.  
It includes structured exercises organized into three main sections:  
1️⃣ Table Manipulation  
2️⃣ Loading External Data (CSV)  
3️⃣ Concept-Based Query Practice

---

## 📁 01_Manipulate_Tables

**Description:**  
This section focuses on mastering core SQL commands related to table creation, modification, and data manipulation.

**Included Queries:**

| File Name                          | Description                                |
|-----------------------------------|--------------------------------------------|
| 01_create_database.sql            | Create a new PostgreSQL database           |
| 02_create_table_function.sql      | Create a table with defined columns        |
| 03_insert_into_function.sql       | Insert sample data into a table            |
| 04_alter_table_ADD_function.sql   | Add a new column to an existing table      |
| 05_alter_table_RENAME_function.sql| Rename an existing column or table         |
| 06_alter_table_ALTER_COLUMN.sql   | Modify column data types or constraints    |
| 07_alter_table_DROP_COLUMN.sql    | Drop unnecessary columns from a table      |
| 08_update_function.sql            | Update data in a table                     |
| 09_drop_table_function.sql        | Drop/delete the entire table               |

**💡 Purpose:**  
These queries help you become confident in handling schema design and table-level operations.

---

## 📁 02_Load_Existing_Database(CSV)_into_Postgres

**Description:**  
This section focuses on creating tables and loading external CSV data into PostgreSQL using SQL.

**Included Queries:**

| File Name                    | Description                                     |
|-----------------------------|-------------------------------------------------|
| 01_create_tables.sql        | Define tables based on external data structure  |
| 02_create_database.sql      | Create a dedicated database for imported data   |
| 03_modify_tables_load_data.sql | Load CSV files into PostgreSQL using `COPY` or `INSERT`|

**💡 Purpose:**  
Learn how to structure and import real-world datasets, preparing them for analysis.

---

## 📁 03_Learning

**Description:**  
Concept-based SQL problems and exercises to strengthen analytical skills.

**Included Queries:**

| File Name                                  | Focus Area                                   |
|-------------------------------------------|----------------------------------------------|
| 01_practice_problem_with_date_function.sql| Work with PostgreSQL date/time functions      |
| 02_case_expression.sql                     | Conditional logic using `CASE`               |
| 03_subqueries.sql                          | Use subqueries inside `SELECT`, `WHERE`, etc.|
| 04_common_table_expressions(CTEs).sql      | Learn and apply `WITH` clauses               |
| 05_problem_with_CTE&Subqueries.sql         | Combine CTEs and subqueries in challenges     |
| 06_union_&_union_all.sql                   | Understand and apply `UNION` vs `UNION ALL`   |
| 07_problem_with_union&union_all.sql        | Real-world scenarios using set operations     |

**💡 Purpose:**  
These practice files help you apply logical thinking, work with real conditions, and solve SQL-based analytical challenges.

---

> 📌 Each subfolder contains hands-on `.sql` files for progressive skill building.  
> 💻 All queries were written and tested using **PostgreSQL**.
---