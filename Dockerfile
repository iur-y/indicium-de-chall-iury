FROM meltano/meltano:v3.4.2

# libpq-dev python3-dev fixed my psycopg2 installation error
RUN apt-get update && apt-get install -y \
    postgresql-client \
    libpq-dev \
    python3-dev

RUN meltano init my-project

WORKDIR /project/my-project

COPY meltano.yml /project/my-project/meltano.yml

# execute script here
COPY setup.sh /project/my-project/setup.sh
RUN chmod +x /project/my-project/setup.sh
RUN /project/my-project/setup.sh

# copy other needed files
# an alternative is to clone from github repo
COPY catalog/ /project/my-project/catalog/
COPY data/ /project/my-project/data/
COPY orchestrate/airflow/dags/ /project/my-project/orchestrate/airflow/dags/
COPY orchestrate/airflow/scripts/ /project/my-project/orchestrate/airflow/scripts/
COPY orchestrate/airflow/airflow.cfg /project/my-project/orchestrate/airflow/airflow.cfg
# bind mounting this one in compose.yml instead
# COPY tmpdata/ /project/my-project/tmpdata/
COPY transform/models/ /project/my-project/transform/models/

# cannot create user and start scheduler and webserver, as the RUN happens before network is created
# moved this command to entrypoint.sh
# RUN meltano invoke airflow users create -u admin@localhost -p password --role Admin -e admin@localhost -f admin -l admin

# entrypoint script
COPY entrypoint.sh /project/my-project/entrypoint.sh
RUN chmod +x /project/my-project/entrypoint.sh

ENTRYPOINT ["/project/my-project/entrypoint.sh"]