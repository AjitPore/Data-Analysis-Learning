SELECT 
   COUNT (job_id) AS count_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS job_location_category
FROM
    job_postings_fact
WHERE 
    job_title = 'Data Analyst'
GROUP BY 
    job_location_category;