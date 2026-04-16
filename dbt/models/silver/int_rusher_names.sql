with cleaned as (
    select
        rusher_player_id,
        regexp_replace(rusher_player_name, '\.(\S)', '. \1') as rusher_player_name,
        count(*) as usage_count
    from {{ ref('plays') }}
    where rusher_player_id is not null
      and rusher_player_name is not null
    group by rusher_player_id, regexp_replace(rusher_player_name, '\.(\S)', '. \1')
),

ranked as (
    select
        rusher_player_id,
        rusher_player_name,
        row_number() over (
            partition by rusher_player_id
            order by usage_count desc
        ) as rn
    from cleaned
)

select
    rusher_player_id,
    rusher_player_name as canonical_name
from ranked
where rn = 1
