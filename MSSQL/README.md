# SNOMED CT DATABASE

MSSQL SQL Scripts to create and populate a MSSQL database with a SNOMED CT terminology release

## Minimum Specification

- MSSQL 2008

# Creating the SNOMED CT DB schema on MS SQL

- Create an empty DB and execute manually script create-database-mssql.sql against it

## Diffences from the PostgreSQL version

- TSQL check for table presentse
- Changes `uniqueidentifier` for `uuid`

## Manual Installation

- Unpack Full version of SNOMED CT files
- Copy import.bat into root folder where Full SNOMED CR files were updacked (the root has "Documentation" and "Full" folders only)
- execute import.bat
- import.sql script will be generated. Execute it againt desired MS SQL DB 

You may use sqlcmd to execute import.sql
sqlcmd -b -I -S [server IP/name, port] -d [DB name] -U [User] -P [Password] -i import.sql

Note: If you recieve message that "... Operating system error code 5(Access is denied.)" - please follow https://stackoverflow.com/questions/14555262/cannot-bulk-load-operating-system-error-code-5-access-is-denied
