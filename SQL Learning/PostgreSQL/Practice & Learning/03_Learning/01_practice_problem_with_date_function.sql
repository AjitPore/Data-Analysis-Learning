--PROBLEM- Create Tables For first 3 months job Posting

--Jan
CREATE TABLE jan_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 1;

--feb
CREATE TABLE feb_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 2;

--march
CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 3;

--To See Results
SELECT *
FROM jan_jobs;

--Removed Created Tables
DROP TABLE jan_jobs;
DROP TABLE feb_jobs;
DROP TABLE march_jobs;