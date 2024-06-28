# local_to_postgres.py: extract data from local disk and load to containerized postgres database, then trasform with dbt
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import timedelta
from airflow.utils.dates import days_ago
from airflow.sensors.external_task import ExternalTaskSensor

default_args = {
    'owner': 'me',
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    dag_id="local_to_postgres",
    default_args=default_args,
    start_date=days_ago(10),
    schedule_interval="@daily",
    catchup=False
) as dag:

    detect_dag_completion = ExternalTaskSensor(
        task_id="detect_dag_completion",
        external_dag_id="postgres_to_local",
        external_task_id="organize_files",
        mode="poke",
        poke_interval=60, # 60 seconds
        timeout=5*60, # 5 minutes
    )

    create_new_database = BashOperator(
        task_id="create_new_database",
        bash_command="${MELTANO_PROJECT_ROOT}/orchestrate/airflow/scripts/create_postgres_db.sh ",
    )

    load_local_to_postgres = BashOperator(
        task_id="load_local_csv_to_postgres",
        bash_command="${MELTANO_PROJECT_ROOT}/orchestrate/airflow/scripts/local_to_postgres.sh {{ ds }} ${MELTANO_PROJECT_ROOT}",
    )

    transform_data = BashOperator(
        task_id="transform_data",
        bash_command="cd ${MELTANO_PROJECT_ROOT} && meltano invoke dbt-postgres:run",
    )

    query_results = BashOperator(
        task_id="query_results",
        bash_command="${MELTANO_PROJECT_ROOT}/orchestrate/airflow/scripts/query_results.sh {{ ds }} ${MELTANO_PROJECT_ROOT}",
    )

    detect_dag_completion >> create_new_database >> load_local_to_postgres >> transform_data >> query_results
