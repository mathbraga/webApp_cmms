# Backend directory of CMMS project of Senado Federal

## database folder instructions:

1. Edit Excel files (*PostgreSQL-\*.xlsx*);
2. Make sure *PostgreSQL-all.xlsx* has been updated with all changes;
3. Paste the contents of *PostgreSQL-all.xlsx* into *create_db.sql*;
4. Save *create_db.sql* with **Windows 1252** encoding;
5. To create a new database, run the command **\i create_db.sql** in **psql** environment;
6. Wait the execution (last line should be **COMMIT**);
7. New database is ready.