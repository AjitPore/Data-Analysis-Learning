WITH customer_revenue AS (
  SELECT
    s.customerkey,
    s.orderdate,
    SUM(s.quantity::double precision * s.netprice * s.exchangerate) AS total_net_revenue,
    COUNT(s.orderkey) AS num_orders,
    c.countryfull,
    c.age,
    c.givenname,
    c.surname
  FROM sales s
  LEFT JOIN customer c ON c.customerkey = s.customerkey
  GROUP BY
    s.customerkey,
    s.orderdate,
    c.countryfull,
    c.age,
    c.givenname,
    c.surname
)
SELECT
  customerkey,
  orderdate,
  total_net_revenue,
  num_orders,
  countryfull,
  age,
  CONCAT(TRIM(givenname), ' ', TRIM(surname)) AS cleaned_name, -- Merge Two Columns
  MIN(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
  EXTRACT(year FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM customer_revenue cr;