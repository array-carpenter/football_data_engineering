
  
  create view "football"."main"."stg_play_by_play__dbt_tmp" as (
    select *
from read_csv(
    '../data/bronze/play_by_play_2025.csv.gz',
    auto_detect =true,
    sample_size = 10000
)
  );
