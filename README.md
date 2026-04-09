  # Football Data Engineering

  <img width="3531" height="1979" alt="football_architecture_v2" src="https://github.com/user-attachments/assets/fb113124-ad55-4c68-902b-20d30e565d26" />

  Learning data engineering with free NFL data.

  ## Tech Stack
  - dbt
  - DuckDB
  - Docker
  - Kubernetes
  - Airflow

  ## File Structure

  data/bronze/          raw CSV from nflfastR
  dbt/models/staging/   reads raw data (view)
  dbt/models/silver/    cleans team abbreviations (table)
  dbt/models/gold/      aggregated stats (table)
  dbt/tests/            data quality checks
  k8s/                  Kubernetes manifests
  dags/                 Airflow DAGs

  ## Quick Start

  ```bash
  git clone https://github.com/array-carpenter/football_data_engineering.git
  cd football_data_engineering
  uv venv
  source .venv/bin/activate
  uv pip install dbt-duckdb requests
  python download.py 2025
  cd dbt
  dbt run
  dbt test

  Author

  Ray Carpenter — @csv_enjoyer | thespade.substack.coom
  ```
