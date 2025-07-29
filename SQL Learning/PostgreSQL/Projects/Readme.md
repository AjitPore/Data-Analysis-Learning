# 📁 Projects — Data Science Job Market Analysis (2023)

This folder contains real-world SQL projects focused on analyzing the **Data Science job market in 2023**.  
Each SQL file explores key trends such as salary insights, in-demand skills, and optimal tools for Data Analysts.

---

## 1️⃣ Top Paying Data Analyst Jobs

**Objective:**  
Identify the top 10 highest-paying remote Data Analyst roles with specified salaries and company names.

```sql
SELECT	
	job_id,
	job_title,
	job_location,
	job_schedule_type,
	salary_year_avg,
	job_posted_date,
    name AS company_name
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short = 'Data Analyst'
  AND job_location = 'Anywhere'
  AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
```

**🔹 Result Summary:**

| Company Name                   | Job Title                                      | Salary ($) | Posted Date         |
|-------------------------------|------------------------------------------------|------------|---------------------|
| Mantys                        | Data Analyst                                   | 650,000    | 2023-02-20          |
| Meta                          | Director of Analytics                          | 336,500    | 2023-08-23          |
| AT&T                          | Associate Director- Data Insights              | 255,829    | 2023-06-18          |
| Pinterest Job Advertisements  | Data Analyst, Marketing                        | 232,423    | 2023-12-05          |
| UCLA Healthcareers            | Data Analyst (Hybrid/Remote)                   | 217,000    | 2023-01-17          |

**💡 Insight:**  
Top salaries range from **$184K to $650K**, including high-level roles like **Director of Analytics**.

---

## 2️⃣ Top Paying Job Skills

**Objective:**  
Find out which skills are required in the top 10 highest-paying Data Analyst jobs.

```sql
WITH top_paying_jobs AS (
    SELECT job_id, job_title, salary_year_avg, name AS company_name
    FROM job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE job_title_short = 'Data Analyst'
      AND job_location = 'Anywhere'
      AND salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 10
)
SELECT top_paying_jobs.*, skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY salary_year_avg DESC;
```

**🔹 Most Common Skills:**

| Skill     | Occurrences |
|-----------|-------------|
| SQL       | 8           |
| Python    | 7           |
| Tableau   | 6           |
| R         | 3           |
| Excel     | 3           |

**💡 Insight:**  
Focus on mastering **SQL, Python, and Tableau** to qualify for high-paying roles.

---

## 3️⃣ Top Demanded Skills in the Market

**Objective:**  
Identify the top 5 most in-demand skills for Data Analysts across all job postings.

```sql
SELECT skills, COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst'
  AND job_work_from_home = True 
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 5;
```

**🔹 Top 5 In-Demand Skills:**

| Skill     | Demand Count |
|-----------|---------------|
| SQL       | 7291          |
| Excel     | 4611          |
| Python    | 4330          |
| Tableau   | 3745          |
| Power BI  | 2609          |

**💡 Insight:**  
These foundational tools are critical for landing remote data analyst roles in 2023.

---

## 4️⃣ Top Paying Skills

**Objective:**  
Discover which skills lead to the highest average salaries for Data Analyst roles.

```sql
SELECT skills, ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst'
  AND salary_year_avg IS NOT NULL
  AND job_work_from_home = True 
GROUP BY skills
ORDER BY avg_salary DESC
LIMIT 25;
```

**🔹 Top 5 Paying Skills:**

| Skill       | Avg Salary ($) |
|-------------|----------------|
| PySpark     | 208,172        |
| Bitbucket   | 189,155        |
| Couchbase   | 160,515        |
| Watson      | 160,515        |
| DataRobot   | 155,486        |

**💡 Insight:**  
Specialized tools like **PySpark**, **DataRobot**, and **Bitbucket** offer strong financial rewards.

---

## 5️⃣ Optimal Skills to Learn (High Demand + High Salary)

**Objective:**  
Identify skills that are both **in high demand** and **offer high salaries**.

```sql
SELECT 
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst'
  AND salary_year_avg IS NOT NULL
  AND job_work_from_home = True 
GROUP BY skills_dim.skill_id
HAVING COUNT(skills_job_dim.job_id) > 10
ORDER BY avg_salary DESC, demand_count DESC
LIMIT 25;
```

**🔹 Top 5 Optimal Skills:**

| Skill      | Demand Count | Avg Salary ($) |
|------------|---------------|----------------|
| Go         | 27            | 115,320        |
| Confluence | 11            | 114,210        |
| Hadoop     | 22            | 113,193        |
| Snowflake  | 37            | 112,948        |
| Azure      | 34            | 111,225        |

**💡 Insight:**  
Learning tools like **Snowflake**, **Azure**, **Go**, and **Hadoop** can give you both job security and high income.

---

> 📊 All queries executed using **VSCode with PostgreSQL**  
> 🧠 Data insights are based on job postings from 2023  
> 📝 Each SQL file is documented for clarity and reproducibility
