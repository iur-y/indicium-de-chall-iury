#!/bin/bash

export MELTANO_ENVIRONMENT=dev

# create lock files so the install commands below work
meltano lock --all

# use meltano install instead of meltano add so plugin versions can be pinned
meltano install extractor tap-csv
meltano install extractor tap-postgres
meltano install loader target-csv
meltano install loader target-postgres


# since this needs to be reproducible this is the easiest approach, even though it's not good practice
meltano config tap-postgres set password thewindisblowing
meltano config target-postgres set password thewindisblowing

##############################
# airflow

meltano install utility airflow

# install psycopg2 specifically in the venv that airflow runs in
cd .meltano/utilities/airflow/
source venv/bin/activate
pip install psycopg2==2.9.9
deactivate

cd /project/my-project
############################
# dbt

meltano install utility dbt-postgres
meltano invoke dbt-postgres:initialize
meltano config dbt-postgres set password thewindisblowing
############################


