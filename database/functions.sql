create or replace function insert_person (
  person_attributes persons,
  input_person_role person_role_type
) returns integer
language plpgsql
strict
security definer
as $$
declare
  new_person_id integer;
begin

  insert into persons values (
    default,
    person_attributes.cpf,
    person_attributes.email,
    person_attributes.name,
    person_attributes.phone,
    person_attributes.cellphone,
    person_attributes.contract_id
  ) returning * into new_person_id;
  
  insert into private.accounts values (
    new_person_id,
    crypt('123456', gen_salt('bf', 10)),
    true,
    input_person_role
  );

  return new_person_id;

end; $$;

create or replace function authenticate (
  in input_email    text,
  in input_password text,
  out user_data text
)
language sql
stable
strict
security definer
as $$
  select p.person_id::text || '-' || a.person_role::text as user_data
    from persons as p
    inner join private.accounts as a using (person_id)
    where p.email = input_email
          and
          a.password_hash = crypt(input_password, a.password_hash)
          and
          a.is_active;
$$;

create or replace function create_log ()
returns trigger
language plpgsql
security definer
as $$
begin

  insert into private.logs values (
    current_setting('auth.data.person_id')::integer,
    now(),
    tg_op::text,
    tg_table_name::text,
    to_jsonb(old),
    to_jsonb(new)
  );

  return null; -- result is ignored since this is an after trigger

end; $$;

create or replace function insert_appliance (
  in appliance_attributes appliances,
  -- in departments_array integer[],
  out new_appliance_sf text
)
language plpgsql
as $$
begin
  insert into appliances values (
    default,
    appliance_attributes.asset_sf,
    appliance_attributes.name,
    appliance_attributes.description,
    'A'::asset_category_type,
    appliance_attributes.manufacturer,
    appliance_attributes.serialnum,
    appliance_attributes.model,
    appliance_attributes.price
  ) returning asset_sf into new_appliance_sf;
  -- if departments_array is not null then
  --   insert into asset_departments select asset_id, unnest(departments_array);
  -- end if;
end; $$;


create or replace function insert_facility (
  in facility_attributes facilities,
  -- in departments_array integer[],
  out new_facility_sf text
)
language plpgsql
as $$
begin
  insert into facilities values (
    default,
    facility_attributes.asset_sf,
    facility_attributes.name,
    facility_attributes.description,
    'F'::asset_category_type,
    facility_attributes.latitude,
    facility_attributes.longitude,
    facility_attributes.area
  ) returning asset_sf into new_facility_sf;
  -- if departments_array is not null then
  --   insert into asset_departments select asset_id, unnest(departments_array);
  -- end if;
end; $$;

create or replace function insert_order (
  in attributes orders,
  in assets integer[],
  in files_metadata files_metadata[],
  out result integer
)
language plpgsql
as $$
begin
  insert into orders values (
    default,
    attributes.status,
    attributes.priority,
    attributes.category,
    attributes.parent,
    attributes.contract_id,
    attributes.title,
    attributes.description,
    attributes.department_id,
    attributes.created_by,
    attributes.contact_name,
    attributes.contact_phone,
    attributes.contact_email,
    attributes.place,
    attributes.progress,
    attributes.date_limit,
    attributes.date_start,
    attributes.date_end,
    default,
    default
  ) returning order_id into result;

  insert into order_assets select result, unnest(assets);

  insert into order_files
    select result,
           f.filename,
           f.uuid,
           f.size,
           current_setting('auth.data.person_id')::integer,
           now()
      from unnest(files_metadata) as f;

end; $$;

create or replace function insert_team (
  in team_attributes teams,
  in persons_array integer[],
  out new_team_id integer
)
language plpgsql
strict
as $$
declare
  new_team_id integer;
begin

  insert into teams values (
    default,
    team_attributes.name,
    team_attributes.description,
    true
  ) returning team_id into new_team_id;

  insert into team_persons select new_team_id, unnest(persons_array);

