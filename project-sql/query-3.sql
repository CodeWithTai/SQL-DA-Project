/* Question 3:
Which companies are the biggest employers, and are they good-paying ones? Top 10 companies by posting count, alongside median and average salary
*/


SELECT
    job_postings_fact.job_title_short AS job_title,
    company_dim.name AS company_name,
    COUNT(job_postings_fact.job_id) AS num_postings,
    COUNT(job_postings_fact.salary_year_avg) AS postings_with_salary,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY job_postings_fact.salary_year_avg)::numeric, 0) AS median_salary,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY
    job_postings_fact.job_title_short,
    company_dim.name
ORDER BY
    num_postings DESC
LIMIT 10;

/* Notes (results run 2026-10-30):
Type of each top-10 poster:
- Staffing agency (5): Robert Half, Insight Global, Get It Recruit - Information Technology, Michael Page, Randstad
- Job board (2): Emprego, Dice
- Anonymous employer (1): Confidenziale ("confidential" in Italian)
- Direct employer (2): Citi, UnitedHealth Group
So 8 of the top 10 are not direct employers.

Salary data is thin: Emprego and Confidenziale list no salary; Dice (1), Randstad (3), Michael Page (5)
and UnitedHealth Group (7) list too few to compare.
Only 4 have at least 30 postings with salary:
- Citi: median $125,540 (n=90)
- Insight Global: median $92,500 (n=96)
- Robert Half: median $87,500 (n=108)
- Get It Recruit: median $84,000 (n=139)
*/
