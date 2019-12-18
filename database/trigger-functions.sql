create or replace function log_change ()
returns trigger
language plpgsql
security definer
as $$
begin

  insert into private.changes values (
    current_setting('auth.data.person_id')::integer,
    now(),
    tg_op::text,
    tg_table_name::text,
    to_jsonb(old),
    to_jsonb(new)
  );

  return null; -- result is ignored since this is an after trigger

end; $$;

create or replace function check_task_supply ()
returns trigger
language plpgsql
as $$
declare
  qty_ok boolean;
begin
  select (b.available + coalesce(old.qty, 0) - new.qty) >= 0 into qty_ok
    from balances as b
    where b.supply_id = new.supply_id;
  if qty_ok then
    return new;
  else
    raise exception '% is larger than available', new.qty;
  end if;
end; $$;