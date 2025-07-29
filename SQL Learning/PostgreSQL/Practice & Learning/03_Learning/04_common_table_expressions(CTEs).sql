-- Example 1
WITH feb_jobs AS ( -- CTE Defination start here
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 1
) -- CTE defination end here

SELECT *
FROM feb_jobs;


-- Exampple 2
-- Find the companies that have the most job openings.
-- Get the total number of job postings per company id (job_postings_fact)
-- Return the total number of jobs with the company name (company_dim)

WITH company_job_count AS (
    SELECT 
        company_id, 
        COUNT(*) 
    FROM 
        job_postings_fact
    GROUP BY 
        company_id
)
SELECT 
    name
FROM 
    company_dim
LEFT JOIN 
    company_job_count 
ON 
    company_job_count.company_id = company_dim.company_id;
