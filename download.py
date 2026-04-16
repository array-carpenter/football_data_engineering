import requests
from pathlib import Path
import sys

dest = Path("data/bronze")
dest.mkdir(parents=True, exist_ok=True)

seasons = [int(s) for s in sys.argv[1:]] if len(sys.argv) > 1 else [2025]

for season in seasons:
    url = f"https://github.com/nflverse/nflverse-data/releases/download/pbp/play_by_play_{season}.csv.gz"
    file_path = dest / f"play_by_play_{season}.csv.gz"

    if file_path.exists():
        print(f"  {file_path.name} already exists, skipping")
        continue

    print(f"  downloading {season}...", end=" ", flush=True)
    resp = requests.get(url, timeout=120)
    resp.raise_for_status()
    file_path.write_bytes(resp.content)
    print(f"{len(resp.content) / 1_048_576:.1f} MB")

print("done")
