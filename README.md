Scroll past challenge description for instructions on how to run the project

# Indicium Tech Code Challenge

Code challenge for Software Developer with focus in data projects.


## Context

At Indicium we have many projects where we develop the whole data pipeline for our client, from extracting data from many data sources to loading this data at its final destination, with this final destination varying from a data warehouse for a Business Intelligency tool to an api for integrating with third party systems.

As a software developer with focus in data projects your mission is to plan, develop, deploy, and maintain a data pipeline.


## The Challenge

We are going to provide 2 data sources, a PostgreSQL database and a CSV file.

The CSV file represents details of orders from an ecommerce system.

The database provided is a sample database provided by microsoft for education purposes called northwind, the only difference is that the **order_detail** table does not exists in this database you are beeing provided with. This order_details table is represented by the CSV file we provide.

Schema of the original Northwind Database: 

![image](https://user-images.githubusercontent.com/49417424/105997621-9666b980-608a-11eb-86fd-db6b44ece02a.png)

Your challenge is to build a pipeline that extracts the data everyday from both sources and write the data first to local disk, and second to a PostgreSQL database. For this challenge, the CSV file and the database will be static, but in any real world project, both data sources would be changing constantly.

Its important that all writing steps (writing data from inputs to local filesystem and writing data from local filesystem to PostgreSQL database) are isolated from each other, you shoud be able to run any step without executing the others.

For the first step, where you write data to local disk, you should write one file for each table. This pipeline will run everyday, so there should be a separation in the file paths you will create for each source(CSV or Postgres), table and execution day combination, e.g.:

```
/data/postgres/{table}/2024-01-01/file.format
/data/postgres/{table}/2024-01-02/file.format
/data/csv/2024-01-02/file.format
```

You are free to chose the naming and the format of the file you are going to save.

At step 2, you should load the data from the local filesystem, which you have created, to the final database.

The final goal is to be able to run a query that shows the orders and its details. The Orders are placed in a table called **orders** at the postgres Northwind database. The details are placed at the csv file provided, and each line has an **order_id** field pointing the **orders** table.

## Solution Diagram

As Indicium uses some standard tools, the challenge was designed to be done using some of these tools.

The following tools should be used to solve this challenge.

Scheduler:
- [Airflow](https://airflow.apache.org/docs/apache-airflow/stable/installation/index.html)

Data Loader:
- [Embulk](https://www.embulk.org) (Java Based)
**OR**
- [Meltano](https://docs.meltano.com/?_gl=1*1nu14zf*_gcl_au*MTg2OTE2NDQ4Mi4xNzA2MDM5OTAz) (Python Based)

Database:
- [PostgreSQL](https://www.postgresql.org/docs/15/index.html)

The solution should be based on the diagrams below:
![image](docs/diagrama_embulk_meltano.jpg)


### Requirements

- You **must** use the tools described above to complete the challenge.
- All tasks should be idempotent, you should be able to run the pipeline everyday and, in this case where the data is static, the output shold be the same.
- Step 2 depends on both tasks of step 1, so you should not be able to run step 2 for a day if the tasks from step 1 did not succeed.
- You should extract all the tables from the source database, it does not matter that you will not use most of them for the final step.
- You should be able to tell where the pipeline failed clearly, so you know from which step you should rerun the pipeline.
- You have to provide clear instructions on how to run the whole pipeline. The easier the better.
- You must provide evidence that the process has been completed successfully, i.e. you must provide a csv or json with the result of the query described above.
- You should assume that it will run for different days, everyday.
- Your pipeline should be prepared to run for past days, meaning you should be able to pass an argument to the pipeline with a day from the past, and it should reprocess the data for that day. Since the data for this challenge is static, the only difference for each day of execution will be the output paths.

### Things that Matters

- Clean and organized code.
- Good decisions at which step (which database, which file format..) and good arguments to back those decisions up.
- The aim of the challenge is not only to assess technical knowledge in the area, but also the ability to search for information and use it to solve problems with tools that are not necessarily known to the candidate.
- Point and click tools are not allowed.


Thank you for participating!

# Instructions on how to run the project
The project was developed in a Linux environment. More specifically, WSL.
1. With the docker engine running and being in the same directory as the file compose.yml, run `docker compose up -d`, then wait for the query results to show in the _output_ directory. It will take a few minutes for the image to build.
2. After you have an output file with the records, you can trigger the pipeline to run with a different logical date using the following command:
```
docker exec meltano-container /bin/sh -c '
meltano invoke airflow dags trigger postgres_to_local -e "2024-06-30";
meltano invoke airflow dags trigger local_to_postgres -e "2024-06-30"
'
```
Note: the DAGs are configured to start from days_ago(10), so picking a date that's too far in the past won't work. Modify the above command accordingly.

#### Extra:
3. Access `localhost:8080` to connect to Airflow's web server
   * login: `admin@localhost`
   * password: `password`

# Report

## I assumed
1. Extracting the CSV data which is already a local file and loading to local just meant using tap-csv to target-csv and changing directories.
2. Loading everything back to postgres meant changing database and creating new tables.

## Potential (?) issues that I didn't address

1. bytea data type used for pictures is now a missing CSV field after being extracted.
2. Two missing tables because of empty records when they were extracted from Postgres, so no CSV files are created.
3. I don't know how to pin neither the dbt-postgres nor Airflow plugin versions because their pip_urls don't follow any examples shown in the docs.

## Weird meltano behavior that I found

1. tap-csv quotechar config set to single quote, " ' ", was throwing errors. Double quotes work fine.

## Issues that I had to read about

1. Catalog files because the default discovery functionality misassigns some data types.
2. Switching from Airflow's SequentialExecutor to LocalExecutor in order to prevent the ExternalTaskSensor from blocking the whole pipeline.

## Choices I made
1. Having the same container running meltano, Airflow and dbt is probably not the best, but I wanted to see how meltano integrates those two services. Plus it looked like a less time consuming approach given the challenge's circumstances.
2. Regarding the output query, I like the formatting that psql outputs by default. Looks more readable than CSV or JSON.
