select
    r.rusher_player_id,
    cn.canonical_name as rusher_player_name,
    r.posteam as team,
    r.season,
    r.run_location,
    r.run_gap,
    count(*) as carries,
    sum(r.epa) as total_epa,
    avg(r.epa) as epa_per_carry,
    sum(r.yards_gained) as rushing_yards,
    avg(r.yards_gained) as yards_per_carry
from {{ ref('plays') }} r
inner join {{ ref('int_rusher_names') }} cn
    on r.rusher_player_id = cn.rusher_player_id
where r.play_type = 'run'
  and r.rusher_player_id is not null
  and r.run_location is not null
  and r.run_gap is not null
group by r.rusher_player_id, cn.canonical_name, r.posteam, r.season, r.run_location, r.run_gap
order by r.season, r.posteam, cn.canonical_name, r.run_location, r.run_gap