end; $$;

-- create or replace function insert_contract (
--   in contract_attributes contracts,
--   in supplies_array supplies[]
-- )
-- returns text
-- language plpgsql
-- as $$
-- declare
--   new_contract_id text;
-- begin

--   insert into contracts
--     select (contract_attributes.*)
--     returning contract_id into new_contract_id;

--   insert into supplies
--     select ((unnest(supplies_array)).*);

--   return new_contract_id;

-- end; $$;

-- create or replace function check_asset_integrity()
-- returns trigger
-- language plpgsql
-- as $$
-- begin
--   -- facility case
--   if new.category = 'F' then
--     if (select category from assets where asset_id = new.parent) = 'F' then
--       return new;
--     else
--       raise exception  'Parent attribute of the new facility must be a facility';
--     end if;
  
--     if (select category from assets where asset_id = new.place) = 'F' then
--       return new;
--     else
--       raise exception 'Place attribute of the new facility must be a facility';
--     end if;
--   end if;

--   -- appliance case
--   if new.category = 'A' then
--     if (select category from assets where asset_id = new.parent) = 'A' then
--       return new;
--     else
--       raise exception 'Parent attribute of the new appliance must be an appliance';
--     end if;
--     if (select category from assets where asset_id = new.place) = 'A' then
--       return new;
--     else
--       raise exception 'Place attribute of the new appliance must be a facility';
--     end if;
--     if (new.description = '' or new.description is null) then
--       raise exception 'New appliance must have a description';
--     end if;
--   end if;
-- end; $$;

-- create or replace function modify_appliance (
--   in appliance_attributes appliances,
--   in departments_array text[],
--   out modified_appliance_id text
-- )
-- language plpgsql
-- as $$
-- begin
--   update assets as a
--     set (
--       title,
--       description,
--       category,
--       manufacturer,
--       serialnum,
--       model,
--       price,
--       warranty
--     ) = (
--       appliance_attributes.title,
--       appliance_attributes.description,
--       appliance_attributes.category,
--       appliance_attributes.manufacturer,
--       appliance_attributes.serialnum,
--       appliance_attributes.model,
--       appliance_attributes.price,
--       appliance_attributes.warranty
--     ) where a.asset_id = appliance_attributes.asset_id;

--   -- with added_departments as (
--   --   select unnest(departments_array) as department_id
--   --   except
--   --   select department_id
--   --     from asset_departments
--   --     where asset_id = appliance_attributes.asset_id
--   -- )
--   -- insert into asset_departments
--   --   select appliance_attributes.asset_id, department_id from added_departments;
  
--   -- with recursive removed_departments as (
--   --   select department_id
--   --     from asset_departments
--   --   where asset_id = appliance_attributes.asset_id
--   --   except
--   --   select unnest(departments_array) as department_id
--   -- )
--   -- delete from asset_departments
--   --   where asset_id = appliance_attributes.asset_id
--   --         and department_id in (select department_id from removed_departments);

--   modified_appliance_id = appliance_attributes.asset_id;

-- end; $$;


-- create or replace function modify_facility (
--   in facility_attributes facilities,
--   in departments_array text[],
--   out modified_facility_id text
-- )
-- language plpgsql
-- as $$
-- begin
--   update assets as a
--     set (
--       parent,
--       place,
--       name,
--       description,
--       category,
--       latitude,
--       longitude,
--       area
--     ) = (
--       facility_attributes.parent,
--       facility_attributes.place,
--       facility_attributes.name,
--       facility_attributes.description,
--       facility_attributes.category,
--       facility_attributes.latitude,
--       facility_attributes.longitude,
--       facility_attributes.area
--     ) where a.asset_id = facility_attributes.asset_id;

--   with added_departments as (
--     select unnest(departments_array) as department_id
--     except
--     select department_id
--       from asset_departments
--       where asset_id = facility_attributes.asset_id
--   )
--   insert into asset_departments
--     select facility_attributes.asset_id, department_id from added_departments;
  
