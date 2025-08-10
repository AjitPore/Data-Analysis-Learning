WITH sales_data AS (
  SELECT
    customerkey,
    SUM(quantity * netprice * exchangerate) AS net_revenue
  FROM sales
  GROUP BY
    customerkey
)
SELECT
  c.customerkey,
  s.net_revenue,
  COALESCE(s.net_revenue, 0)
FROM customer c
LEFT JOIN sales_data s ON c.customerkey = s.customerkey;