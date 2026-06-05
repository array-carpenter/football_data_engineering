-- Gold: jumbo formation plays (desc-based detection)
--
-- Flags every offensive scrimmage play with at least one "reported in as
-- eligible" event in the description. See tutorials/querying_jumbo_formations.md
-- for the methodology, gotchas, and limitations.
--
-- Caveats handled here:
--   - Pass/rush filter excludes FG / punt / kickoff / kneel
--   - Broader regex catches 2013 phrasing variants
--   - LA -> LAR normalization happens upstream in silver/plays.sql
-- Caveat NOT handled (limitation of desc-only method):
--   - Misses ~20% of true jumbo plays where the extra OL is covered
--     (no eligibility report required). For full coverage, join
--     participation data (offense_numbers field) and count ineligible-
--     numbered players >= 6.

SELECT
    season,
    week,
    season_type,
    posteam,
    defteam,
    game_id,
    play_id,
    down,
    ydstogo,
    yardline_100,
    score_differential,
    play_type,
    pass,
    rush,
    yards_gained,
    epa,
    "desc",
    -- Convenience: number of distinct reporters on this play
    -- (handles multi-reporter plays like Heck + Vea on TB goal line)
    array_length(
        regexp_extract_all("desc", '\d+-[A-Z]\.\S+ reported in as eligible')
    ) as n_reporters,
    -- Field position bucket for goal-line vs midfield slicing
    case
        when yardline_100 <= 5  then 'Inside 5'
        when yardline_100 <= 10 then '5-10 yard line'
        when yardline_100 <= 20 then '10-20 yard line'
        when yardline_100 <= 40 then '20-40 yard line'
        else                         'Own territory'
    end as field_zone
FROM {{ ref('plays') }}
WHERE season_type = 'REG'
  AND posteam IS NOT NULL
  AND (pass = 1 OR rush = 1)
  AND regexp_matches("desc", '(reported|reports)( in)? as eligible')
