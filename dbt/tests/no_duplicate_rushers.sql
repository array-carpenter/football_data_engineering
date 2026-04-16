select
    rusher_player_id,
    team,
    season,
    count(*) as duplicates
from {{ ref('rushing_player_stats') }}
group by rusher_player_id, team, season
having count(*) > 1
