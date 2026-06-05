-- Gold: two-quarterback plays
--
-- A "two-QB play" has 2+ players lined up at QB on an offensive scrimmage
-- snap -- think the Saints' Taysom Hill packages, where Hill lines up next to
-- the passer. We detect it from participation data (offense_positions), the
-- same feed Part 2 used for jumbo formations. The two models are mirror
-- images of each other:
--
--   jumbo  = 6+ players with ineligible jersey numbers   (n_ineligible_numbered)
--   two-QB = 2+ players at the QB position                (n_qb)
--
-- Same two gotchas as the jumbo model:
--   1. Filter to real scrimmage plays (pass = 1 OR rush = 1). Special teams
--      formations list strange "offense" positions (whole punt/kick units)
--      and would pollute the count.
--   2. offense_positions is only populated 2023+ in the nflverse feed, so
--      this model only has data for recent seasons.

SELECT
    p.season,
    p.week,
    p.posteam as team,
    p.game_id,
    p.play_id,
    p.down,
    p.ydstogo,
    p.yardline_100,
    p.play_type,
    p.pass,
    p.rush,
    p.yards_gained,
    p.epa,
    part.n_qb,
    part.offense_personnel,
    p.desc
FROM {{ ref('plays') }} p
JOIN {{ ref('participation') }} part
  ON p.game_id = part.game_id AND p.play_id = part.play_id
WHERE p.season_type = 'REG'
  AND p.posteam IS NOT NULL
  AND (p.pass = 1 OR p.rush = 1)
  AND part.n_qb >= 2
