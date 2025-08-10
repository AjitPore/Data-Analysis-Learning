# 📈 Project (Intermediate)

This folder contains advanced SQL analysis projects using the **Contoso Dataset**.  
Each project builds on concepts from `Project (Basic)`, introducing cohort analysis, segmentation, and retention tracking.

**Tools & Data:** This project was developed using the **PostgreSQL** database, the **Contoso Dataset**, executed and analyzed in **Google Colab**, and written using the **DBeaver** SQL editor.

---

## 📁 Files Overview

1. **0_view_cohort_analysis.sql** – Creates a base cohort analysis view.
2. **1_customer_segmentation.sql** – Segments customers based on lifetime value (LTV).
3. **2_cohort_analysis.sql** – Aggregates cohort-level revenue and customer counts.
4. **3_retention_analysis.sql** – Analyzes customer retention and churn rates.

---

## 📄 Project Details

### 0️⃣ View Cohort Analysis
**Objective:**  
Create a reusable **`cohort_analysis`** view that calculates per-customer revenue, order counts, demographic info, and first purchase date.

**Key SQL Concepts Used:**  
`CREATE OR REPLACE VIEW`, `JOIN`, `SUM`, `COUNT`, `MAX`, `WINDOW FUNCTIONS`, `GROUP BY`

**SQL Code:**
```sql
CREATE OR REPLACE VIEW public.cohort_analysis AS
WITH customer_revenue AS (
    SELECT 
        s.customerkey,
        s.orderdate,
        SUM(s.quantity * s.netprice * s.exchangerate) AS total_net_revenue,
        COUNT(s.orderkey) AS num_orders,
        MAX(c.countryfull) AS countryfull,
        MAX(c.age) AS age,
        MAX(c.givenname) AS givenname,
        MAX(c.surname) AS surname
    FROM sales s
    JOIN customer c ON c.customerkey = s.customerkey
    GROUP BY s.customerkey, s.orderdate
)
SELECT
    customerkey,
    orderdate,
    total_net_revenue,
    num_orders,
    countryfull,
    age,
    CONCAT(TRIM(BOTH FROM givenname), ' ', TRIM(BOTH FROM surname)) AS cleaned_name,
    MIN(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM customer_revenue cr;
```

---

### 1️⃣ Customer Segmentation
**Objective:**  
Segment customers into **Low**, **Mid**, and **High** value groups based on **Lifetime Value (LTV)** using percentile cutoffs.

**Key SQL Concepts Used:**  
`PERCENTILE_CONT`, `CASE WHEN`, `GROUP BY`, `WINDOW FUNCTIONS`

**SQL Code:**
```sql
WITH customer_ltv AS (
    SELECT
        customerkey,
        cleaned_name,
        SUM(total_net_revenue) AS total_ltv
    FROM cohort_analysis
    GROUP BY customerkey, cleaned_name
),
customer_segments AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile
    FROM customer_ltv
),
segment_values AS (
    SELECT
        c.*,
        CASE
            WHEN c.total_ltv < cs.ltv_25th_percentile THEN '1 - Low-Value'
            WHEN c.total_ltv <= cs.ltv_75th_percentile THEN '2 - Mid-Value'
            ELSE '3 - High-Value'
        END AS customer_segment
    FROM customer_ltv c, customer_segments cs
)
SELECT
    customer_segment,
    SUM(total_ltv) AS total_ltv,
    COUNT(customerkey) AS customer_count,
    SUM(total_ltv) / COUNT(customerkey) AS avg_ltv
FROM segment_values
GROUP BY customer_segment
ORDER BY customer_segment DESC;
```

---

### 2️⃣ Cohort Analysis
**Objective:**  
Summarize **first purchase revenue** and customer counts for each cohort year.

**SQL Code:**
```sql
SELECT
    cohort_year,
    SUM(total_net_revenue) AS total_revenue,
    COUNT(DISTINCT customerkey) AS total_customers,
    SUM(total_net_revenue) / COUNT(DISTINCT customerkey) AS customer_revenue
FROM cohort_analysis
WHERE orderdate = first_purchase_date
GROUP BY cohort_year;
```

---

### 3️⃣ Retention Analysis
**Objective:**  
Identify **Active** vs **Churned** customers per cohort based on their last purchase date.

**Key SQL Concepts Used:**  
`ROW_NUMBER()`, `INTERVAL`, `CASE WHEN`, `WINDOW FUNCTIONS`

**SQL Code:**
```sql
WITH customer_last_purchase AS (
    SELECT
        customerkey,
        cleaned_name,
        orderdate,
        ROW_NUMBER() OVER (PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,
        first_purchase_date,
        cohort_year
    FROM cohort_analysis
),
churned_customers AS (
    SELECT
        customerkey,
        cleaned_name,
        orderdate AS last_purchase_date,
        CASE
            WHEN orderdate < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months' THEN 'Churned'
            ELSE 'Active'
        END AS customer_status,
        cohort_year
    FROM customer_last_purchase
    WHERE rn = 1
      AND first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
)
SELECT
    cohort_year,
    customer_status,
    COUNT(customerkey) AS num_customers,
    SUM(COUNT(customerkey)) OVER (PARTITION BY cohort_year) AS total_customers,
    ROUND(COUNT(customerkey) * 1.0 / SUM(COUNT(customerkey)) OVER (PARTITION BY cohort_year), 2) AS status_percentage
FROM churned_customers
GROUP BY cohort_year, customer_status;
```

---

## 💡 Insights Gained
- Created **cohort-based analysis** to track customer lifecycle.
- Segmented customers to identify high-value vs low-value groups.
- Measured **first purchase revenue trends** over time.
- Analyzed churn rates to aid **retention strategies**.

---
