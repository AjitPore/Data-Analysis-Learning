-- All this code executed in Google Colab on Diffrent code tabs
-- Do not run this codes Here use google colab

-- 1) Python Code to load Contoso Dataset in Google Colab
import sys
import pandas as pd
import matplotlib.pyplot as plt
%matplotlib inline

# If running in Google Colab, install PostgreSQL and restore the database
if 'google.colab' in sys.modules:
    # Update package installer
    !sudo apt-get update -qq > /dev/null 2>&1

    # Install PostgreSQL
    !sudo apt-get install postgresql -qq > /dev/null 2>&1

    # Start PostgreSQL service (suppress output)
    !sudo service postgresql start > /dev/null 2>&1

    # Set password for the 'postgres' user to avoid authentication errors (suppress output)
    !sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'password';" > /dev/null 2>&1

    # Create the 'colab_db' database (suppress output)
    !sudo -u postgres psql -c "CREATE DATABASE contoso_100k;" > /dev/null 2>&1

    # Download the PostgreSQL .sql dump
    !wget -q -O contoso_100k.sql https://github.com/lukebarousse/Int_SQL_Data_Analytics_Course/releases/download/v.0.0.0/contoso_100k.sql

    # Restore the dump file into the PostgreSQL database (suppress output)
    !sudo -u postgres psql contoso_100k < contoso_100k.sql > /dev/null 2>&1

    # Shift libraries from ipython-sql to jupysql
    !pip uninstall -y ipython-sql > /dev/null 2>&1
    !pip install jupysql > /dev/null 2>&1

# Load the sql extension for SQL magic
%load_ext sql

# Connect to the PostgreSQL database
%sql postgresql://postgres:password@localhost:5432/contoso_100k

# Enable automatic conversion of SQL results to pandas DataFrames
%config SqlMagic.autopandas = True

# Disable named parameters for SQL magic
%config SqlMagic.named_parameters = "disabled"

# Display pandas number to two decimal places
pd.options.display.float_format = '{:.2f}'.format

-- Aggregation functions in winodw functions
-- 2) 
%%sql

SELECT
  customerkey,
  orderkey,
  linenumber,
  (quantity * netprice * exchangerate) AS net_revenue,
  AVG(quantity * netprice * exchangerate) OVER() AS avg_net_revenue_all_orders
FROM sales
ORDER BY customerkey
LIMIT 10;

-- 3)
%%sql

SELECT
  customerkey,
  orderkey,
  linenumber,
  (quantity * netprice * exchangerate) AS net_revenue,
  AVG(quantity * netprice * exchangerate) OVER() AS avg_net_revenue_all_orders,
  AVG(quantity * netprice * exchangerate) OVER(PARTITION BY customerkey) AS avg_net_revenue_this_customers
FROM sales
ORDER BY customerkey
LIMIT 10;

-- 4)
%%sql

-- This query analyzes customer orders and ranks them,
-- calculates running totals and revenue proportions per customer.

SELECT
    customerkey AS customer,
    orderdate,

    -- Calculate net revenue for each order
    (quantity * netprice * exchangerate) AS net_revenue,

    -- Rank orders per customer based on highest revenue (DESC)
    ROW_NUMBER() OVER (
        PARTITION BY customerkey
        ORDER BY quantity * netprice * exchangerate DESC
    ) AS order_rank,

    -- Running total revenue per customer ordered by orderdate
    SUM(quantity * netprice * exchangerate) OVER (
        PARTITION BY customerkey
        ORDER BY orderdate
    ) AS customer_running_total,

    -- Total revenue per customer
    SUM(quantity * netprice * exchangerate) OVER (
        PARTITION BY customerkey
    ) AS customer_net_revenue,

    -- Proportion of each order’s revenue compared to customer’s total revenue
    (quantity * netprice * exchangerate) / 
    SUM(quantity * netprice * exchangerate) OVER (
        PARTITION BY customerkey
    ) AS percent_of_customer_revenue

FROM sales

-- Order results by customer and orderdate
ORDER BY customerkey, orderdate

-- Limit results to 10 rows
LIMIT 10;

-- 5)
%%sql

-- This query analyzes sales data by calculating net revenue per order line,
-- total daily revenue, and the percentage contribution of each line to the daily total.

SELECT
    orderdate,

    -- Generate a unique order line number by combining orderkey and linenumber
    orderkey * 10 + linenumber AS order_line_number,

    -- Calculate revenue per line item
    (quantity * netprice * exchangerate) AS net_revenue,

    -- Compute the total revenue for each day (partitioned by orderdate)
    SUM(quantity * netprice * exchangerate) 
    OVER(PARTITION BY orderdate) AS daily_net_revenue,

    -- Calculate what percentage each line item contributes to its day's total revenue
    (quantity * netprice * exchangerate) * 100.0 / 
    SUM(quantity * netprice * exchangerate) OVER(PARTITION BY orderdate) AS pct_daily_revenue

FROM sales

-- Sort results by date and descending percentage contribution
ORDER BY
    orderdate,
    pct_daily_revenue DESC

-- Limit result to first 10 rows
LIMIT 10;

