
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  SELECT*
FROM "football"."main"."plays"
WHERE posteam = 'LA'
    OR defteam = 'LA'
    OR home_team = 'LA'
    OR away_team = 'LA'
    OR penalty_team = 'LA'
    OR return_team = 'LA'
    OR timeout_team = 'LA'
    OR fumble_recovery_1_team = 'LA'
  
  
      
    ) dbt_internal_test