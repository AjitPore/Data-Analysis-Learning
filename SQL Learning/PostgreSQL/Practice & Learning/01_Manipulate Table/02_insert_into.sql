INSERT INTO job_applied (
    job_id, 
    application_sent_date, 
    custom_resume, 
    resume_file_name, 
    cover_letter_sent, 
    cover_letter_name, 
    status
)

values (
    1,
    '12/03/2025',
    True,
    'resume_01',
    True,
    'cover_letter_01',
    'Submitted'
),
(
    2,
    '13/03/2025',
    False,
    '',
    True,
    'cover_letter_02',
    'Under Process'
),
(
    3,
    '14/03/2025',
    True,
    'resume_03',
    True,
    'cover_letter_03',
    'Submitted'
),
(
    4,
    '15/03/2025',
    True,
    'resume_04',
    True,
    'cover_letter_04',
    'Submitted'
),
(
    5,
    '16/03/2025',
    False,
    'RESUME',
    True,
    'cover_letter_05',
    'Interview Scheduled'
);

SELECT *
FROM job_applied;