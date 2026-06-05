-- Gold: two-QB plays aggregated by team and season.
--
-- Rollup of two_qb_plays. The story jumps off the page: one team
-- (New Orleans) accounts for almost every two-QB snap in the league,
-- and the formation lives in the run game.

SELECT
    season,
    team,
    count(*) as two_qb_plays,
    sum(case when rush = 1 then 1 else 0 end) as two_qb_runs,
    sum(case when pass = 1 then 1 else 0 end) as two_qb_passes,
    avg(epa) as two_qb_epa_per_play
FROM {{ ref('two_qb_plays') }}
GROUP BY season, team
ORDER BY season DESC, two_qb_plays DESC
