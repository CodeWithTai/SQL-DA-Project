/* Question 4:
Which skills are most often requested together? Top 10 skill pairs for Data Analyst postings
*/

SELECT
    skills1.skills AS skill_a,
    skills2.skills AS skill_b,
    job_postings_fact.job_title_short AS job_title,
    COUNT(*) AS pair_count
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

/* Insights:
1. SQL anchors nearly every top pairing
2. SQL + Python is the single strongest pairing by a wide margin
3. A visible cluster forms around "SQL + a visualization tool: Tableau, Power BI, or Excel
4. Python pairs with R almost as often as with SQL-adjacent tools


[
  {
    "skill_a": "sql",
    "skill_b": "python",
    "job_title": "Data Analyst",
    "pair_count": "44630"
  },
  {
    "skill_a": "sql",
    "skill_b": "tableau",
    "job_title": "Data Analyst",
    "pair_count": "34434"
  },
  {
    "skill_a": "sql",
    "skill_b": "excel",
    "job_title": "Data Analyst",
    "pair_count": "34254"
  },
  {
    "skill_a": "sql",
    "skill_b": "power bi",
    "job_title": "Data Analyst",
    "pair_count": "26424"
  },
  {
    "skill_a": "python",
    "skill_b": "r",
    "job_title": "Data Analyst",
    "pair_count": "25588"
  },
  {
    "skill_a": "python",
    "skill_b": "tableau",
    "job_title": "Data Analyst",
    "pair_count": "23233"
  },
  {
    "skill_a": "sql",
    "skill_b": "r",
    "job_title": "Data Analyst",
    "pair_count": "22395"
  },
  {
    "skill_a": "sql",
    "skill_b": "sas",
    "job_title": "Data Analyst",
    "pair_count": "19666"
  },
  {
    "skill_a": "excel",
    "skill_b": "tableau",
    "job_title": "Data Analyst",
    "pair_count": "18803"
  },
  {
    "skill_a": "excel",
    "skill_b": "power bi",
    "job_title": "Data Analyst",
    "pair_count": "17847"
  }
]
*/