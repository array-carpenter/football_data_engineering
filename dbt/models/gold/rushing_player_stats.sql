select
    r.rusher_player_id,
    cn.canonical_name as rusher_player_name,
    r.posteam as team,
    r.season,
    count(*) as carries,
    sum(r.yards_gained) as rushing_yards,
    sum(r.rush_touchdown) as rushing_tds,
    sum(r.epa) as total_epa,
    avg(r.epa) as epa_per_carry,
    sum(r.fumble_lost) as fumbles_lost,
    count(distinct r.game_id) as games
from {{ ref('plays') }} r
inner join {{ ref('int_rusher_names') }} cn
    on r.rusher_player_id = cn.rusher_player_id
where r.play_type = 'run'
  and r.rusher_player_id is not null
group by r.rusher_player_id, cn.canonical_name, r.posteam, r.season
order by r.season, r.posteam, rushing_yards desc
