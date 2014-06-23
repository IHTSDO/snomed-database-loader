# Creating the SNOMED CT schema on PostgreSQL



PostgreSQL is an [`ORDBMS`](http://en.wikipedia.org/wiki/ORDBMS) therefore every Database 
is self-contained object. A _"database"_ contains logins, one or more schemas, groups, 
etc. and every conection is related to a sigle database. 

## Diffences from the MySQL version


* PostgreSQL does not need `engine=myisam` which by itself is a bit strange as `myisam` 
does not support foreign keys. 
* Changes `database` for `schema`
