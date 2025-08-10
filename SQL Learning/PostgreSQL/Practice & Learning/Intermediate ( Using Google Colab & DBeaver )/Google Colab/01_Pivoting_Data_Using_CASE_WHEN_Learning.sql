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


-- 2) Finding Net revenue
%%sql

SELECT 
    orderdate,
    quantity * netprice * exchangerate AS net_revenue
FROM 
    sales
LIMIT
    10;

-- 3) Recent Sales >=2020
SELECT 
    orderdate,
    quantity * netprice * exchangerate AS net_revenue
FROM 
    sales
WHERE 
    orderdate::DATE >= '01-01-2020'
LIMIT
    10;

-- 4) Add Customer Info
%%sql

SELECT 
    s.orderdate,
    s.quantity * s.netprice * s.exchangerate AS net_revenue,
    c.givenname,
    c.surname,
    c.countryfull,
    c.continent
FROM 
    sales s
LEFT JOIN customer c
    ON c.customerkey = s.custoerkey
WHERE 
    orderdate::DATE >= '01-01-2020'
LIMIT
    10;

-- 5) Add Product Info
%%sql

SELECT 
    s.orderdate,
    s.quantity * s.netprice * s.exchangerate AS net_revenue,
    c.givenname,
    c.surname,
    c.countryfull,
    c.continent,
    p.productkey,
    p.productname,
    p.categoryname,
    p.subcategoryname
FROM 
    sales s
LEFT JOIN customer c
    ON s.customerkey = c.custoerkey
LEFT JOIN product p
    ON s.productkey = p.productkey
WHERE 
    orderdate::DATE >= '01-01-2020'
LIMIT
    10

-- BASIC AGGREGATION
-- 6) High VS Low value ($1000USD)
%%sql

SELECT 
    s.orderdate,
    s.quantity * s.netprice * s.exchangerate AS net_revenue,
    c.givenname,
    c.surname,
    c.countryfull,
    c.continent,
    p.productkey,
    p.productname,
    p.categoryname,
    p.subcategoryname,
    CASE WHEN s.quantity * s.netprice * s.exchangerate > '1000' THEN 'High' ELSE 'Low' END AS High_Low
FROM 
    sales s
LEFT JOIN customer c
    ON s.customerkey = c.custoerkey
LEFT JOIN product p
    ON s.productkey = p.productkey
WHERE 
    orderdate::DATE >= '01-01-2020'
LIMIT
    10;

-- 7) Customer Count by OrderDare
%%sql

SELECT
    orderdate,
    COUNT(DISTINCT customerkey) AS total_customers
FROM
    sales
WHERE
    orderdate BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY
    orderdate
ORDER BY
    orderdate;

-- 8) Pivoting Data for COUNT Statement (CASE WHEN)
%%sql

SELECT
    s.orderdate,
    COUNT(DISTINCT s.customerkey) AS total_customers,
    COUNT(DISTINCT CASE WHEN c.continent = 'Europe' THEN s.customerkey END) AS eu_customers,
    COUNT(DISTINCT CASE WHEN c.continent = 'North America' THEN s.customerkey END) AS na_customers,
    COUNT(DISTINCT CASE WHEN c.continent = 'Australia' THEN s.customerkey END) AS au_customer
FROM
    sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey
WHERE
    s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY
    s.orderdate
ORDER BY
    s.orderdate;

-- 9) Pivoting Data for SUM Statement (CASE WHEN)
%%sql

SELECT
    p.categoryname,
    SUM(s.quantity * s.netprice * s.exchangerate) AS net_revenue,
    SUM(CASE WHEN s.orderdate BETWEEN '2022-01-01' AND '2022-12-31' 
             THEN s.quantity * s.netprice * s.exchangerate ELSE 0 END) AS total_net_revenue_2022,
    SUM(CASE WHEN s.orderdate BETWEEN '2023-01-01' AND '2023-12-31' 
             THEN s.quantity * s.netprice * s.exchangerate ELSE 0 END) AS total_net_revenue_2023
