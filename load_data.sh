#!/bin/bash

 # Wait for PostgreSQL to be ready
 until PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -U $POSTGRES_USER -d $POSTGRES_DB -c '\q'; do
   >&2 echo "Postgres is unavailable - sleeping"
   sleep 1
 done

 >&2 echo "Postgres is up - executing command"

 # Create tables
 psql -U $POSTGRES_USER -d $POSTGRES_DB -f /docker-entrypoint-initdb.d/ACME_small.ddl

 # Load data
 for file in /docker-entrypoint-initdb.d/*.csv
 do
   table=$(basename "$file" .csv)
   psql -U $POSTGRES_USER -d $POSTGRES_DB -c "\COPY $table FROM '$file' WITH CSV HEADER"
 done

 echo "Data loading completed"
