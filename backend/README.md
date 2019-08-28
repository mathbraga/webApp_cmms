# Backend directory of CMMS project of Senado Federal

## /backend/database folder instructions:

1. Edit Excel files (*PostgreSQL-\*.xlsx*);
1. Make sure *PostgreSQL-all.xlsx* [ 1 ] has been updated with all changes;
1. Paste the contents of *PostgreSQL-all.xlsx* into *create_db.sql*;
1. Save *create_db.sql* with **Windows 1252** encoding;
1. To create a new database, run the command **\i create_db.sql** in **psql** environment;
1. Wait the execution (last line should be **COMMIT**);
1. New database is ready.

### [ 1 ] Order of SQL commands inside *PostgreSQL-all.xlsx* file:

  #### Example: [ name of the file ] Command(s)

  1. [ first ] First commands
      1. Create new database
      1. Switch from currently connected database to the new one
      1. Create extension (pgcrypto)
      1. Create private schema (not exposed to PostGraphile)
      1. Begin transaction
  1. [ types ] Create custom types (enums)
  1. [ *many* ] Create tables following this order:
      1. assets
      1. contracts
      1. ceb_meters
      1. ceb_meters_assets
      1. ceb_bills
      1. caesb_meters
      1. caesb_meters_assets
      1. caesb_bills
      1. departments
      1. persons
      1. private.accounts
      1. orders
      1. orders_messages
      1. orders_assets
      1. assets_departments
  1. [ *many* ] Insert values into tables (same order as creation of tables)
  1. [ functions ] Create functions (get ceb bills, get caesb bills)
  1. [ authentication ] Configure authentication 
      1. Create roles
      1. Create register function
      1. Create authenticate function
      1. Create users and their accounts (run register function)
  1. [ last ] End transaction (COMMIT;)