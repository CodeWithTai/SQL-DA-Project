/* Question 4:
Which skills are most often requested together? Top 10 skill pairs for Data Analyst postings
*/

-- One row per (posting, skill NAME). skills_dim can hold the same skill name under more than one skill_id,
-- so pairing by skill_id would count the same pair of names twice. DISTINCT collapses those duplicates.
WITH da_skills AS (
    SELECT DISTINCT
        skills_job_dim.job_id,
        skills_dim.skills AS skill_name
    FROM
        skills_job_dim
    INNER JOIN skills_dim
        ON skills_job_dim.skill_id = skills_dim.skill_id
    INNER JOIN job_postings_fact
        ON skills_job_dim.job_id = job_postings_fact.job_id
    WHERE
        job_postings_fact.job_title_short = 'Data Analyst'
)

SELECT
    skills1.skill_name AS skill_a,
    skills2.skill_name AS skill_b,
    'Data Analyst' AS job_title,
    COUNT(*) AS pair_count,
    -- each (job_id, skill_name) row is unique, so pair_count = number of postings with both skills
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM job_postings_fact WHERE job_title_short = 'Data Analyst'), 1) AS pct_of_postings
FROM
    da_skills skills1
INNER JOIN da_skills skills2
    ON skills1.job_id = skills2.job_id
    AND skills1.skill_name < skills2.skill_name
GROUP BY
    skills1.skill_name,
    skills2.skill_name
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
