# query_results.sh: using psql, select * from the transformed dbt table
# $1 is {{ ds }}
# $2 is ${MELTANO_PROJECT_ROOT}

# Variables for PostgreSQL connection
HOST="db"
PORT="5432"
USER="northwind_user"
# Environment variable TARGET_POSTGRES_PASSWORD
PASSWORD="$TARGET_POSTGRES_PASSWORD"
DB="newdb"

# Export the PGPASSWORD variable so psql can use it
export PGPASSWORD=${PASSWORD}

# Create file to store output of psql
touch "output-${1}.txt"

# Execute the query
psql -h ${HOST} -p ${PORT} -U ${USER} -d ${DB} -c "SELECT * FROM analytics.orders_join_order_details;" > "output-${1}.txt"

mv "output-${1}.txt" "$2/output"



