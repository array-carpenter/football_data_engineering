select *
from read_csv(
    '../data/bronze/play_by_play_2025.csv.gz',
    auto_detect =true,
    sample_size = 10000
)