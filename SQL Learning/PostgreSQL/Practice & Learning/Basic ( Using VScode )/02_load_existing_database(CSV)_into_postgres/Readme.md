# 🗂️ 02_Load_Existing_Database(CSV)_into_Postgres

This folder focuses on the process of **creating tables and loading external CSV files** into PostgreSQL.  
It simulates a real-world scenario where raw data is imported and structured for analysis.

---

## 📄 Query List & Descriptions

| File Name                     | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| 01_create_tables.sql         | Defines the schema (tables, columns, data types) to match the CSV structure |
| 02_create_database.sql       | Creates a new PostgreSQL database for loading and working with CSV data     |
| 03_modify_tables_load_data.sql | Loads CSV files into the created tables using `COPY` or `INSERT` commands    |

---

## 🧠 Learning Objectives

- Understand how to structure tables to receive external data
- Use PostgreSQL’s `COPY` command or alternatives for importing CSV
- Perform data modifications after loading (e.g., type casting, formatting)

---

## 🧪 Tools Used

- PostgreSQL  
- CSV datasets  
- SQL `CREATE`, `COPY`, `INSERT`, `ALTER` statements

---

> 📌 This is a fundamental process in real-world data projects where analysts often import large volumes of CSV or Excel data for transformation and analysis.
