/* Question 4:
Which skills are most often requested together? Top 10 skill pairs for Data Analyst postings
*/

SELECT
    skills1.skills AS skill_a,
    skills2.skills AS skill_b,
    job_postings_fact.job_title_short AS job_title,
    COUNT(*) AS pair_count,
    -- each (job_id, skill_id) row is unique, so pair_count = number of postings with both skills
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM job_postings_fact WHERE job_title_short = 'Data Analyst'), 1) AS pct_of_postings
FROM
    skills_job_dim sjd1
INNER JOIN skills_job_dim sjd2
    ON sjd1.job_id = sjd2.job_id
    AND sjd1.skill_id < sjd2.skill_id
INNER JOIN skills_dim skills1 ON sjd1.skill_id = skills1.skill_id
INNER JOIN skills_dim skills2 ON sjd2.skill_id = skills2.skill_id
INNER JOIN job_postings_fact ON sjd1.job_id = job_postings_fact.job_id
WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY
    skills1.skills,
    skills2.skills,
    job_postings_fact.job_title_short
ORDER BY
    pair_count DESC
LIMIT 10;

/* Notes (results run 2026-10-30):
1. SQL + Python is the top pair: 44,630 postings (22.7% of 196,593 Data Analyst postings).
2. #2 is SQL + Tableau with 34,434 (17.5%), so the gap is 10,196 postings (5.2 percentage points).
   #2 and #3 (SQL + Excel, 34,254) are only 180 postings apart.
3. SQL is in 6 of the top 10 pairs.
4. Python + R (25,588, 13.0%) is the top pair without SQL.
*/
