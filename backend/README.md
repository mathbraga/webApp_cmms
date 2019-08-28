# Backend directory of CMMS project of Senado Federal

## /backend/database folder instructions:

1. Edit Excel files (*PostgreSQL-\*.xlsx*);
2. Make sure *PostgreSQL-all.xlsx* [ 1 ] has been updated with all changes;
3. Paste the contents of *PostgreSQL-all.xlsx* into *create_db.sql*;
4. Save *create_db.sql* with **Windows 1252** encoding;
5. To create a new database, run the command **\i create_db.sql** in **psql** environment;
6. Wait the execution (last line should be **COMMIT**);
7. New database is ready.

### [ 1 ] Order of SQL commands inside *PostgreSQL-all.xlsx* file:

  1. Create new database
  2. Switch from currently connected database to the new one
  3. Create extension (pgcrypto)
  4. Create custom types (enums)
  5. Create private schema (not exposed to PostGraphile)
  6. Create tables (correct order)
  7. Insert first batch of values (referenced items)
  8. Insert second batch of values (referencing items)
  9. Create functions (get ceb bills, get caesb bills)
  10. Configure authentication 
      * Create roles
      * Create register function
      * Create authenticate function
      * Create users and their accounts (run register function)
