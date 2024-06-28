# local_to_postgres.sh: using meltano, load data from local disk CSV files to a postgres database
# $1 is {{ ds }}
# $2 is ${MELTANO_PROJECT_ROOT}

set -e

# Go to MELTANO_PROJECT_ROOT directory
cd "$2"

# Create JSON string containing tap-csv configuration 
fileconfig=$(tr -d [:space:] << _EOF_
[
{"entity": "order_details", "path": "data/csv/$1/", "keys": ["order_id", "product_id"]},
{"entity": "categories", "path": "data/postgres/categories/$1/", "keys": ["category_id"]},
{"entity": "customers", "path": "data/postgres/customers/$1/", "keys": ["customer_id"]},
{"entity": "employee_territories", "path": "data/postgres/employee_territories/$1/", "keys": ["employee_id", "territory_id"]},
{"entity": "employees", "path": "data/postgres/employees/$1/", "keys": ["employee_id"]},
{"entity": "orders", "path": "data/postgres/orders/$1/", "keys": ["order_id"]},
{"entity": "products", "path": "data/postgres/products/$1/", "keys": ["product_id"]},
{"entity": "region", "path": "data/postgres/region/$1/", "keys": ["region_id"]},
{"entity": "shippers", "path": "data/postgres/shippers/$1/", "keys": ["shipper_id"]},
{"entity": "suppliers", "path": "data/postgres/suppliers/$1/", "keys": ["supplier_id"]},
{"entity": "territories", "path": "data/postgres/territories/$1/", "keys": ["territory_id"]},
{"entity": "us_states", "path": "data/postgres/us_states/$1/", "keys": ["state_id"]}
]
_EOF_
)

# Configure tap-csv
meltano config tap-csv set quotechar \"
meltano config tap-csv set files "$fileconfig"

# target-postgres is pre-configured in meltano.yml and .env

# Extract and load
meltano run tap-csv target-postgres
