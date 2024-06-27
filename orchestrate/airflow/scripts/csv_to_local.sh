# csv_to_local.sh: using meltano, extract data from ${MELTANO_PROJECT_ROOT}/data/order_details.csv and load to tmpdata
# $1 is {{ ds }}
# $2 is ${MELTANO_PROJECT_ROOT}

set -e

fileconfig='[{"entity": "order_details", "path": "data/order_details.csv", "keys": ["order_id", "product_id"]}]'

# Check if MELTANO_PROJECT_ROOT directory exists
if [ -d "$2" ]; then
  cd "$2";
else
  echo "Directory $2 does not exist" 2>&1;
  exit 1;
fi

# Temporary directory to store all extracted tables
mkdir -p tmpdata

# Configure target-csv
meltano config target-csv set destination_path tmpdata
meltano config target-csv set quotechar \"
meltano config target-csv set delimiter ,

# Configure tap-csv
meltano config tap-csv set quotechar \"
meltano config tap-csv set files "$fileconfig"

# Extract and load
meltano run tap-csv target-csv
