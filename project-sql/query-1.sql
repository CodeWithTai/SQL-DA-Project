/*
-Question:
What's the realistic entry point?
-Answer:
Find the salary range,
most common titles,
and top requested skills specifically for postings where no degree requirement is mentioned (Google Jobs' "No degree mentioned" tag)
*/


CREATE TEMP TABLE no_degree_da_jobs AS
SELECT *
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
  AND job_no_degree_mention = TRUE;

-- Salary range
SELECT
    job_title_short AS job_title,
    COUNT(job_id) AS num_postings,
    COUNT(salary_year_avg) AS postings_with_salary,
    MIN(salary_year_avg) AS min_salary,
    MAX(salary_year_avg) AS max_salary,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_year_avg)::numeric, 0) AS median_salary,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM no_degree_da_jobs
GROUP BY job_title_short;

-- No-degree postings vs all other Data Analyst postings
SELECT
    CASE WHEN job_no_degree_mention IS TRUE THEN 'No degree mentioned' ELSE 'All other' END AS posting_group,
    COUNT(job_id) AS num_postings,
    COUNT(salary_year_avg) AS postings_with_salary,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_year_avg)::numeric, 0) AS median_salary,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY posting_group;

-- Most common titles
SELECT
    job_title_short,
    job_title,
    COUNT(job_id) AS posting_count
FROM no_degree_da_jobs
GROUP BY job_title_short, job_title
ORDER BY posting_count DESC
LIMIT 10;

-- Top requested skills
SELECT
    no_degree_da_jobs.job_title_short,
    skills_dim.skills AS skill_name,
    COUNT(skills_job_dim.job_id) AS skill_count,
    ROUND(COUNT(skills_job_dim.job_id) * 100.0 / (SELECT COUNT(*) FROM no_degree_da_jobs), 1) AS pct_of_postings
FROM no_degree_da_jobs
INNER JOIN skills_job_dim ON no_degree_da_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
GROUP BY no_degree_da_jobs.job_title_short, skills_dim.skills
ORDER BY skill_count DESC
LIMIT 10;

/* Notes (results run 2026-10-30):
1. 76,057 of 196,593 Data Analyst postings (38.7%) mention no degree. Only 1,236 of them (1.6%) list a salary.
2. Median salary is the same for both groups: $90,000 for no-degree postings (n=1,236 with salary)
   and $90,000 for all other postings (n=4,227). Averages: $92,951 vs $94,146.
3. Salary range for no-degree postings: $26,444 to $650,000. The $650K value is likely an outlier.
4. Most titles are generic "Data Analyst" (18,603), but "Lead Data Analyst" (397) and "Data Architect" (389)
   are also in the top 10, so these postings are not only junior roles.
5. Top skills (% of no-degree postings): SQL 42.0%, Excel 27.0%, Python 22.8%, Tableau 18.5%, Power BI 17.7%.
6. job_no_degree_mention only says what the posting text says. It does not tell us who actually gets hired.
*/
