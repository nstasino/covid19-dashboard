#!/bin/bash
echo "Today is $(date)"

SCRIPTS_DIR="${PWD}"
DATA_DIR="${SCRIPTS_DIR}/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports"

CSSE_GITHUB_REPO="https://github.com/CSSEGISandData/COVID-19.git"
export PGPASSWORD='superset';


yell() { echo "$(date): $0: $*" >> ${SCRIPTS_DIR}/error.log; echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

if [ ! -d COVID-19/.git  ]

then
	# echo "Cloning anew"
	cd "${PWD}"
	git clone "${CSSE_GITHUB_REPO}"
	cd $DATA_DIR

	# Create schema in postgres

	export PGPASSWORD='superset';
	try psql -a -f "${SCRIPTS_DIR}/schema.sql" -h 127.0.0.1 -p 5432  -U superset

	# states
	try psql -a  -c "truncate TABLE state_abbreviation;" -h 127.0.0.1 -p 5432  -U superset;
	cat "${SCRIPTS_DIR}/states.csv" | try psql -a -c "\copy state_abbreviation from stdin csv header;" -h 127.0.0.1 -p 5432  -U superset



	# Covid lookup
	try psql -a  -c "truncate TABLE covid_lookup;" -h 127.0.0.1 -p 5432  -U superset;
	cat "${SCRIPTS_DIR}/COVID-19/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv" | try psql -a -c "\copy covid_lookup from stdin csv header;" -h 127.0.0.1 -p 5432  -U superset


	# truncate last line
	for f in ./*csv;
	do [ -z $(tail -c1 $f) ] && truncate -s-1 $f;
	sed -i 's/\r//g' $f;
	done;


	export PGPASSWORD='superset';
	try psql -a  -c "truncate TABLE covid19;" -h 127.0.0.1 -p 5432  -U superset;

	for f in ./0{1..2}*csv;
	do
	# echo $f;
	filename=$(basename -- "$f");
	filename="${filename%.*}";
	egrep -cv '#|^$' $f;
	try psql -a  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
	cat $f | try psql -a -c "\copy covid19 (province, country, last_update,confirmed,deaths, recovered) from stdin QUOTE '\"' csv header;" -h 127.0.0.1 -p 5432  -U superset;
	done;


	for f in ./03-{01..21}*csv; 
	do
	# echo $f;
	filename=$(basename -- "$f");
	filename="${filename%.*}";
	egrep -cv '#|^$' $f;
	try psql -a  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
	cat $f | try psql -a -c '\copy covid19 ("province","country","last_update","confirmed","deaths","recovered", "latitude", "longitude") from stdin csv header;' -h 127.0.0.1 -p 5432  -U superset;
	done;




	for f in ./03-{22..31}*csv; do  
	# echo $f;
	filename=$(basename -- "$f");
	filename="${filename%.*}";
	egrep -cv '#|^$' $f;
	try psql -a  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
	cat $f | try psql -a -c '\copy covid19 ("fips","admin2","province","country","last_update","latitude", "longitude", "confirmed","deaths","recovered", active, "combined_key") from stdin csv header;' -h 127.0.0.1 -p 5432  -U superset;
	done;

	for f in ./0{4..5}*csv; do  
	# echo $f;
	filename=$(basename -- "$f");
	filename="${filename%.*}";
	egrep -cv '#|^$' $f;
	try psql -a  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
	cat $f | try psql -a -c '\copy covid19 ("fips","admin2","province","country","last_update","latitude", "longitude", "confirmed","deaths","recovered", active, "combined_key") from stdin csv header;' -h 127.0.0.1 -p 5432  -U superset;
	done;




	cd ${SCRIPTS_DIR}
	try psql -a  -f "${SCRIPTS_DIR}/data_cleaning_queries.sql" -h 127.0.0.1 -p 5432  -U superset

	
else
    cd "${SCRIPTS_DIR}/COVID-19"
    echo "${PWD}"

    git fetch origin
    if ! git diff --quiet origin/master; then
    	echo "Pulling update"
	    git checkout .
	    git pull "${CSSE_GITHUB_REPO}"
	    cd "${DATA_DIR}" 


		# Create schema in postgres

		export PGPASSWORD='superset';
		try psql -a  -f "${SCRIPTS_DIR}/schema.sql" -h 127.0.0.1 -p 5432  -U superset

		# states
		try psql -a  -c "truncate TABLE state_abbreviation;" -h 127.0.0.1 -p 5432  -U superset;
		cat "${SCRIPTS_DIR}/states.csv" | try psql -a -c "\copy state_abbreviation from stdin csv header;" -h 127.0.0.1 -p 5432  -U superset



		# Covid lookup
		try psql -a  -c "truncate TABLE covid_lookup;" -h 127.0.0.1 -p 5432  -U superset;
		cat "${SCRIPTS_DIR}/COVID-19/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv" | try psql -a -c "\copy covid_lookup from stdin csv header;" -h 127.0.0.1 -p 5432  -U superset


		# truncate last line
		for f in ./*csv;
			do [ -z $(tail -c1 $f) ] && truncate -s-1 $f;
			sed -i 's/\r//g' $f;
		done;


		export PGPASSWORD='superset';
		try psql -a  -c "truncate TABLE covid19;" -h 127.0.0.1 -p 5432  -U superset;

		for f in ./0{1..2}*csv;
		do
		 # echo $f;
		 filename=$(basename -- "$f");
		 filename="${filename%.*}";
		 egrep -cv '#|^$' $f;
		 try psql -a  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
		 cat $f | try psql -a -c "\copy covid19 (province, country, last_update,confirmed,deaths, recovered) from stdin QUOTE '\"' csv header;" -h 127.0.0.1 -p 5432  -U superset;
		done;


		for f in ./03-{01..21}*csv; 
		do
		 # echo $f;
		 filename=$(basename -- "$f");
		 filename="${filename%.*}";
		 egrep -cv '#|^$' $f;
		 try psql -a  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
		 cat $f | try psql -a -c '\copy covid19 ("province","country","last_update","confirmed","deaths","recovered", "latitude", "longitude") from stdin csv header;' -h 127.0.0.1 -p 5432  -U superset;
		done;




		for f in ./03-{22..31}*csv; do  
		 # echo $f;
		 filename=$(basename -- "$f");
		 filename="${filename%.*}";
		 egrep -cv '#|^$' $f;
		 try psql -a  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
		 cat $f | try psql -a -c '\copy covid19 ("fips","admin2","province","country","last_update","latitude", "longitude", "confirmed","deaths","recovered", active, "combined_key") from stdin csv header;' -h 127.0.0.1 -p 5432  -U superset;
		done;

		for f in ./0{4..5}*csv; do  
		 # echo $f;
		 filename=$(basename -- "$f");
		 filename="${filename%.*}";
		 egrep -cv '#|^$' $f;
		 try psql -a  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
		 cat $f | try psql -a -c '\copy covid19 ("fips","admin2","province","country","last_update","latitude", "longitude", "confirmed","deaths","recovered", active, "combined_key") from stdin csv header;' -h 127.0.0.1 -p 5432  -U superset;
		done;


		cd ${SCRIPTS_DIR}
		try psql -a -f "${SCRIPTS_DIR}/data_cleaning_queries.sql" -h 127.0.0.1 -p 5432  -U superset

		# Revert changes in the covid git repo to all the checky git diff --quiet origin/master; 
        cd "${SCRIPTS_DIR}/COVID-19"
        git checkout .

	fi
fi