select
    passer_player_name,
    posteam as team,
    season,
    week,
    count(*) as dropbacks,
    sum(epa) as total_epa,
    avg(epa) as epa_per_dropback
from {{ ref('plays') }}
where qb_dropback = 1 and passer_player_name is NOT NULL
group by passer_player_name, posteam, season, week
order by passer_player_name, season, week