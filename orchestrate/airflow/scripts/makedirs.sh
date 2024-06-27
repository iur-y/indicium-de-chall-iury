# makedirs.sh: given a list of names and command line arguments, create one directory for each name
# $1 is {{ ds }}
# $2 is ${MELTANO_PROJECT_ROOT}

TABLES="categories customers employee_territories employees orders products region shippers suppliers territories us_states"

for table in $TABLES; do 
    path="$2/data/postgres/${table}/$1/";
    echo "Making directory $path";
    mkdir -p "$path";
done

mkdir -p "$2/data/csv/$1/"

