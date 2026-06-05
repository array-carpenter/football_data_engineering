-- Silver: cleaned participation, one row per play, with derived counts
-- already computed.
--
-- Two important things happen here:
--   1. Rams game_id normalization (LA -> LAR) so this can join to silver.plays
--      without silently dropping every Rams play.
--   2. Dissection of the semicolon-separated columns into arrays plus
--      pre-computed jumbo signals (count of ineligible-numbered players).
--
-- Downstream gold models can use:
--   - n_offense_players / n_offense_numbers (sanity checks)
--   - n_ineligible_numbered (the jersey-rule jumbo signal: 6+ = jumbo)
--   - offense_player_ids / offense_numbers_arr (for unnesting per-player)

select
    -- Normalize Rams game_id (silver/plays.sql does the same; both must
    -- agree or the join breaks). LAC is unaffected because the pattern
    -- requires "_LA" followed by "_" or end-of-string.
    case
        when nflverse_game_id like '%_LA' then
            replace(nflverse_game_id, '_LA', '_LAR')
        else
            replace(nflverse_game_id, '_LA_', '_LAR_')
    end as game_id,
    play_id,
    possession_team,

    -- Raw arrays (for downstream unnesting)
    string_to_array(offense_players, ';')   as offense_player_ids,
    string_to_array(offense_numbers, ';')   as offense_numbers_arr,
    string_to_array(offense_positions, ';') as offense_positions_arr,
    string_to_array(defense_players, ';')   as defense_player_ids,

    -- Sanity columns
    array_length(string_to_array(offense_players, ';')) as n_offense_players,
    array_length(string_to_array(offense_numbers, ';')) as n_offense_numbers,

    -- Jumbo signal: count of players with ineligible jersey numbers
    -- (50-79 or 90-99). 6+ on the field = jumbo formation.
    -- offense_numbers is only populated 2023+; will be NULL for older seasons.
    coalesce(
        (
            select count(*)
            from unnest(string_to_array(offense_numbers, ';')) as t(num)
            where try_cast(num as int) between 50 and 79
               or try_cast(num as int) between 90 and 99
        ),
        0
    ) as n_ineligible_numbered,

    -- Two-QB signal: count of players lined up at QB. 2+ means a second
    -- quarterback is on the field (e.g. the Saints' Taysom Hill packages).
    -- Same idea as n_ineligible_numbered above, just counting a position
    -- instead of a number range. offense_positions is only populated 2023+.
    coalesce(
        (
            select count(*)
            from unnest(string_to_array(offense_positions, ';')) as t(pos)
            where pos = 'QB'
        ),
        0
    ) as n_qb,

    -- Personnel grouping string ("1 C, 2 G, 1 QB, 1 RB, 2 T, 1 TE")
    offense_personnel,
    defense_personnel,
    offense_formation,
    defenders_in_box,
    number_of_pass_rushers
from {{ ref('stg_participation') }}
