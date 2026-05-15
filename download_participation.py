"""Download nflverse participation data for a given season.

Participation data complements the play-by-play feed by listing every
offensive and defensive player on the field for each snap, with their
jersey numbers and positions (positions only populated 2023+).

Usage:
    python download_participation.py 2025
"""
import sys
from pathlib import Path
import requests

DEFAULT_SEASON = 2025
RELEASE_URL = (
    "https://github.com/nflverse/nflverse-data/releases/download/"
    "pbp_participation/pbp_participation_{season}.csv.gz"
)

season = int(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SEASON
url = RELEASE_URL.format(season=season)

dest = Path("data/bronze")
dest.mkdir(parents=True, exist_ok=True)

resp = requests.get(url, timeout=120)
resp.raise_for_status()

file_path = dest / f"participation_{season}.csv.gz"
file_path.write_bytes(resp.content)

print(f"downloaded {len(resp.content) / 1_048_576:.1f} MB to {file_path}")
