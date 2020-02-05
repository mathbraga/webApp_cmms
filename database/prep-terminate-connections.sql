select pg_terminate_backend(pid)
  from pg_stat_activity
where
  -- don't kill my own connection!
  pid <> pg_backend_pid()
  -- don't kill the connections to other databases
  and datname = :'new_db_name'
;