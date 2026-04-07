from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
      dag_id="nfl_pipeline",
      start_date=datetime(2025, 1, 1),
      schedule=None,
  ) as dag:

      download = BashOperator(
          task_id="download",
          bash_command="echo 'downloading data'",
      )

      dbt_run = BashOperator(
          task_id="dbt_run",
          bash_command="echo 'running dbt'",
      )

      dbt_test = BashOperator(
          task_id="dbt_test",
          bash_command="echo 'testing dbt'",
      )

      download >> dbt_run >> dbt_test