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

create or replace function check_asset_category ()
returns trigger
language plpgsql
as $$
begin
    if (select parent_id from asset_relations where asset_id = new.category) is null then
      return new;
    else
      raise exception  'Category of the new asset is not defined.';
    end if;
end; $$;

create or replace function check_asset_relation ()
returns trigger
language plpgsql
as $$
begin
    if (select parent_id from asset_relations where asset_id = new.top_id) is null then
      return new;
    else
      raise exception  'Top_id is invalid.';
    end if;
end; $$;

create or replace function check_task_supply ()
returns trigger
language plpgsql
as $$
declare
  qty_ok boolean;
  decimals_ok boolean;
  contract_ok boolean;
begin

  select ((b.qty_available + coalesce(old.qty, 0) - new.qty) >= 0),
         (z.qty_decimals or not (scale(new.qty) > 0)),
         (t.contract_id = s.contract_id)
         into
         qty_ok,
         decimals_ok,
         contract_ok
    from supplies as s
    inner join specs as z using (spec_id)
    inner join balances as b using (supply_id)
    inner join tasks as t on (t.task_id = new.task_id)
  where s.supply_id = new.supply_id;

  if not qty_ok then
    raise exception '% is larger than available', new.qty;
  elsif not decimals_ok then
    raise exception 'Decimal input is not allowed.';
  elsif not contract_ok then
    raise exception 'Contracts do not match.';
  else
    return new;
  end if;

end; $$;

-- create or replace function check_conclusion()
-- returns trigger
-- language plpgsql
-- as $$
-- declare
--   contract_ok boolean;
-- begin
--   if (new.status = 'CON' and new.date_end is not null) then
--     select every(coalesce(c.date_end, '9999-12-31'::date) >= new.date_end) into contract_ok
--         from task_supplies as ts
--         inner join contracts as c using (contract_id)
--         where os.task_id = new.task_id;
--     if (contract_ok) then
--       return new;
--     else
--       raise exception 'task % has an expired contract in its used supplies', new.task_id;
--     end if;
--   else
--     return new;
--   end if;
-- end; $$;
