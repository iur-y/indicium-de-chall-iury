# postgres_to_local.py: extract data from containerized postgres database and CSV file and load to local disk
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import timedelta
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'me',
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    dag_id="postgres_to_local",
    default_args=default_args,
    start_date=days_ago(10),
    schedule_interval="@daily",
    catchup=False
) as dag:

    create_directories = BashOperator(
        task_id="create_dirs_for_today",
        bash_command="${MELTANO_PROJECT_ROOT}/orchestrate/airflow/scripts/makedirs.sh {{ ds }} ${MELTANO_PROJECT_ROOT}",
    )

    extract_postgres = BashOperator(
        task_id="extract_postgres_to_local",
        bash_command="${MELTANO_PROJECT_ROOT}/orchestrate/airflow/scripts/postgres_to_local.sh {{ ds }} ${MELTANO_PROJECT_ROOT}",
    )

    extract_csv = BashOperator(
        task_id="extract_csv_to_local",
        bash_command="${MELTANO_PROJECT_ROOT}/orchestrate/airflow/scripts/csv_to_local.sh {{ ds }} ${MELTANO_PROJECT_ROOT}",
    )

    move_files = BashOperator(
        task_id="organize_files",
        bash_command="${MELTANO_PROJECT_ROOT}/orchestrate/airflow/scripts/organize_files.sh {{ ds }} ${MELTANO_PROJECT_ROOT}",
    )

    create_directories >> extract_postgres >> extract_csv >> move_files