FROM
    sales s
LEFT JOIN product p ON s.productkey = p.productkey
GROUP BY
    p.categoryname
ORDER BY
    p.categoryname;

-- STATISTICAL AGGREGATION
-- 10) Pivoting Data for AVG, MIN & MAX Statement (CASE WHEN)
%%sql

SELECT
    p.categoryname AS category,
    AVG(CASE WHEN s.orderdate BETWEEN '2022-01-01' AND '2022-12-31' 
             THEN (s.quantity * s.netprice * s.exchangerate) END) AS avg_revenue_2022,
    AVG(CASE WHEN s.orderdate BETWEEN '2023-01-01' AND '2023-12-31' 
             THEN (s.quantity * s.netprice * s.exchangerate) END) AS avg_revenue_2023,
    MIN(CASE WHEN s.orderdate BETWEEN '2022-01-01' AND '2022-12-31' 
             THEN (s.quantity * s.netprice * s.exchangerate) END) AS min_revenue_2022,
    MIN(CASE WHEN s.orderdate BETWEEN '2023-01-01' AND '2023-12-31' 
             THEN (s.quantity * s.netprice * s.exchangerate) END) AS min_revenue_2023,
    MAX(CASE WHEN s.orderdate BETWEEN '2022-01-01' AND '2022-12-31' 
             THEN (s.quantity * s.netprice * s.exchangerate) END) AS max_revenue_2022,
    MAX(CASE WHEN s.orderdate BETWEEN '2023-01-01' AND '2023-12-31' 
             THEN (s.quantity * s.netprice * s.exchangerate) END) AS max_revenue_2023
FROM
    sales s
LEFT JOIN product p ON s.productkey = p.productkey
GROUP BY
    p.categoryname
ORDER BY
    p.categoryname;


-- 11) Pivoting Data for MEDIAN(PERCENTILE_CONT) Statement (CASE WHEN)
-- Median in Different Databases:

-- PostgreSQL → Use PERCENTILE_CONT(0.5)
-- SQL Server → Use PERCENTILE_CONT(0.5)
-- MySQL → No native MEDIAN(), requires subqueries or window functions
-- SQLite → No built-in MEDIAN(), requires custom logic
-- MariaDB → No built-in MEDIAN(), requires custom approach

%%sql

SELECT
    p.categoryname AS category,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY (CASE 
                    WHEN s.orderdate BETWEEN '2022-01-01' AND '2022-12-31' 
                    THEN (s.quantity * s.netprice * s.exchangerate) 
                  END)
    ) AS y2022_median_sales,
    
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY (CASE 
                    WHEN s.orderdate BETWEEN '2023-01-01' AND '2023-12-31' 
                    THEN (s.quantity * s.netprice * s.exchangerate) 
                  END)
    ) AS y2023_median_sales
FROM
    sales s
LEFT JOIN product p ON s.productkey = p.productkey
GROUP BY
    p.categoryname
ORDER BY
    p.categoryname;

-- ADVANCED SEGMENTATION
-- 12) Pivoting Data Using AND, OR and Multiple WHEN in CASE WHEN Statement
-- Problem - Categorize orders based on quantity and netprice:
-- "Multiple High Value Items" if quantity >= 2 and netprice >= 100
-- "Single High Value Item" if netprice >= 100
-- "Multiple Standard Items" if quantity >= 2
-- "Single Standard Item" otherwise
%%sql

SELECT
    orderdate,
    quantity,
    netprice,
    CASE
        WHEN quantity >= 2 AND netprice >= 100 THEN 'Multiple High Value Order'
        WHEN netprice >= 100 THEN 'Single High Value Item'
        WHEN quantity >= 2 THEN 'Multiple Standard Items'
        ELSE 'Single Standard Item'
    END AS order_type
FROM sales
LIMIT 10;

