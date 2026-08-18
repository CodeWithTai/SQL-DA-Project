# Breaking Into Data Analytics: What the Job Market Actually Rewards

A SQL-based analysis of real-world Data Analyst job postings, built to answer the
questions I actually had as a self-taught, no-degree career changer: what does
this market really pay, reward, and require — and where should I focus first?

## Dataset

Built on the open [`data_jobs`](https://github.com/lukebarousse/data_jobs) dataset
(job postings scraped from Google Jobs), loaded into a local PostgreSQL database.

| Table | Contents |
|---|---|
| `job_postings_fact` | One row per posting — title, salary, location, remote flag, benefits flags, posted date |
| `company_dim` | Company names |
| `skills_dim` | Skill reference table |
| `skills_job_dim` | Bridge table linking postings to required skills |

## Tools

PostgreSQL · SQL (CTEs, subqueries, self-joins, aggregate functions, temp tables)

## Questions

| # | Question | File |
|---|---|---|
| 1 | What's the realistic entry point for postings that don't require a degree? | `query-1.sql` |
| 2 | Does mentioning health insurance correlate with pay? | `query-2.sql` |
| 3 | Which companies post the most Data Analyst jobs, and do they pay well? | `query-3.sql` |
| 4 | Which two skills most often appear together in the same posting? | `query-4.sql` |
| 5 | Which skills give beginners the best return — high demand, without being gated behind senior-sounding titles? | `query-final.sql` |

---

## Findings

### 1. The "no degree required" entry point pays close to market rate

- Avg salary: **$92,951** (range $26,444–$650,000, n=1,236 postings with salary listed)
- Titles are overwhelmingly generic "Data Analyst," but "Lead Data Analyst" and
  "Data Architect" also appear — no-degree isn't confined to junior roles
- Top skills: **SQL → Excel → Python → Tableau → Power BI**

~$93K is roughly on par with market-wide Data Analyst pay, which pushes back on
the assumption that skipping a degree caps earning potential. The $650K max is
likely an outlier and shouldn't be read as typical.

### 2. Health insurance correlates with slightly *higher* pay, not lower

| | Mentions health insurance | Doesn't |
|---|---|---|
| Postings | 2,322 | 3,141 |
| Avg salary | $95,550 | $92,638 |

A ~3% premium (~$2,912) — real, but modest. No evidence of a benefits-for-salary
tradeoff in this data. Worth noting the $650K outlier sits in the *no-insurance*
group, so it shouldn't be misread as skewing the "with insurance" number.

### 3. Biggest employers aren't always the best-paying — and many aren't direct employers at all

| Company | Postings | Avg Salary |
|---|---|---|
| Emprego | 1,121 | — |
| Robert Half | 1,047 | $89,111 |
| Insight Global | 892 | $92,801 |
| **Citi** | 875 | **$121,509** |
| Dice | 604 | $107,500 |
| UnitedHealth Group | 592 | $103,464 |
| Confidenziale | 549 | — |
| Get It Recruit | 510 | $87,489 |
| Michael Page | 468 | $97,000 |
| Randstad | 462 | $92,500 |

Six of the top 10 are staffing/recruiting agencies, not companies hiring for
their own teams. **Citi** is the standout: the only employer in the top 10
combining high volume with the highest average pay. Two of the top posters
(including the #1 by volume) disclosed no salary data at all.

### 4. SQL is the hub skill

| Pair | Count |
|---|---|
| SQL + Python | 44,630 |
| SQL + Tableau | 34,434 |
| SQL + Excel | 34,254 |
| SQL + Power BI | 26,424 |
| Python + R | 25,588 |

SQL appears in 7 of the top 10 skill pairs, and SQL + Python is the single
strongest pairing by a wide margin — a natural second skill to learn after SQL
itself. A visible "SQL + a visualization tool" cluster (Tableau, Power BI,
Excel) suggests querying and presenting are expected together.

### 5. Two independent "beginner" filters converge on the same core skills

Filtering separately by (a) "no degree mentioned" and (b) "non-senior job title"
both surface the same top 5, in nearly the same order: **SQL, Excel, Python,
Tableau, Power BI.** That agreement across two unrelated filters is a stronger
signal than either list alone.

| Skill | Demand | Avg salary |
|---|---|---|
| SQL | 2,836 | $93,918 |
| Excel | 2,025 | $84,441 |
| Python | 1,652 | $98,495 |
| Tableau | 1,532 | $95,494 |
| Power BI | 983 | $90,825 |
| R | 958 | $95,294 |
| SAS | 874 | $90,476 |

*(Full top-15, including Word, PowerPoint, SQL Server, Oracle, Azure, AWS, is
in `query-final.sql`.)*

Excel has the lowest average salary of the top 5 despite being #2 in demand —
likely a baseline expectation rather than a differentiator. Python and Tableau
pay somewhat more than SQL despite lower demand, suggesting a "SQL first, then
specialize" path. Word and PowerPoint cracking the top 10 is a reminder the
role isn't purely technical even at entry level.

---

## Methodology notes

- **Temp tables** were used where the same filtered subset (e.g. "no degree
  required" postings) fed three separate, independent queries — avoids
  repeating the filter logic across each one.
- **CTEs** were used where multiple aggregated results needed to be joined into
  one final combined output within a single statement (e.g. `query-final.sql`,
  which builds an entry-level job set, then aggregates skill demand/salary
  against it).
- **Skill pairing** (`query-4.sql`) used a self-join on `skills_job_dim` with a
  `skill_id_a < skill_id_b` condition so each unique pair is counted once,
  rather than twice or paired with itself.
- All queries scoped to `job_title_short = 'Data Analyst'` for consistency
  across the whole project.

## Files

- `query-1.sql` — entry point (no degree required)
- `query-2.sql` — benefits vs. pay
- `query-3.sql` — top employers
- `query-4.sql` — skill pairing
- `query-final.sql` — optimal skills for beginners

## What I'd explore next

- Remote vs. on-site salary comparison
- Month-over-month hiring trend across 2023
- The $650K salary outlier from Question 1 — legitimate senior role, or data error?
