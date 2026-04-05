import requests
from pathlib import Path

url = 'https://github.com/nflverse/nflverse-data/releases/download/pbp/play_by_play_2025.csv.gz'

dest = Path("data/bronze")

dest.mkdir(parents=True, exist_ok =True)

resp = requests.get(url, timeout=120)
resp.raise_for_status()

file_path = dest / "play_by_play_2025.csv.gz"
file_path.write_bytes(resp.content)

print(f"downloaded {len(resp.content) / 1_048_576:.1f} MB to {file_path}")