-- 6)
-- this is the same above code but included in CTE to make it clean and short
%%sql

SELECT
  *,
  100 * net_revenue / daily_net_revenue AS pct_daily_revenue
FROM (
  SELECT
    orderdate,
    orderkey * 10 + linenumber AS order_line_item,
    (quantity * netprice * exchangerate) AS net_revenue,
    SUM(quantity * netprice * exchangerate) OVER(PARTITION BY orderdate) AS daily_net_revenue
  FROM
    sales
) AS revenue_by_day;

-- 7) Cohart
%%sql

WITH yearly_cohort AS (
  SELECT DISTINCT
    customerkey,
    EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
  FROM sales
)
SELECT
  y.cohort_year,
  EXTRACT(YEAR FROM orderdate) AS purchase_year,
  SUM(s.quantity * s.netprice * s.exchangerate) AS net_revenue
FROM sales s
LEFT JOIN yearly_cohort y ON s.customerkey = y.customerkey
GROUP BY
  y.cohort_year,
  purchase_year;

-- 8) 
%%sql

-- CTE: Determine the cohort year (first purchase year) and current purchase year for each customer
WITH yearly_cohort AS (
    SELECT DISTINCT
        customerkey,

        -- Get the year of the first order for the customer
        EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year,

        -- Get the year of the current purchase
        EXTRACT(YEAR FROM orderdate) AS purchase_year
    FROM
        sales
)

-- Count number of customers by purchase year and cohort year (i.e., cohort analysis)
SELECT DISTINCT
    cohort_year,
    purchase_year,

    -- Count number of customers for each cohort and purchase year combination
    COUNT(customerkey) OVER (PARTITION BY purchase_year, cohort_year) AS num_customers

FROM yearly_cohort
ORDER BY
cohort_year,
purchase_year;

-- Never USE GROUP BY in the window Function query it will show error, we can use GROUP BY in CTE but not in window function query

-- 9)
%%sql

WITH customer_orders AS (
  SELECT
    customerkey,
    quantity * netprice * exchangerate AS order_value,
    COUNT(*) OVER(PARTITION BY customerkey) AS total_orders
  FROM sales
)
SELECT
  customerkey,
  total_orders,
  AVG(order_value) AS net_revenue
FROM
  customer_orders
GROUP BY
  customerkey,
  total_orders;

-- 10)
%%sql

WITH yearly_cohort AS (
  SELECT
    customerkey,
    EXTRACT(YEAR FROM MIN(orderdate)) AS cohort_year,
    SUM(quantity * netprice * exchangerate) AS customer_ltv
  FROM sales
  GROUP BY
    customerkey
)
SELECT
  *,
  AVG(customer_ltv) OVER (PARTITION BY cohort_year) AS avg_cohort_ltv
FROM
  yearly_cohort
ORDER BY
  cohort_year,
  customerkey;

-- 11) Using WHERE in window function, need to use in CTE
%%sql

WITH cohort AS (
  SELECT
    customerkey,
    EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
  FROM sales
)
SELECT *
FROM cohort
WHERE cohort_year >= '2020';

-- Ranking functions in window functions

-- 12) checking for ranking use
%%sql

SELECT
  customerkey,
  orderdate,
  (quantity * netprice * exchangerate) AS net_revenue,
  COUNT(*) OVER (
    PARTITION BY customerkey
    ORDER BY orderdate
  ) AS running_order_count,
  AVG(quantity * netprice * exchangerate) OVER (
    PARTITION BY customerkey
    ORDER BY orderdate
  ) AS running_avg_revenue
FROM
  sales;

-- 13)
%%sql
WITH row_numbering AS (
  SELECT
    ROW_NUMBER() OVER(
      PARTITION BY
        orderdate
      ORDER BY
        orderdate,
        orderkey,
        linenumber
    ) AS row_num,
    *
  FROM sales
)
SELECT *
FROM row_numbering
WHERE orderdate > '2015-01-01'
LIMIT 10;

-- 14)
%%sql

SELECT
  customerkey,
  COUNT(*) AS total_orders,
  ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS total_orders_row_num,
  RANK() OVER (ORDER BY COUNT(*) DESC) AS total_orders_rank,
  DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS total_orders_dense_rank
FROM sales
GROUP BY customerkey
LIMIT 10;

-- 15) FIRST VALUE, LAST VALUE & NTH VALUE
%%sql

