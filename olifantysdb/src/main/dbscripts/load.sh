#!bin/bash
cd $(dirname $0)
dropdb --if-exists olifantysbank 

createdb -O olifantys olifantysbank

cat olifantys_schema.sql | psql -E -X -U olifantys olifantysbank
cat olifantys_functions.sql | psql -E -X -U olifantys olifantysbank
 
# exit 0

cat transactintable.sql | psql -X -U olifantys olifantysbank
echo loaded transactintable

cat getaccount_event.sql | psql -X -U olifantys olifantysbank
echo loaded getaccount_event.sql

cat bankingactions2.sql | psql -X -U olifantys olifantysbank

echo done loading bankingactions

cat testdata.sql | psql -E -U olifantys olifantysbank

echo sql tests

cat sqltests.sql | psql -E -U olifantys olifantysbank