-- 13) Pivoting Data Using AND, OR and Multiple WHEN in CASE WHEN Statement with CTE
%%sql

-- Step 1: Create a CTE (Common Table Expression) to calculate the median value 
-- across all sales between 2022-01-01 and 2023-12-31 based on total revenue
WITH median_value AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY (s.quantity * s.netprice * s.exchangerate)
        ) AS median
    FROM
        sales s
    WHERE
        orderdate BETWEEN '2022-01-01' AND '2023-12-31'
)

-- Step 2: Use the median value from the CTE to classify each sale into 
-- high or low revenue for both 2022 and 2023
SELECT
    p.categoryname AS category,

    -- Total revenue < median for year 2022
    SUM(CASE 
            WHEN (s.quantity * s.netprice * s.exchangerate) < mv.median
                AND s.orderdate BETWEEN '2022-01-01' AND '2022-12-31'
            THEN (s.quantity * s.netprice * s.exchangerate)
        END) AS low_net_revenue_2022,

    -- Total revenue ≥ median for year 2022
    SUM(CASE 
            WHEN (s.quantity * s.netprice * s.exchangerate) >= mv.median
                AND s.orderdate BETWEEN '2022-01-01' AND '2022-12-31'
            THEN (s.quantity * s.netprice * s.exchangerate)
        END) AS high_net_revenue_2022,

    -- Total revenue < median for year 2023
    SUM(CASE 
            WHEN (s.quantity * s.netprice * s.exchangerate) < mv.median
                AND s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
            THEN (s.quantity * s.netprice * s.exchangerate)
        END) AS low_net_revenue_2023,

    -- Total revenue ≥ median for year 2023
    SUM(CASE 
            WHEN (s.quantity * s.netprice * s.exchangerate) >= mv.median
                AND s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
            THEN (s.quantity * s.netprice * s.exchangerate)
        END) AS high_net_revenue_2023

FROM
    sales s
    LEFT JOIN product p ON s.productkey = p.productkey,
    median_value mv  -- join with the CTE (acts like a cross join)

GROUP BY
    p.categoryname

ORDER BY
    p.categoryname;

-- 14) Multiple WHEN clause in a single CASE block
%%sql

-- Step 1: Create a CTE to calculate the 25th and 75th percentiles of total revenue
WITH percentiles AS (
    SELECT
        -- Calculate 25th percentile of total revenue
        PERCENTILE_CONT(0.25) WITHIN GROUP (
            ORDER BY (s.quantity * s.netprice * s.exchangerate)
        ) AS revenue_25th_percentile,

        -- Calculate 75th percentile of total revenue
        PERCENTILE_CONT(0.75) WITHIN GROUP (
            ORDER BY (s.quantity * s.netprice * s.exchangerate)
        ) AS revenue_75th_percentile

    FROM
        sales s
    WHERE
        orderdate BETWEEN '2022-01-01' AND '2023-12-31'
)

-- Step 2: Classify each order's total revenue into LOW, MEDIUM, or HIGH based on percentiles
SELECT
    p.categoryname AS category,

    -- Classify revenue tier per order:
    -- LOW if below or equal to 25th percentile
    -- HIGH if above or equal to 75th percentile
    -- Otherwise, MEDIUM
    CASE
        WHEN (s.quantity * s.netprice * s.exchangerate) <= pctl.revenue_25th_percentile THEN '1-LOW'
        WHEN (s.quantity * s.netprice * s.exchangerate) >= pctl.revenue_75th_percentile THEN '3-HIGH'
        ELSE '2-MEDIUM'
    END AS revenue_tier,

    -- Sum of revenue for each group
    SUM(s.quantity * s.netprice * s.exchangerate) AS total_revenue

FROM
    sales s
    LEFT JOIN product p ON s.productkey = p.productkey,
    percentiles pctl  -- join the percentiles CTE like a cross join

GROUP BY
    p.categoryname,
    revenue_tier

ORDER BY
    p.categoryname,
    revenue_tier;