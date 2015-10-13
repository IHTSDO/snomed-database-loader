/* Create the database */
-- This is to create a schema inside a database instead of creating a blank database.
-- Postgres does not allow to drop a database within the same connection. Also, postgres does not allow switch database within sql statement.
drop schema if exists snomedct;
create schema if not exists snomedct;
set schema 'snomedct';