--   with recursive removed_departments as (
--     select department_id
--       from asset_departments
--     where asset_id = facility_attributes.asset_id
--     except
--     select unnest(departments_array) as department_id
--   )
--   delete from asset_departments
--     where asset_id = facility_attributes.asset_id
--           and department_id in (select department_id from removed_departments);

--   modified_facility_id = facility_attributes.asset_id;

-- end; $$;

-- create or replace function modify_order (
--   in order_attributes orders,
--   in assets_array text[],
--   out modified_order_id integer
-- )
-- language plpgsql
-- strict
-- as $$
-- begin
--   update orders as o
--     set (
--       status,
--       priority,
--       category,
--       parent,
--       team_id,
--       progress,
--       title,
--       description,
--       origin_department,
--       origin_person,
--       contact_name,
--       contact_phone,
--       contact_email,
--       place,
--       date_limit,
--       date_start,
--       updated_at
--     ) = (
--       order_attributes.status,
--       order_attributes.priority,
--       order_attributes.category,
--       order_attributes.parent,
--       order_attributes.team_id,
--       order_attributes.progress,
--       order_attributes.title,
--       order_attributes.description,
--       order_attributes.origin_department,
--       order_attributes.origin_person,
--       order_attributes.contact_name,
--       order_attributes.contact_phone,
--       order_attributes.contact_email,
--       order_attributes.place,
--       order_attributes.date_limit,
--       order_attributes.date_start,
--       default
--     ) where o.order_id = order_attributes.order_id;

--   with added_assets as (
--     select unnest(assets_array) as asset_id
--     except
--     select asset_id
--       from order_assets
--       where order_id = order_attributes.order_id
--   )
--   insert into order_assets
--     select order_attributes.order_id, asset_id from added_assets;
  
--   with recursive removed_assets as (
--     select asset_id
--       from order_assets
--     where order_id = order_attributes.order_id
--     except
--     select unnest(assets_array) as asset_id
--   )
--   delete from order_assets
--     where order_id = order_attributes.order_id
--           and asset_id in (select asset_id from removed_assets);

--   modified_order_id = order_attributes.order_id;

-- end; $$;

-- create or replace function modify_team (
--   in team_attributes teams,
--   in persons_array integer[],
--   out modified_team_id integer
-- )
-- returns integer
-- language plpgsql
-- strict
-- as $$
-- begin

--   update teams
--     set (
--       name,
--       description,
--       is_active
--     ) = (
--       team_attributes.name,
--       team_attributes.description,
--       team_attributes.is_active
--     )
--     where team_id = team_attributes.team_id;

--   with added_persons as (
--     select unnest(persons_array) as person_id
--     except
--     select person_id
--       from team_persons
--       where team_id = team_attributes.team_id
--   )
--   insert into team_persons
--     select team_attributes.team_id, person_id from added_persons;
  
--   with recursive removed_persons as (
--     select person_id
--       from team_persons
--     where team_id = team_attributes.team_id
--     except
--     select unnest(persons_array) as person_id
--   )
--   delete from team_persons
--     where team_id = team_attributes.team_id
--           and person_id in (select person_id from removed_persons);

--   modified_team_id = team_attributes.team_id;

-- end; $$;

-- create or replace function modify_profile (
--   person_attributes persons,
--   new_password text
-- )
-- returns integer
-- language plpgsql
-- security definer
-- as $$
-- begin

--   update persons set (
--     cpf,
--     email,
--     full_name,
--     phone,
--     cellphone
--   ) = (
--     person_attributes.cpf,
--     person_attributes.email,
--     person_attributes.full_name,
--     person_attributes.phone,
--     person_attributes.cellphone
--   ) where person_id = current_setting('auth.data.person_id')::integer;

