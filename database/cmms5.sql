-- connect to other database
\c hzl

-- drop database
drop database if exists cmms5;

-- create new database
create database cmms5 with owner postgres template template0; --encoding 'win1252';

-- connect to the new database
\c cmms5

-- create extensions
create extension if not exists pgcrypto;

-- create additional schemas
create schema private;

-- set ON_ERROR_STOP to on
\set ON_ERROR_STOP on

-- begin transaction
begin transaction;

-- create roles (already created for the database cluster, not necessary in new databases)
-- drop role administrator;
-- drop role supervisor;
-- drop role employee;
-- drop role visitor;
-- create role administrator;
-- create role supervisor;
-- create role employee;
-- create role visitor;

-- alter default privileges
alter default privileges in schema public grant all on tables to public;
alter default privileges in schema public grant usage on sequences to public;
alter default privileges in schema public grant execute on routines to public;

-- create custom types
create type asset_category_type as enum (
  'F',
  'A'
);

create type order_status_type as enum (
  'CAN',
  'NEG',
  'PEN',
  'SUS',
  'FIL',
  'EXE',
  'CON'
);

create type order_priority_type as enum (
  'BAI',
  'NOR',
  'ALT',
  'URG'
);

create type order_category_type as enum (
  'ARC',
  'ELE',
  'ELV',
  'EST',
  'EXA',
  'FOR',
  'GRL',
  'HID',
  'INF',
  'MAR',
  'PIS',
  'REV',
  'SER',
  'VED',
  'VID'
);

create type person_role_type as enum (
  'administrator',
  'supervisor',
  'employee',
  'visitor'
);

-- create tables
create table assets (
  asset_id text primary key,
  parent text not null references assets (asset_id),
  place text not null references assets (asset_id),
  name text not null,
  description text,
  category asset_category_type not null,
  latitude real,
  longitude real,
  area real,
  manufacturer text,
  serialnum text,
  model text,
  price money,
  warranty text
);

create table contracts (
  contract_id text primary key,
  parent text references contracts (contract_id),
  date_sign date not null,
  date_pub date,
  date_start date not null,
  date_end date,
  company_name text not null,
  description text not null,
  url text not null
);

create table departments (
  department_id text primary key,
  parent text not null references departments (department_id),
  full_name text not null,
  is_active boolean not null
);

create table persons (
  person_id integer primary key generated always as identity,
  cpf text not null unique check (cpf ~ '^[0-9]{11}$'),
  email text not null unique check (email ~* '^.+@.+\..+$'),
  full_name text not null,
  phone text not null,
  cellphone text,
  contract_id text references contracts (contract_id)
);

create table private.accounts (
  person_id integer not null references persons (person_id),
  password_hash text not null,
  is_active boolean not null default true,
  person_role person_role_type not null
);

create table teams (
  team_id integer primary key generated always as identity,
  team_name text not null
);

create table team_persons (
  team_id integer references teams (team_id),
  person_id integer references persons (person_id),
  primary key (team_id, person_id)
);

create table orders (
  order_id bigint primary key generated always as identity,
  status order_status_type not null,
  priority order_priority_type not null,
  category order_category_type not null,
  parent integer references orders (order_id),
  team_id integer references teams (team_id),
  progress integer check (progress >= 0 and progress <= 100),
  title text not null,
  description text not null,
  department_id text not null references departments (department_id),
  created_by text not null,
  contact_name text not null,
  contact_phone text not null,
  contact_email text not null,
  place text,
  date_limit timestamptz,
  date_start timestamptz,
  date_end timestamptz,
  created_at timestamptz not null default now()
);

create table order_messages (
  order_id integer not null references orders (order_id),
  person_id integer not null references persons (person_id),
  message text not null
);

create table order_assets (
  order_id integer not null references orders (order_id),
  asset_id text not null references assets (asset_id),
  primary key (order_id, asset_id)
);

create table asset_departments (
  asset_id text not null references assets (asset_id),
  department_id text not null references departments (department_id),
  primary key (asset_id, department_id)
);

create table private.logs (
  person_id integer not null references persons (person_id),
  created_at timestamptz not null,
  operation text not null,
  tablename text not null,
  old_row jsonb,
  new_row jsonb
);

create table specs (
  spec_id integer primary key generated always as identity,
  spec_name text,
  spec_previous integer references specs (spec_id),
  category text,
  subcategory text,
  details text,
  materials text,
  services text,
  activities text,
  comments text,
  criteria text,
  tables jsonb,
  lifespan interval,
  commercial_ref text,
  external_ref text,
  is_subcont boolean,
  documental_ref text,
  catmatcatser text
);

