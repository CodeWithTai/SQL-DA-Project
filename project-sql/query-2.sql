/* Question 2:
    Does mentioning health insurance correlate with pay?
    Note: job_health_insurance = TRUE means the posting MENTIONS health insurance.
    FALSE means it doesn't mention it, not that the job has no health insurance.
*/
SELECT
    job_title_short AS job_title,
    job_health_insurance,
    COUNT(salary_year_avg) AS postings_with_salary,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_year_avg)::numeric, 0) AS median_salary,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary,
    MIN(salary_year_avg) AS min_salary,
    MAX(salary_year_avg) AS max_salary
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
GROUP BY
    job_title_short,
    job_health_insurance
ORDER BY
    job_health_insurance DESC;

/* Notes (results run 2026-10-30):
1. Mentions health insurance: 2,322 postings with salary, median $90,000, average $95,550.
   Doesn't mention it:        3,141 postings with salary, median $90,000, average $92,638.
2. The averages differ by $2,912 (about 3%), but the medians are the same. No clear pay difference.
3. The $650K max is in the "doesn't mention" group.
*/
