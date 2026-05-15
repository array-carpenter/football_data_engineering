-- Staging: raw participation CSV
-- One row per play with semicolon-separated player IDs / numbers / positions.
-- Note: offense_numbers and offense_positions are only populated 2023+.

select *
from read_csv(
    '../data/bronze/participation_2025.csv.gz',
    auto_detect = true,
    sample_size = 10000
)
