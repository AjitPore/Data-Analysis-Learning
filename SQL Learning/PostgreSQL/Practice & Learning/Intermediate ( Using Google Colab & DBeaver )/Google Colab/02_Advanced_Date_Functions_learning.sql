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

-- 2) Using DATE TRUNC
%%sql

SELECT
  orderdate,
  DATE_TRUNC('month', orderdate)::date AS order_month
FROM sales
ORDER BY RANDOM()
LIMIT 10;

-- 3) Using DATE TRUNC
%%sql

SELECT
  DATE_TRUNC('month', orderdate)::date AS order_month,
  SUM(quantity * netprice * exchangerate) AS net_revenue,
  COUNT(DISTINCT customerkey) AS total_unique_customers
FROM sales
GROUP BY
  order_month
LIMIT 10;

-- 4) Using TO_CHAR
%%sql

SELECT
  TO_CHAR(orderdate, 'YYYY-MM') AS order_month,
  SUM(quantity * netprice * exchangerate) AS net_revenue,
  COUNT(DISTINCT customerkey) AS total_unique_customers
FROM sales
GROUP BY
  order_month;

-- 5) DATE_PART
%%sql

SELECT
  orderdate,
  DATE_PART('year', orderdate) AS order_year,
  DATE_PART('month', orderdate) AS order_month,
  DATE_PART('day', orderdate) AS order_day
FROM sales
ORDER BY RANDOM()
LIMIT 10;

-- 6) EXTRACT
%%sql

SELECT
  orderdate,
  EXTRACT(YEAR FROM orderdate) AS extract_year,
  EXTRACT(MONTH FROM orderdate) AS extract_month,
  EXTRACT(DAY FROM orderdate) AS extract_day
FROM sales
ORDER BY RANDOM()
LIMIT 10;

-- 7) 
%%sql

SELECT
  CURRENT_DATE, -- CURRENT_DATE is a SQL function that returns the current date without the time component.
  EXTRACT(YEAR FROM orderdate) AS order_year,
  EXTRACT(YEAR FROM CURRENT_DATE) AS current_year,
  EXTRACT(YEAR FROM CURRENT_DATE) - 5 AS minus_five,
  s.orderdate,
  p.categoryname,
  SUM(s.quantity * s.netprice * s.exchangerate) AS net_revenue
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
WHERE
  EXTRACT(YEAR FROM orderdate) >= EXTRACT(YEAR FROM CURRENT_DATE) - 5
GROUP BY
  s.orderdate,
  p.categoryname
ORDER BY
  s.orderdate,
  p.categoryname;

-- 8) Final result of 7th query (above)
%%sql

SELECT
  s.orderdate,
  p.categoryname,
  SUM(s.quantity * s.netprice * s.exchangerate) AS net_revenue
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
WHERE
  EXTRACT(YEAR FROM orderdate) >= EXTRACT(YEAR FROM CURRENT_DATE) - 5
GROUP BY
  s.orderdate,
  p.categoryname
ORDER BY
  s.orderdate,
  p.categoryname;

-- 8) INTERVAL
%%sql

SELECT
  CURRENT_DATE,
  s.orderdate,
  p.categoryname,
  SUM(s.quantity * s.netprice * s.exchangerate) AS net_revenue
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
WHERE
  orderdate >= CURRENT_DATE - INTERVAL '5 years'
GROUP BY
  s.orderdate,
  p.categoryname
ORDER BY
  s.orderdate,
  p.categoryname;

-- 9) total sales revenue and average processing time by year
%%sql

-- Select order year, average processing time, and total net revenue for the past 5 years
SELECT
    -- Extract the year from the order date
    DATE_PART('year', orderdate) AS order_year,

    -- Calculate average processing time in days between order and delivery, rounded to 2 decimals
    ROUND(AVG(EXTRACT(DAYS FROM AGE(deliverydate, orderdate))), 2) AS avg_processing_time,

    -- Calculate net revenue = quantity * netprice * exchange rate, casted to integer
    CAST(SUM(quantity * netprice * exchangerate) AS INTEGER) AS net_revenue

FROM
    sales

-- Only include orders from the last 5 years
WHERE
    orderdate >= CURRENT_DATE - INTERVAL '5 years'

-- Group the data by year of order
GROUP BY
    order_year

-- Order the results by year ascending
ORDER BY
    order_year;
