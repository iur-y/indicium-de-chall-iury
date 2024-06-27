# organize_files.sh: move files from tmpdata directory to their respective places inside the data directory
# $1 is {{ ds }}
# $2 is ${MELTANO_PROJECT_ROOT}

if [ -d "$2" ]; then
  cd $2;
else
  echo "Directory $2 does not exist" 2>&1;
  exit 1;
fi

if [ ! -d "tmpdata" ]; then
  echo "tmpdata directory does not exist" 2>&1;
  exit 1;
else
    files="$(ls tmpdata)";
fi

if [ -z "$files" ]; then
    echo "Empty directory, nothing to move" 2>&1;
    exit 1;
fi

pattern="categories|customers|employee_territories|employees|orders|products|region|shippers|suppliers|territories|us_states"

# If there are files in tmpdata, move them
# Works as long as the table names can be found in the file naming scheme used by meltano's target-csv hotgluexyz variant:
# postgresschema-tablename-datetime.csv
for file in $files; do

    match=$(echo "$file" | grep -oE "$pattern")

    # If there's a match
    if [ -n "$match" ]; then
        destination_path="data/postgres/${match}/$1";

    # Else, check if it's the order_details file
    else
        if [ $(echo "$file" | grep -oE "order_details") ]; then
            destination_path="data/csv/$1";
        fi

    fi

    # If we have a valid file, move it
    if [ -n "$destination_path" ]; then
        mv "./tmpdata/$file" "$destination_path";

    else
        # Make sure previous destination_path doesn't interfere with the next iteration
        destination_path="";
    fi

done

# Clean tmpdata
rm ./tmpdata/*
