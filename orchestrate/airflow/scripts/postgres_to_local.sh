# postgres_to_local.sh: using meltano, extract data from containerized postgres database and load to local disk
# $1 is {{ ds }}
# $2 is ${MELTANO_PROJECT_ROOT}

set -e

# Check if MELTANO_PROJECT_ROOT directory exists
if [ -d "$2" ]; then
  cd "$2";
else
  echo "Directory $2 does not exist" 2>&1;
  exit 1
fi

# Temporary directory to store all extracted tables
mkdir -p tmpdata

# tap-postgres is pre-configured in meltano.yml and .env

# Configure target-csv
meltano config target-csv set destination_path tmpdata
meltano config target-csv set quotechar \"
meltano config target-csv set delimiter ,

# Extract and load
meltano run tap-postgres target-csv
