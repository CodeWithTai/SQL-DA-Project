/* Question 5:
Optimal skills for beginners — which skills give the best return (high demand + not gated to senior-sounding titles)
*/

WITH entry_level_postings AS (
    SELECT
        job_id,
        job_title_short
    FROM
        job_postings_fact
    WHERE
        job_title_short = 'Data Analyst'
        AND job_title NOT ILIKE '%senior%'
        AND job_title NOT ILIKE '%lead%'
        AND job_title NOT ILIKE '%principal%'
        AND job_title NOT ILIKE '%staff%'
),

skill_stats AS (
    SELECT
        entry_level_postings.job_title_short,
        skills_dim.skills AS skill_name,
        COUNT(skills_job_dim.job_id) AS demand_count,
        ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
    FROM
        entry_level_postings
    INNER JOIN skills_job_dim
        ON entry_level_postings.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim
        ON skills_job_dim.skill_id = skills_dim.skill_id
    INNER JOIN job_postings_fact
        ON entry_level_postings.job_id = job_postings_fact.job_id
    WHERE
        job_postings_fact.salary_year_avg IS NOT NULL
    GROUP BY
        entry_level_postings.job_title_short,
        skills_dim.skills
)

SELECT
    job_title_short AS job_title,
    skill_name,
    demand_count,
    avg_salary
FROM
    skill_stats
WHERE
    demand_count > 100
ORDER BY
    demand_count DESC,
    avg_salary DESC
LIMIT 15;


/* Insights
1. SQL wins on demand again — this time under a different, independent filter. Comparing this to Question 1's "no degree required" list: both lists put SQL, Excel, Python, Tableau, and Power BI in the top 5, in almost the exact same order. That's a meaningful validation point for your write-up — two completely different definitions of "beginner-accessible" (no-degree-mentioned vs. non-senior-titled) converge on the same core skill set. That's a stronger, more credible finding than either list alone, since it's not an artifact of one particular filter choice.
2. Excel has the lowest average salary among the top 5 ($84,441) despite being the #2 most in-demand skill.
3. Python and Tableau pay noticeably more than SQL despite lower demand ($98,495 and $95,494 vs. SQL's $93,918).
4. Word and PowerPoint cracking the top 10 is a bit of a surprise — a reminder that "Data Analyst" postings still expect basic office/communication tooling, not just technical skills.

[
  {
    "job_title": "Data Analyst",
    "skill_name": "sql",
    "demand_count": "2836",
    "avg_salary": "93918"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "excel",
    "demand_count": "2025",
    "avg_salary": "84441"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "python",
    "demand_count": "1652",
    "avg_salary": "98495"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "tableau",
    "demand_count": "1532",
    "avg_salary": "95494"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "power bi",
    "demand_count": "983",
    "avg_salary": "90825"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "r",
    "demand_count": "958",
    "avg_salary": "95294"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "sas",
    "demand_count": "874",
    "avg_salary": "90476"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "word",
    "demand_count": "501",
    "avg_salary": "81379"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "powerpoint",
    "demand_count": "489",
    "avg_salary": "86023"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "sql server",
    "demand_count": "309",
    "avg_salary": "93730"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "oracle",
    "demand_count": "293",
    "avg_salary": "97363"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "azure",
    "demand_count": "287",
    "avg_salary": "103104"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "aws",
    "demand_count": "258",
    "avg_salary": "103769"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "go",
    "demand_count": "258",
    "avg_salary": "92288"
  },
  {
    "job_title": "Data Analyst",
    "skill_name": "flow",
    "demand_count": "245",
    "avg_salary": "96086"
  }
] */