create table supplies (
  contract_id text not null references contracts (contract_id),
  supply_id text not null,
  spec_id integer references specs (spec_id),
  qty_initial real not null,
  is_qty_real boolean not null,
  unit text not null,
  price money not null,
  estimated_price money,
  primary key (contract_id, supply_id)
);

create table order_supplies (
  order_id integer not null references orders (order_id),
  contract_id text not null,
  supply_id text not null,
  qty real not null,
  primary key (order_id, contract_id, supply_id),
  foreign key (contract_id, supply_id) references supplies (contract_id, supply_id)
);

-- create views
create view facilities as
  select
    asset_id,
    parent,
    place,
    name,
    description,
    category,
    latitude,
    longitude,
    area
  from assets
  where category = 'F'
  order by asset_id;

create view appliances as
  select
    asset_id,
    parent,
    place,
    name,
    description,
    category,
    manufacturer,
    serialnum,
    model,
    price,
    warranty
  from assets
  where category = 'A'
  order by asset_id;

create view balances as
  with
    unfinished as (
      select
        os.contract_id,
        os.supply_id,
        sum(os.qty) as blocked
          from orders as o
          inner join order_supplies as os using (order_id)
      where o.status <> 'CON'
      group by os.contract_id, os.supply_id
    ),
    finished as (
      select
        os.contract_id,
        os.supply_id,
        sum(os.qty) as consumed
          from orders as o
          inner join order_supplies as os using (order_id)
      where o.status = 'CON'
      group by os.contract_id, os.supply_id
    ),
    both_cases as (
      select contract_id,
             supply_id,
             sum(coalesce(blocked, 0)) as blocked,
             sum(coalesce(consumed, 0)) as consumed
        from unfinished
        full outer join finished using (contract_id, supply_id)
      group by contract_id, supply_id
    )
    select s.contract_id,
           s.supply_id,
           s.qty_initial,
           bc.blocked,
           bc.consumed,
           s.qty_initial - bc.blocked - bc.consumed as available
      from both_cases as bc
      inner join supplies as s using (contract_id, supply_id);

-- create functions
create or replace function insert_person (
  person_attributes persons,
  input_person_role person_role_type
) returns persons
language plpgsql
strict
security definer
as $$
declare
  new_person persons;
begin

  insert into persons (
    person_id,
    cpf,
    email,
    full_name,
    phone,
    cellphone,
    contract_id
  ) values (
    default,
    person_attributes.cpf,
    person_attributes.email,
    person_attributes.full_name,
    person_attributes.phone,
    person_attributes.cellphone,
    person_attributes.contract_id
  ) returning * into new_person;
  
  insert into private.accounts (
    person_id,
    password_hash,
    is_active,
    person_role
  ) values (
    new_person.person_id,
    crypt('123456', gen_salt('bf', 10)),
    true,
    input_person_role
  );

  return new_person;

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
    join private.accounts as a using(person_id)
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
    tg_op,
    tg_table_name::text,
    to_jsonb(old),
    to_jsonb(new)
  );

  return null; -- result is ignored since this is an after trigger

end; $$;

create or replace function insert_appliance (
  in appliance_attributes appliances,
  in departments_array  text[],
  out asset_id text
)
language plpgsql
as $$
begin
  insert into appliances as a values (appliance_attributes.*)
    returning a.asset_id into asset_id;
  if departments_array is not null then
    insert into asset_departments select asset_id, unnest(departments_array);
  end if;
end; $$;


create or replace function insert_facility (
  in facility_attributes facilities,
  in departments_array text[],
  out asset_id text
)
language plpgsql
as $$
begin
  insert into facilities as f values (facility_attributes.*)
    returning f.asset_id into asset_id;
  if departments_array is not null then
    insert into asset_departments select asset_id, unnest(departments_array);
  end if;
end; $$;

create or replace function insert_order (
  in order_attributes orders,
  in assets_array text[],
  out order_id integer
)
language plpgsql
strict
as $$
begin
  insert into orders as o (
    order_id,
    status,
    priority,
    category,
    parent,
    team_id,
    progress,
    title,
    description,
    origin_department,
    origin_person,
    contact_name,
    contact_phone,
    contact_email,
    contact_place,
    date_limit,
    date_start,
    created_at
  ) values (
    default,
    order_attributes.status,
    order_attributes.priority,
    order_attributes.category,
    order_attributes.parent,
    order_attributes.team_id,
    order_attributes.progress,
    order_attributes.title,
    order_attributes.description,
    order_attributes.origin_department,
    order_attributes.origin_person,
    order_attributes.contact_name,
    order_attributes.contact_phone,
    order_attributes.contact_email,
    order_attributes.contact_place,
    order_attributes.date_limit,
    order_attributes.date_start,
    order_attributes.date_end,
    default
  ) returning o.order_id into order_id;

  insert into order_assets select order_id, unnest(assets_array);

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

  insert into teams (
    team_id,
    team_name
  ) values (
    default,
    team_attributes.team_name
  ) returning team_id into new_team_id;

  insert into team_persons select new_team_id, unnest(persons_array);

