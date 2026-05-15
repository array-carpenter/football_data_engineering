-- Adds a binary jumbo indicator to all plays.
-- A play is "jumbo" when an ineligible-number player (typically OL/DL)
-- reports in as eligible, signaling an extra blocker on the field.
--
-- Detection: search for eligible-reporting language in the play description.
-- The primary pattern (2003+) is "XX-Name reported in as eligible".
-- Earlier seasons (2002) use varied phrasing: "reports as eligible",
-- "is an eligible receiver", "eligible" next to a jersey number, etc.
--
-- Also extracts the reporting player's jersey number and abbreviated name
-- when the modern format is used.
--
-- Validated against nflfastR participation data (2021-2025):
--   98.9% of flagged plays have 6+ OL on the field.
--   The ~1% with 5 OL are DL/LB types (e.g. Vita Vea) reporting eligible.

select
    *,
    case
        when "desc" like '%reported in as eligible%' then 1
        when "desc" like '%reports as eligible%' then 1
        when "desc" like '%reports in as eligible%' then 1
        when "desc" like '%reports eligible%' then 1
        when "desc" like '%reported as eligible%' then 1
        when "desc" like '%in as eligible receiver%' then 1
        when "desc" like '%is an eligible receiver%' then 1
        when "desc" like '%is eligible receiver%' then 1
        when regexp_matches("desc", '#?\d+[\s\-]?\w*\s+eligible') then 1
        else 0
    end as is_jumbo,
    regexp_extract("desc", '(\d+-[A-Z]\.[A-Za-z''\-]+) reported in as eligible', 1)
        as jumbo_player_raw,
    try_cast(
        regexp_extract("desc", '(\d+)-[A-Z]\.[A-Za-z''\-]+ reported in as eligible', 1)
        as integer
    ) as jumbo_player_jersey
from {{ ref('plays') }}
