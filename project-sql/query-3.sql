/* Question 3: 
Which companies are the biggest employers, and are they good-paying ones? Top 10 companies by posting count, alongside average salary
*/


SELECT
    job_postings_fact.job_title_short AS job_title,
    company_dim.name AS company_name,
    COUNT(job_postings_fact.job_id) AS num_postings,
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

/* Insights:
1. Two NULLs are worth calling out, not hiding. Emprego (#1 by volume!)
2. Several of the top postings are staffing/recruiting agencies, not direct employers
3. Citi stands out as the one high-volume AND high-paying company
4. Staffing agencies cluster in the $87K–$107K range */



/*[
  {
    "job_title": "Data Analyst",
    "company_name": "Emprego",
    "num_postings": "1121",
    "avg_salary": null
  },
  {
    "job_title": "Data Analyst",
    "company_name": "Robert Half",
    "num_postings": "1047",
    "avg_salary": "89111"
  },
  {
    "job_title": "Data Analyst",
    "company_name": "Insight Global",
    "num_postings": "892",
    "avg_salary": "92801"
  },
  {
    "job_title": "Data Analyst",
    "company_name": "Citi",
    "num_postings": "875",
    "avg_salary": "121509"
  },
  {
    "job_title": "Data Analyst",
    "company_name": "Dice",
    "num_postings": "604",
    "avg_salary": "107500"
  },
  {
    "job_title": "Data Analyst",
    "company_name": "UnitedHealth Group",
    "num_postings": "592",
    "avg_salary": "103464"
  },
  {
    "job_title": "Data Analyst",
    "company_name": "Confidenziale",
    "num_postings": "549",
    "avg_salary": null
  },
  {
    "job_title": "Data Analyst",
    "company_name": "Get It Recruit - Information Technology",
    "num_postings": "510",
    "avg_salary": "87489"
  },
  {
    "job_title": "Data Analyst",
    "company_name": "Michael Page",
    "num_postings": "468",
    "avg_salary": "97000"
  },
  {
    "job_title": "Data Analyst",
    "company_name": "Randstad",
    "num_postings": "462",
    "avg_salary": "92500"
  }
] */