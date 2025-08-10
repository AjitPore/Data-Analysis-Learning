SELECT
  cohort_year,
  SUM(total_net_revenue)
FROM
  cohort_analysis
GROUP BY
  cohort_year;