select *
from read_csv(
    '../data/bronze/play_by_play_*.csv.gz',
    auto_detect=true,
    sample_size=10000,
    union_by_name=true
)