end; $$;

create or replace function check_asset_integrity()
returns trigger
language plpgsql
as $$
begin
  -- facility case
  if new.category = 'F' then
    if (select category from assets where asset_id = new.parent) = 'F' then
      return new;
    else
      raise exception  'Parent attribute of the new facility must be a facility';
    end if;
  
    if (select category from assets where asset_id = new.place) = 'F' then
      return new;
    else
      raise exception 'Place attribute of the new facility must be a facility';
    end if;
  end if;

  -- appliance case
  if new.category = 'A' then
    if (select category from assets where asset_id = new.parent) = 'A' then
      return new;
    else
      raise exception 'Parent attribute of the new appliance must be an appliance';
    end if;
    if (select category from assets where asset_id = new.place) = 'A' then
      return new;
    else
      raise exception 'Place attribute of the new appliance must be a facility';
    end if;
    if (new.description = '' or new.description is null) then
      raise exception 'New appliance must have a description';
    end if;
  end if;
end; $$;

create or replace function modify_appliance (
  in appliance_attributes appliances,
  in departments_array text[],
  out modified_appliance_id text
)
language plpgsql
as $$
begin
  update assets as a
    set (
      parent,
      place,
      name,
      description,
      category,
      manufacturer,
      serialnum,
      model,
      price,
      warranty
    ) = (
      appliance_attributes.parent,
      appliance_attributes.place,
      appliance_attributes.name,
      appliance_attributes.description,
      appliance_attributes.category,
      appliance_attributes.manufacturer,
      appliance_attributes.serialnum,
      appliance_attributes.model,
      appliance_attributes.price,
      appliance_attributes.warranty
    ) where a.asset_id = appliance_attributes.asset_id;

  with added_departments as (
    select unnest(departments_array) as department_id
    except
    select department_id
      from asset_departments
      where asset_id = appliance_attributes.asset_id
  )
  insert into asset_departments
    select appliance_attributes.asset_id, department_id from added_departments;
  
  with recursive removed_departments as (
    select department_id
      from asset_departments
    where asset_id = appliance_attributes.asset_id
    except
    select unnest(departments_array) as department_id
  )
  delete from asset_departments
    where asset_id = appliance_attributes.asset_id
          and department_id in (select department_id from removed_departments);

  modified_appliance_id = appliance_attributes.asset_id;

end; $$;


create or replace function modify_facility (
  in facility_attributes facilities,
  in departments_array text[],
  out modified_facility_id text
)
language plpgsql
as $$
begin
  update assets as a
    set (
      parent,
      place,
      name,
      description,
      category,
      latitude,
      longitude,
      area
    ) = (
      facility_attributes.parent,
      facility_attributes.place,
      facility_attributes.name,
      facility_attributes.description,
      facility_attributes.category,
      facility_attributes.latitude,
      facility_attributes.longitude,
      facility_attributes.area
    ) where a.asset_id = facility_attributes.asset_id;

  with added_departments as (
    select unnest(departments_array) as department_id
    except
    select department_id
      from asset_departments
      where asset_id = facility_attributes.asset_id
  )
  insert into asset_departments
    select facility_attributes.asset_id, department_id from added_departments;
  
  with recursive removed_departments as (
    select department_id
      from asset_departments
    where asset_id = facility_attributes.asset_id
    except
    select unnest(departments_array) as department_id
  )
  delete from asset_departments
    where asset_id = facility_attributes.asset_id
          and department_id in (select department_id from removed_departments);

  modified_facility_id = facility_attributes.asset_id;

end; $$;

