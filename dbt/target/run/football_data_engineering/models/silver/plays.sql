
  
    
    

    create  table
      "football"."main"."plays__dbt_tmp"
  
    as (
      SELECT
    CASE WHEN posteam = 'LA' THEN 'LAR' ELSE posteam END as posteam,
    CASE when defteam = 'LA' THEN 'LAR' ELSE defteam END as defteam,
    CASE WHEN td_team = 'LA' THEN 'LAR' ELSE td_team END as td_team,
    CASE WHEN home_team = 'LA' THEN 'LAR' ELSE home_team END as home_team,
    CASE WHEN away_team = 'LA' THEN 'LAR' ELSE away_team END as away_team,
    CASE WHEN penalty_team = 'LA' THEN 'LAR' ELSE penalty_team END as penalty_team,
    CASE WHEN return_team = 'LA' THEN 'LAR' ELSE return_team END as return_team,
    CASE WHEN fumble_recovery_1_team = 'LA' THEN 'LAR' ELSE fumble_recovery_1_team END as fumble_recovery_1_team,
    CASE WHEN timeout_team = 'LA' THEN 'LAR' else timeout_team END as timeout_team,
    replace(game_id, '_LA_', '_LAR_') as game_id, -- including underscores so we don't accidentally replace the chargers
    * exclude (posteam, defteam, td_team, home_team, away_team, penalty_team, return_team, fumble_recovery_1_team, timeout_team, game_id)
    from "football"."main"."stg_play_by_play"
    );
  
  