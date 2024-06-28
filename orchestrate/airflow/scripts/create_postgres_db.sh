# create_postgres_db.sh: using psql, create a target database in the postgres container

# Variables for PostgreSQL connection
HOST="localhost"
PORT="5432"
USER="northwind_user"
# Environment variable TARGET_POSTGRES_PASSWORD
PASSWORD="$TARGET_POSTGRES_PASSWORD"
DB="northwind"
NEW_DB="newdb"

# Export the PGPASSWORD variable so psql can use it
export PGPASSWORD=${PASSWORD}

# Create file to store output of psql
touch output.txt

# Execute the CREATE DATABASE statement
psql -h ${HOST} -p ${PORT} -U ${USER} -d ${DB} -c "CREATE DATABASE ${NEW_DB};" > output.txt 2>&1


# If the database is created or if it already exists, exit 0 and pipeline continues
# If any error other than already exists, then exit 1 to stop the pipeline
if [ $? -eq 0 ]; then
    exit 0;
else
    output=$(cat output.txt);
    echo $output | grep "already exists";
    if [ $? -eq 0 ]; then
        exit 0;
    else
        echo $output;
        exit 1;
    fi
fi

