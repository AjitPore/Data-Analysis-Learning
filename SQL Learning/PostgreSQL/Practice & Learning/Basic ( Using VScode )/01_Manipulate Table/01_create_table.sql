CREATE TABLE job_applied (
    job_id INT,
    application_sent_date DATE,
    custom_resume BOOLEAN,
    resume_file_name VARCHAR(250),
    cover_letter_sent BOOLEAN,
    cover_letter_name VARCHAR(250),
    status VARCHAR(50)
);

SELECT *
FROM job_applied;