/* Create the database */
-- This is to create a schema inside a database instead of creating a blank database.
-- Postgres does not allow to drop a database within the same connection. 
-- Also, postgres does not allow switch database within sql statement. A new connection must be estabilished for changing database target.
drop schema if exists snomedct cascade;
create schema snomedct;
set schema 'snomedct';