-- CTE: Calculate monthly revenue for the year 2023
WITH monthly_revenue AS (
    SELECT
        -- Format order date to 'YYYY-MM' for monthly grouping
        TO_CHAR(orderdate, 'YYYY-MM') AS month,
        -- Calculate net revenue for the month
        SUM(quantity * netprice * exchangerate) AS net_revenue
    FROM sales
    WHERE EXTRACT(YEAR FROM orderdate) = 2023
    GROUP BY month
    ORDER BY month
)
-- Select revenue details along with window function outputs
SELECT
    *,
    -- Revenue in the first month of 2023
    FIRST_VALUE(net_revenue) OVER (ORDER BY month) AS first_month_revenue,
    -- Revenue in the last month of 2023
    LAST_VALUE(net_revenue) OVER (
        ORDER BY month 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_month_revenue,
    -- Revenue in the 3rd month of 2023
    NTH_VALUE(net_revenue, 3) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS third_month_revenue
FROM monthly_revenue;

-- 16) LAG & LEAD
%%sql
WITH monthly_revenue AS (
  SELECT
    TO_CHAR(orderdate, 'YYYY-MM') AS month,
    SUM(quantity * netprice * exchangerate) AS net_revenue
  FROM sales
  WHERE EXTRACT(YEAR FROM orderdate) = 2023
  GROUP BY month
  ORDER BY month
)
SELECT
  *,
  LAG(net_revenue) OVER (ORDER BY month) AS previous_month_revenue,
  LEAD(net_revenue) OVER (ORDER BY month) AS next_month_revenue
FROM monthly_revenue;

-- 17) Why LAG & LEAD Used Example
%%sql
WITH monthly_revenue AS (
  SELECT
    TO_CHAR(orderdate, 'YYYY-MM') AS month,
    SUM(quantity * netprice * exchangerate) AS net_revenue
  FROM sales
  WHERE EXTRACT(YEAR FROM orderdate) = 2023
  GROUP BY month
  ORDER BY month
)
SELECT
  *,
  LAG(net_revenue) OVER (ORDER BY month) AS previous_month_revenue,
  100 * (net_revenue - LAG(net_revenue) OVER (ORDER BY month)) / LAG(net_revenue) OVER (ORDER BY month) AS monthly_rev_growth
FROM monthly_revenue;

-- 18)
-- Step 1: Calculate cohort year and LTV per customer
WITH yearly_cohort AS (
  SELECT
    customerkey,
    EXTRACT(YEAR FROM MIN(orderdate)) AS cohort_year, -- year of customer's first order
    SUM(quantity * netprice * exchangerate) AS customer_ltv -- total revenue from customer
  FROM sales
  GROUP BY customerkey
),
-- Step 2: Add average LTV per cohort
cohort_summary AS (
  SELECT
    cohort_year,
    customerkey,
    customer_ltv,
    AVG(customer_ltv) OVER (PARTITION BY cohort_year) AS avg_cohort_ltv -- average LTV for cohort
  FROM yearly_cohort
),
-- Step 3: Prepare cohort summary table with distinct cohort year and average LTV
cohort_final AS (
  SELECT DISTINCT
    cohort_year,
    avg_cohort_ltv
  FROM cohort_summary
  ORDER BY cohort_year
)
-- Step 4: Final output with previous year LTV and percentage change
SELECT
  cohort_year,
  avg_cohort_ltv,
  LAG(avg_cohort_ltv) OVER (ORDER BY cohort_year) AS prev_cohort_ltv, -- previous year’s LTV
  ROUND(
    100.0 * (avg_cohort_ltv - LAG(avg_cohort_ltv) OVER (ORDER BY cohort_year)) /
    LAG(avg_cohort_ltv) OVER (ORDER BY cohort_year), 2
  ) AS ltv_change_percent -- LTV % change vs previous year
FROM cohort_final;

-- 19) FRAME CLAUGE
%%sql

WITH monthly_sales AS (
  SELECT
    TO_CHAR(orderdate, 'YYYY-MM') AS month,
    SUM(quantity * netprice * exchangerate) AS net_revenue
  FROM sales
  WHERE EXTRACT(YEAR FROM orderdate) = 2023
  GROUP BY month
  ORDER BY month
)
SELECT
  month,
  net_revenue,
  AVG(net_revenue) OVER (
    ORDER BY month
    ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
  ) AS net_revenue_preceding_1,
  AVG(net_revenue) OVER (
    ORDER BY month
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS net_revenue_preceding_2,
  AVG(net_revenue) OVER (
    ORDER BY month
    ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
  ) AS net_revenue_preceding_3
FROM monthly_sales;

-- 20)
%%sql
WITH monthly_sales AS (
  SELECT
    TO_CHAR(orderdate, 'YYYY-MM') AS month,
    SUM(quantity * netprice * exchangerate) AS net_revenue
  FROM sales
  WHERE EXTRACT(YEAR FROM orderdate) = 2023
  GROUP BY month
  ORDER BY month
)
SELECT
  month,
  net_revenue,
  AVG(net_revenue) OVER (
    ORDER BY month
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ) AS net_revenue_current
FROM monthly_sales;

-- 21) 
%%sql
WITH monthly_sales AS (
  SELECT
    TO_CHAR(orderdate, 'YYYY-MM') AS month,
    SUM(quantity * netprice * exchangerate) AS net_revenue
  FROM sales
  WHERE EXTRACT(YEAR FROM orderdate) = 2023
  GROUP BY month
  ORDER BY month
)
SELECT
  month,
  net_revenue,
  FIRST_VALUE(net_revenue) OVER (ORDER BY month) AS first_month_revenue,
  LAST_VALUE(net_revenue) OVER (
    ORDER BY month
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS last_month_revenue,
  NTH_VALUE(net_revenue, 3) OVER (ORDER BY month) AS third_month_revenue_unbound
FROM monthly_sales;