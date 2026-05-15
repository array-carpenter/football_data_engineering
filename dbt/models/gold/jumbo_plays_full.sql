-- Gold: jumbo formation plays — FULL coverage (participation + desc).
--
-- Combines two detection methods into a single per-play table:
--   is_jumbo_jersey  = participation says 6+ ineligible-numbered players
--                       (50-79 or 90-99) on the field. Catches "covered"
--                       extra-OL plays that don't require a report.
--   is_jumbo_desc    = desc text contains an eligibility report. Catches
--                       declared-eligible jumbo plays even when participation
--                       data is missing for that snap (~6% of plays in 2025).
--
-- A play is is_jumbo if EITHER method flags it. Use this model when you
-- want the most complete jumbo count. Use jumbo_plays.sql (desc-only) when
-- you specifically want plays involving an eligibility declaration.
--
-- NOTES:
--   - Requires participation data downloaded (download_participation.py).
--   - offense_numbers is only populated 2023+. Pre-2023, only the desc
--     signal is usable here. For 2016-2022 you'd need a roster-position
--     fallback (lookup gsis_id -> position OL); see the R companion script
--     in nfl-assets/jumbo/jumbo_multi_season.R.

with desc_jumbo as (
    select
        season, week, season_type, posteam, defteam,
        game_id, play_id, down, ydstogo, yardline_100,
        score_differential, play_type, pass, rush,
        yards_gained, epa, desc,
        true as is_jumbo_desc,
        -- Number of distinct reporters on this play (multi-reporter handling)
        array_length(
            regexp_extract_all(desc, '\d+-[A-Z]\.\S+ reported in as eligible')
        ) as n_reporters
    from {{ ref('plays') }}
    where season_type = 'REG'
      and posteam is not null
      and (pass = 1 or rush = 1)
      and regexp_matches(desc, '(reported|reports)( in)? as eligible')
),

jersey_jumbo as (
    -- Limit participation join to offensive scrimmage plays
    select
        p.game_id,
        p.play_id,
        part.n_ineligible_numbered,
        part.offense_personnel,
        true as is_jumbo_jersey
    from {{ ref('plays') }} p
    inner join {{ ref('participation') }} part
        on p.game_id = part.game_id
       and p.play_id = part.play_id
    where p.season_type = 'REG'
      and p.posteam is not null
      and (p.pass = 1 or p.rush = 1)
      and part.n_ineligible_numbered >= 6
),

-- All plays flagged by either method
combined_keys as (
    select game_id, play_id from desc_jumbo
    union
    select game_id, play_id from jersey_jumbo
)

select
    p.season,
    p.week,
    p.season_type,
    p.posteam,
    p.defteam,
    p.game_id,
    p.play_id,
    p.down,
    p.ydstogo,
    p.yardline_100,
    p.score_differential,
    p.play_type,
    p.pass,
    p.rush,
    p.yards_gained,
    p.epa,
    p.desc,
    coalesce(d.is_jumbo_desc,   false) as is_jumbo_desc,
    coalesce(j.is_jumbo_jersey, false) as is_jumbo_jersey,
    coalesce(d.n_reporters, 0)         as n_reporters,
    j.n_ineligible_numbered,
    j.offense_personnel,
    case
        when yardline_100 <= 5  then 'Inside 5'
        when yardline_100 <= 10 then '5-10 yard line'
        when yardline_100 <= 20 then '10-20 yard line'
        when yardline_100 <= 40 then '20-40 yard line'
        else                         'Own territory'
    end as field_zone
from {{ ref('plays') }} p
inner join combined_keys ck
    on p.game_id = ck.game_id
   and p.play_id = ck.play_id
left join desc_jumbo d
    on p.game_id = d.game_id
   and p.play_id = d.play_id
left join jersey_jumbo j
    on p.game_id = j.game_id
   and p.play_id = j.play_id
