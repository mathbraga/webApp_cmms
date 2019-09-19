drop table if exists private.logs;
drop trigger if exists log_changes on assets;
drop trigger if exists log_changes on orders;
-----------------------------------------------------------------
create table private.logs (
  person_id         integer      not null,
  stamp             timestamp    not null,
  operation         text         not null,
  tablename         text         not null,
  old_row           text,
  new_row           text
);
-----------------------------------------------------------------
create or replace function create_logs ()
returns trigger as $$
begin

  insert into private.logs2 values (
    current_setting('auth.data.person_id')::integer,
    now(),
    tg_op,
    tg_table_name::text,
    row_to_json(old, false),
    row_to_json(new, false)
  );

  return null; -- result is ignored since this is an after trigger

end;
$$
security definer
language plpgsql;
-----------------------------------------------------------------
create trigger log_changes
after insert or update or delete on orders
for each row execute function create_logs();
-----------------------------------------------------------------
create trigger log_changes
after insert or update or delete on orders_messages
for each row execute function create_logs();
-----------------------------------------------------------------
create trigger log_changes
after insert or update or delete on orders_assets
for each row execute function create_logs();
-----------------------------------------------------------------
create trigger log_changes
after insert or update or delete on assets
for each row execute function create_logs();
-----------------------------------------------------------------
create trigger log_changes
after insert or update or delete on assets_departments;
for each row execute function create_logs();
-----------------------------------------------------------------
create trigger log_changes
after insert or update or delete on contracts
for each row execute function create_logs();
-----------------------------------------------------------------
create trigger log_changes
after insert or update or delete on departments
for each row execute function create_logs();
-----------------------------------------------------------------

            -- persons and private.logs tables must not log
            -- because operations in those tables might
            -- have no current_setting(auth.data.person_id)


-- create trigger log_changes
-- after insert or update or delete on persons
-- for each row execute function create_logs();
-----------------------------------------------------------------
-- create trigger log_changes
-- after insert or update or delete on private.accounts
-- for each row execute function create_logs();
-----------------------------------------------------------------