create or replace function modify_order (
  in order_attributes orders,
  in assets_array text[],
  out modified_order_id integer
)
language plpgsql
strict
as $$
begin
  update orders as o
    set (
      status,
      priority,
      category,
      parent,
      team_id,
      progress,
      title,
      description,
      origin_department,
      origin_person,
      contact_name,
      contact_phone,
      contact_email,
      contact_place,
      date_limit,
      date_start
    ) = (
      order_attributes.status,
      order_attributes.priority,
      order_attributes.category,
      order_attributes.parent,
      order_attributes.team_id,
      order_attributes.progress,
      order_attributes.title,
      order_attributes.description,
      order_attributes.origin_department,
      order_attributes.origin_person,
      order_attributes.contact_name,
      order_attributes.contact_phone,
      order_attributes.contact_email,
      order_attributes.contact_place,
      order_attributes.date_limit,
      order_attributes.date_start
    ) where o.order_id = order_attributes.order_id;

  with added_assets as (
    select unnest(assets_array) as asset_id
    except
    select asset_id
      from order_assets
      where order_id = order_attributes.order_id
  )
  insert into order_assets
    select order_attributes.order_id, asset_id from added_assets;
  
  with recursive removed_assets as (
    select asset_id
      from order_assets
    where order_id = order_attributes.order_id
    except
    select unnest(assets_array) as asset_id
  )
  delete from order_assets
    where order_id = order_attributes.order_id
          and asset_id in (select asset_id from removed_assets);

  modified_order_id = order_attributes.order_id;

end; $$;

create or replace function get_asset_history (
  in asset_id text,
  out fullname text,
  out created_at timestamptz,
  out operation text,
  out tablename text,
  out old_row jsonb,
  out new_row jsonb
)
returns setof record
security definer
language sql
stable
as $$
  select p.full_name,
         l.created_at,
         l.operation,
         l.tablename,
         l.old_row,
         l.new_row
    from private.logs as l
    inner join persons as p using (person_id)
  where (l.tablename = 'assets' or l.tablename = 'asset_departments' or l.tablename = 'order_assets')
        and
        (
          l.new_row @> ('{"asset_id": "' || asset_id || '"}')::jsonb
          or
          l.old_row @> ('{"asset_id": "' || asset_id || '"}')::jsonb
        );
$$;

create or replace function get_order_history (
  in order_id integer,
  out fullname text,
  out created_at timestamptz,
  out operation text,
  out tablename text,
  out old_row jsonb,
  out new_row jsonb
)
returns setof record
security definer
language sql
stable
as $$
  select p.full_name,
         l.created_at,
         l.operation,
         l.tablename,
         l.old_row,
         l.new_row
    from private.logs as l
    inner join persons as p using (person_id)
  where (l.tablename = 'orders' or l.tablename = 'order_assets' or l.tablename = 'order_supplies')
        and
        (
          l.new_row @> ('{"order_id": ' || order_id || '}')::jsonb
          or
          l.old_row @> ('{"order_id": ' || order_id || '}')::jsonb
        );
$$;

-- create triggers
create trigger log_changes
  after insert or update or delete on orders
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on order_messages
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on order_assets
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on order_supplies
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on assets
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on asset_departments
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on contracts
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on supplies
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on departments
  for each row execute function create_log();

---------------------------------------------------------------------------------
-- run file with insert commands and comments (this file should have win1252 encoding)
-- \i insertswin1252.sql
-- Content of inserts file:
-- -- set variable auth.data.person_id to allow log of initial rows insertions
-- -- insert rows into tables
-- -- create comments
-- -- alter sequences (currently not necessary, since inserts use default values)

-- this trigger must be created after inserts to avoid error during first asset insert;
-- this trigger must exist in production environment
create trigger check_before_insert
  before insert or update on assets
  for each row execute function check_asset_integrity();
---------------------------------------------------------------------------------

-- create policies
-- \i rls.sql

-- create smart comments
comment on function authenticate is E'@omit execute';
comment on table assets is E'@omit create,update,delete';
comment on table contracts is E'@omit create,update,delete';
comment on table departments is E'@omit create,update,delete';
comment on table persons is E'@omit all,create,update,delete';
comment on table teams is E'@omit create,update,delete';
comment on table team_persons is E'@omit create,update,delete';
comment on table orders is E'@omit create,update,delete';
comment on table order_messages is E'@omit all,create,update,delete';
comment on table order_assets is E'@omit create,update,delete';
comment on table asset_departments is E'@omit create,update,delete';
comment on table specs is E'@omit all,create,update,delete';
comment on table supplies is E'@omit read,all,many,create,update,delete';
comment on table order_supplies is E'@omit all,create,update,delete';
comment on view appliances is E'@omit create,update,delete';
comment on view facilities is E'@omit create,update,delete';
comment on constraint persons_pkey on persons is E'@omit';
comment on constraint persons_email_key on persons is E'@omit';
comment on constraint contracts_pkey on contracts is E'@omit';
comment on constraint specs_pkey on specs is E'@omit';

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- commit transaction
commit;