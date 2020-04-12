#!/bin/bash


# Create schema in postgres

export PGPASSWORD='superset';
psql -a -f 'schema.sql' -h 127.0.0.1 -p 5432  -U superset

# states
psql  -c "truncate TABLE state_abbreviation;" -h 127.0.0.1 -p 5432  -U superset;
cat 'states.csv' | psql -c '\copy state_abbreviation from stdin csv header;' -h 127.0.0.1 -p 5432  -U superset


if [ ! -d COVID-19/.git ]
then
	git clone https://github.com/CSSEGISandData/COVID-19.git
	cd COVID-19/csse_covid_19_data/csse_covid_19_daily_reports 
else
    cd COVID-19
    git pull https://github.com/CSSEGISandData/COVID-19.git
    cd csse_covid_19_data/csse_covid_19_daily_reports 
fi





# Covid lookup
psql  -c "truncate TABLE covid_lookup;" -h 127.0.0.1 -p 5432  -U superset;
cat ../UID_ISO_FIPS_LookUp_Table.csv | psql -c '\copy covid_lookup from stdin csv header;' -h 127.0.0.1 -p 5432  -U superset


# truncate last line
for f in ./*csv;
	do [ -z $(tail -c1 $f) ] && truncate -s-1 $f;
	sed -i 's/\r//g' $f;
done;


export PGPASSWORD='superset';
psql  -c "truncate TABLE covid19;" -h 127.0.0.1 -p 5432  -U superset;

for f in ./0{1..2}*csv;
do
 echo $f;
 filename=$(basename -- "$f");
 filename="${filename%.*}";
 egrep -cv '#|^$' $f;
 psql  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
 cat $f | psql -c "\copy covid19 (province, country, last_update,confirmed,deaths, recovered) from stdin QUOTE '\"' csv header;" -h 127.0.0.1 -p 5432  -U superset;
done;


for f in ./03-{01..21}*csv; 
do
 echo $f;
 filename=$(basename -- "$f");
 filename="${filename%.*}";
 egrep -cv '#|^$' $f;
 psql  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
 cat $f | psql -c '\copy covid19 ("province","country","last_update","confirmed","deaths","recovered", "latitude", "longitude") from stdin csv header;' -h 127.0.0.1 -p 5432  -U superset;
done;




for f in ./03-{22..31}*csv; do  
 echo $f;
 filename=$(basename -- "$f");
 filename="${filename%.*}";
 egrep -cv '#|^$' $f;
 psql  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
 cat $f | psql -c '\copy covid19 ("fips","admin2","province","country","last_update","latitude", "longitude", "confirmed","deaths","recovered", active, "combined_key") from stdin csv header;' -h 127.0.0.1 -p 5432  -U superset;
done;

for f in ./04*csv; do  
 echo $f;
 filename=$(basename -- "$f");
 filename="${filename%.*}";
 egrep -cv '#|^$' $f;
 psql  -c "ALTER TABLE covid19 ALTER file_date SET DEFAULT '$filename';" -h 127.0.0.1 -p 5432  -U superset;
 cat $f | psql -c '\copy covid19 ("fips","admin2","province","country","last_update","latitude", "longitude", "confirmed","deaths","recovered", active, "combined_key") from stdin csv header;' -h 127.0.0.1 -p 5432  -U superset;
done;




cd ~/data
psql -a -f 'data_cleaning_queries.sql' -h 127.0.0.1 -p 5432  -U superset

