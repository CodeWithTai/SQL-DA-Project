/* Question 1:
    What's the realistic entry point?
*/
SELECT
    job_title_short AS job_title,
    job_health_insurance,
    COUNT(job_id) AS num_postings,
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

/* Insights:
1. Postings mentioning health insurance pay ~$2,912 more on average
2. Slightly more postings don't mention insurance (3,141 vs 2,322) — worth noting that a meaningful chunk of Data Analyst postings simply don't disclose or offer this benefit at all.
3. The $650K max sits in the "no insurance" group
4. A ~3% gap is small enough to call roughly "no strong relationship"


[
  {
    "job_title": "Data Analyst",
    "job_health_insurance": true,
    "num_postings": "2322",
    "avg_salary": "95550",
    "min_salary": "25000.0",
    "max_salary": "375000.0"
  },
  {
    "job_title": "Data Analyst",
    "job_health_insurance": false,
    "num_postings": "3141",
    "avg_salary": "92638",
    "min_salary": "25920.0",
    "max_salary": "650000.0"
  }
] */