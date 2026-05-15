-- Gold: jumbo plays aggregated by team and season
--
-- Rolls up jumbo_plays into per-team-per-season totals with run/pass split
-- and average EPA. Use this for "which teams use jumbo most" analyses.

SELECT
    season,
    posteam as team,
    count(*) as jumbo_plays,
    sum(case when rush = 1 then 1 else 0 end) as jumbo_runs,
    sum(case when pass = 1 then 1 else 0 end) as jumbo_passes,
    avg(epa) as jumbo_epa_per_play,
    avg(yards_gained) as jumbo_yards_per_play
FROM {{ ref('jumbo_plays') }}
GROUP BY season, posteam
ORDER BY season DESC, jumbo_plays DESC
