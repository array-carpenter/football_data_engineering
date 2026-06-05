"""Export the DuckDB gold tables into a portable SQLite database.

Why bother? The .duckdb file is great while you're working, but it's a pain
to hand to someone else:
  - they need DuckDB installed to open it, and
  - the DuckDB storage format changes between versions, so a file written
    today might not open in the DuckDB someone installed last year.

SQLite has none of those problems. It opens just about everywhere with no
setup: DB Browser for SQLite (free, click-to-open), Python's built-in
sqlite3, R's RSQLite, DBeaver, pandas, even your phone. So we copy the
finished "gold" tables into one football.sqlite file that anyone can
download and start querying immediately.

Run it after `dbt run`:

    python export_to_sqlite.py
"""
from pathlib import Path

import duckdb

DUCKDB_PATH = "data/football.duckdb"
SQLITE_PATH = "data/football.sqlite"

# The tables worth sharing: the gold layer. These are the finished,
# analysis-ready tables -- one row per play or per team-season, all columns
# flat. We deliberately DON'T export the silver layer: silver/participation
# has list columns (offense_player_ids, offense_numbers_arr, ...) and SQLite
# has no array type, so those wouldn't survive the trip. Gold is flat and
# copies across cleanly.
GOLD_TABLES = [
    "jumbo_plays",
    "jumbo_plays_full",
    "jumbo_by_team_season",
    "two_qb_plays",
    "two_qb_by_team_season",
    "epa_per_dropback",
    "rushing_gap_stats",
    "rushing_player_stats",
]


def main():
    con = duckdb.connect(DUCKDB_PATH, read_only=True)

    # DuckDB can read and write SQLite files directly through an extension.
    con.execute("INSTALL sqlite")
    con.execute("LOAD sqlite")

    # Start fresh each run so re-exports don't leave stale tables behind.
    Path(SQLITE_PATH).unlink(missing_ok=True)

    # ATTACH makes the SQLite file look like a second database we can write to.
    con.execute(f"ATTACH '{SQLITE_PATH}' AS sqlite_db (TYPE SQLITE)")

    for table in GOLD_TABLES:
        # CREATE TABLE ... AS SELECT copies the rows straight across. DuckDB
        # maps its types down to SQLite's (TEXT / INTEGER / REAL) for us.
        con.execute(
            f"CREATE TABLE sqlite_db.{table} AS SELECT * FROM main.{table}"
        )
        n = con.execute(f"SELECT count(*) FROM sqlite_db.{table}").fetchone()[0]
        print(f"  {table}: {n:,} rows")

    con.execute("DETACH sqlite_db")
    con.close()

    size_mb = Path(SQLITE_PATH).stat().st_size / 1_048_576
    print(f"wrote {SQLITE_PATH} ({size_mb:.1f} MB)")


if __name__ == "__main__":
    main()
