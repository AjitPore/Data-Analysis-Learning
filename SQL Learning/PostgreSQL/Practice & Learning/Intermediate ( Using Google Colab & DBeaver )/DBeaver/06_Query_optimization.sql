-- EXPLAIN ANALYZE

EXPLAIN ANALYZE
SELECT
  customerkey,
  SUM(quantity * netprice * exchangerate) AS net_revenue
FROM SALES
GROUP BY customerkey;



-- EXPLAIN

EXPLAIN
SELECT
  customerkey,
  SUM(quantity * netprice * exchangerate) AS net_revenue
FROM SALES
GROUP BY customerkey;