--   update private.accounts set (
--     password_hash
--   ) = (
--     crypt(new_password, gen_salt('bf', 10))
--   ) where person_id = current_setting('auth.data.person_id')::integer;

--   return current_setting('auth.data.person_id')::integer;

-- end; $$;

-- create or replace function modify_person (
--   person_attributes persons,
--   new_is_active boolean,
--   new_person_role text
-- )
-- returns integer
-- language plpgsql
-- security definer
-- as $$
-- begin

--   update persons set (
--     cpf,
--     email,
--     full_name,
--     phone,
--     cellphone,
--     contract_id
--   ) = (
--     person_attributes.cpf,
--     person_attributes.email,
--     person_attributes.full_name,
--     person_attributes.phone,
--     person_attributes.cellphone,
--     person_attributes.contract_id
--   ) where person_id = person_attributes.person_id;

--   update private.accounts set (
--     password_hash,
--     is_active,
--     person_role
--   ) = (
--     crypt(new_password, gen_salt('bf', 10)),
--     new_is_active,
--     new_person_role
--   ) where person_id = person_attributes.person_id;

--   return person_attributes.person_id;

-- end; $$;

-- create or replace function get_asset_history (
--   in asset_id integer,
--   out full_name text,
--   out created_at timestamptz,
--   out operation text,
--   out tablename text,
--   out old_row jsonb,
--   out new_row jsonb
-- )
-- returns setof record
-- security definer
-- language sql
-- stable
-- as $$
--   select p.full_name,
--          l.created_at,
--          l.operation,
--          l.tablename,
--          l.old_row,
--          l.new_row
--     from private.logs as l
--     inner join persons as p using (person_id)
--   where (l.tablename = 'assets' or l.tablename = 'asset_departments' or l.tablename = 'order_assets')
--         and
--         (
--           l.new_row @> ('{"asset_id": "' || asset_id || '"}')::jsonb
--           or
--           l.old_row @> ('{"asset_id": "' || asset_id || '"}')::jsonb
--         );
-- $$;

-- create or replace function get_order_history (
--   in order_id integer,
--   out full_name text,
--   out created_at timestamptz,
--   out operation text,
--   out tablename text,
--   out old_row jsonb,
--   out new_row jsonb
-- )
-- returns setof record
-- security definer
-- language sql
-- stable
-- as $$
--   select p.full_name,
--          l.created_at,
--          l.operation,
--          l.tablename,
--          l.old_row,
--          l.new_row
--     from private.logs as l
--     inner join persons as p using (person_id)
--   where (l.tablename = 'orders' or l.tablename = 'order_assets' or l.tablename = 'order_supplies')
--         and
--         (
--           l.new_row @> ('{"order_id": ' || order_id || '}')::jsonb
--           or
--           l.old_row @> ('{"order_id": ' || order_id || '}')::jsonb
--         );
-- $$;

-- create or replace function check_conclusion()
-- returns trigger
-- language plpgsql
-- as $$
-- declare
--   contract_ok boolean;
-- begin
--   if (new.status = 'CON' and new.date_end is not null) then
--     select every(coalesce(c.date_end, '9999-12-31'::date) >= new.date_end) into contract_ok
--         from order_supplies as os
--         inner join contracts as c using (contract_id)
--         where os.order_id = new.order_id;
--     if (contract_ok) then
--       return new;
--     else
--       raise exception 'Order % has an expired contract in its used supplies', new.order_id;
--     end if;
--   else
--     return new;
--   end if;
-- end; $$;

-- create or replace function check_supply_qty()
-- returns trigger
-- language plpgsql
-- as $$
-- declare
--   qty_ok boolean;
-- begin
--   select (b.available + coalesce(old.qty, 0) - new.qty) >= 0 into qty_ok
--     from balances as b
--     where (b.contract_id = new.contract_id and b.supply_id = new.supply_id);
--   if qty_ok then
--     return new;
--   else
--     raise exception '% is larger than available', new.qty;
--   end if;
-- end; $$;