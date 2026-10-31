/* Question 5:
Optimal skills for beginners — which skills give the best return (high demand + not gated to senior-sounding titles)
*/

-- Filter check: how many Data Analyst postings each seniority word removes.
-- Whole-word match (\m ... \M) so "CSR", "Staffordshire", "Headquartered" or "Directory" are not removed.
SELECT
    seniority_word,
    COUNT(*) AS postings_excluded
FROM
    job_postings_fact
CROSS JOIN (VALUES ('senior'), ('sr'), ('lead'), ('leader'), ('teamlead'), ('principal'), ('staff'), ('manager'), ('head'), ('director')) AS words(seniority_word)
WHERE
    job_title_short = 'Data Analyst'
    AND job_title ~* ('\m' || seniority_word || '\M')
GROUP BY
    seniority_word
ORDER BY
    postings_excluded DESC;

-- Entry-level skills: demand counts ALL entry-level postings, salary stats use only postings with a salary
WITH entry_level_postings AS (
    SELECT
        job_id,
        job_title_short,
        salary_year_avg
    FROM
        job_postings_fact
    WHERE
        job_title_short = 'Data Analyst'
        AND job_title !~* '\m(senior|sr|lead|leader|teamlead|principal|staff|manager|head|director)\M'
),

skill_stats AS (
    SELECT
        entry_level_postings.job_title_short,
        skills_dim.skills AS skill_name,
        COUNT(skills_job_dim.job_id) AS demand_count,
        COUNT(entry_level_postings.salary_year_avg) AS postings_with_salary,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY entry_level_postings.salary_year_avg)::numeric, 0) AS median_salary,
        ROUND(AVG(entry_level_postings.salary_year_avg), 0) AS avg_salary
    FROM
        entry_level_postings
    INNER JOIN skills_job_dim
        ON entry_level_postings.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim
        ON skills_job_dim.skill_id = skills_dim.skill_id
    GROUP BY
        entry_level_postings.job_title_short,
        skills_dim.skills
)

SELECT
    job_title_short AS job_title,
    skill_name,
    demand_count,
    ROUND(demand_count * 100.0 / (SELECT COUNT(*) FROM entry_level_postings), 1) AS pct_of_postings,
    postings_with_salary,
    -- salaries are only compared when at least 30 postings list one
    CASE WHEN postings_with_salary >= 30 THEN median_salary END AS median_salary,
    CASE WHEN postings_with_salary >= 30 THEN avg_salary END AS avg_salary
FROM
    skill_stats
ORDER BY
    demand_count DESC
LIMIT 15;

-- Baseline: top 15 skills for ALL Data Analyst postings (no filter)
SELECT
    skills_dim.skills AS skill_name,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(COUNT(skills_job_dim.job_id) * 100.0 / (SELECT COUNT(*) FROM job_postings_fact WHERE job_title_short = 'Data Analyst'), 1) AS pct_of_postings,
    COUNT(job_postings_fact.salary_year_avg) AS postings_with_salary,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY job_postings_fact.salary_year_avg)::numeric, 0) AS median_salary
FROM
    job_postings_fact
INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY
    skills_dim.skills
ORDER BY
    demand_count DESC
LIMIT 15;

/* Notes (results run 2026-10-30):
1. Bug fixed: demand_count used to count only postings with a salary (SQL was 2,836).
   It now counts all entry-level postings (SQL: 83,567). Salary columns still use only postings with a salary.
2. The seniority filter keeps 179,589 of 196,593 Data Analyst postings (91.4%) and removes 17,004.
   Whole-word matching is used because plain ILIKE '%...%' removed titles like "CSR Data Analyst",
   "Staffordshire", "Headquartered" and "Money Market Directories".
   Compared with the old filter (senior/lead/principal/staff), the new words remove 8,157 more postings:
   manager 4,680, sr 2,625, director 575, head 303.
3. Entry-level top 5 by % of postings: SQL 46.5%, Excel 34.8%, Python 28.7%, Tableau 23.1%, Power BI 20.2%.
4. Baseline (all Data Analyst postings, no filter) has the same top 15 in the same order
   (SQL 47.1%, Excel 34.1%, Python 29.2%, Tableau 23.7%, Power BI 20.1%).
   The no-degree list in query-1 has the same top 5. These are the core Data Analyst skills,
   not something special to beginners. Entry-level postings are 91.4% of the total, so the filter changes little.
5. Median salary in entry-level postings (all top 15 have at least 30 postings with salary):
   highest: AWS $100,000 (n=236), Azure $98,038 (n=261), Python $95,000 (n=1,556)
   lowest:  Word $76,650 (n=467), Excel $80,850 (n=1,920), PowerPoint $81,682 (n=455)
   SQL and Tableau are both $90,000 (n=2,659 and n=1,421).
6. "go" is likely noisy: the tag can come from the plain word "go" in posting text.
*/
