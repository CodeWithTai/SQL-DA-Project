"""Regenerate the README charts from the SQL queries.

Usage: python project-sql/make_charts.py
Needs a local PostgreSQL `sql_course` database and a password in PGPASSWORD or pgpass.conf.
Writes images/top_10_skill_pairs.png and images/top_15_entry_level_skills.png at the repo root.
"""
import os
import subprocess
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker

PSQL = os.environ.get("PSQL", r"C:\Program Files\PostgreSQL\17\bin\psql.exe")
HERE = os.path.dirname(os.path.abspath(__file__))
IMAGES = os.path.join(HERE, "..", "images")


def query_rows(sql_file, header_prefix, n):
    """Run a .sql file and return the n rows under the result set whose header starts with header_prefix."""
    out = subprocess.run([PSQL, "-w", "-h", "localhost", "-U", "postgres", "-d", "sql_course",
                          "-A", "-F", "|", "-P", "footer=off", "-f", os.path.join(HERE, sql_file)],
                         capture_output=True, text=True, check=True).stdout.strip().split("\n")
    start = next(i for i, line in enumerate(out) if line.startswith(header_prefix))
    rows = [line.split("|") for line in out[start + 1: start + 1 + n]]
    assert len(rows) == n, f"expected {n} rows from {sql_file}, got {len(rows)}"
    return rows


def bar_chart(labels, counts, pcts, title, subtitle, out_png, height):
    assert counts == sorted(counts, reverse=True)
    fig, ax = plt.subplots(figsize=(9, height), facecolor="#fcfcfb")
    ax.set_facecolor("#fcfcfb")
    bars = ax.barh(labels[::-1], counts[::-1], color="#2a78d6", height=0.7)
    for b, c, p in zip(bars, counts[::-1], pcts[::-1]):
        ax.text(b.get_width() + max(counts) * 0.01, b.get_y() + b.get_height() / 2, f"{c:,}  ({p:.1f}%)",
                va="center", fontsize=9, color="#52514e")
    ax.set_title(title, loc="left", fontsize=13, color="#0b0b0b", pad=34)
    ax.text(0, 1.02, subtitle, transform=ax.transAxes, fontsize=8.5, color="#52514e")
    ax.set_xlabel("Number of postings", color="#52514e")
    ax.xaxis.set_major_formatter(matplotlib.ticker.FuncFormatter(lambda x, _: f"{int(x):,}"))
    ax.set_xlim(0, max(counts) * 1.22)
    for s in ["top", "right", "left"]:
        ax.spines[s].set_visible(False)
    ax.spines["bottom"].set_color("#c3c2b7")
    ax.tick_params(colors="#52514e", length=0)
    ax.grid(axis="x", color="#e6e5e0", linewidth=0.8)
    ax.set_axisbelow(True)
    fig.tight_layout()
    fig.savefig(os.path.join(IMAGES, out_png), dpi=150)
    print("saved", out_png, list(zip(labels, counts))[:3])


# shortcut: posting totals in the subtitles are hardcoded from the 2026-10-30 run, update them if the data changes
pairs = query_rows("query-4.sql", "skill_a|skill_b", 10)
bar_chart([f"{r[0]} + {r[1]}" for r in pairs], [int(r[3]) for r in pairs], [float(r[4]) for r in pairs],
          "Top 10 skill pairs in Data Analyst postings (2023)",
          "Postings that mention both skills (% of 196,593 Data Analyst postings)",
          "top_10_skill_pairs.png", 5.5)

skills = query_rows("query-final.sql", "job_title|skill_name", 15)
bar_chart([r[1] for r in skills], [int(r[2]) for r in skills], [float(r[3]) for r in skills],
          "Top 15 skills in entry-level Data Analyst postings (2023)",
          "Postings that mention each skill (% of 179,589 entry-level postings)\n"
          "Excludes titles with senior, sr, lead, manager, head, director, etc.",
          "top_15_entry_level_skills.png", 6.5)
