#!/bin/bash

meltano invoke airflow:initialize

meltano invoke airflow users create -u admin@localhost -p password --role Admin -e admin@localhost -f admin -l admin

# Airflow scheduler in the background
meltano invoke airflow scheduler &

# Airflow webserver in the background
meltano invoke airflow webserver &

# Keep the container running
wait -n