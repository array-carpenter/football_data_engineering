-- Every play with "reported in as eligible" in desc should have is_jumbo = 1,
-- and every is_jumbo = 1 play should have that text in desc.
select *
from {{ ref('plays_jumbo') }}
where (is_jumbo = 1 and "desc" not like '%reported in as eligible%')
   or (is_jumbo = 0 and "desc" like '%reported in as eligible%')
