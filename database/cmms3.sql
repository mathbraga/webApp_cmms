-- connect to other database
\c hzl

-- drop database
drop database if exists cmms3;

-- create new database
create database cmms3 with owner postgres template template0 encoding 'win1252';

-- connect to the new database
\c cmms3

-- create extensions
create extension if not exists pgcrypto;

-- create additional schemas
create schema private;

-- set variable ON_ERROR_STOP
\set ON_ERROR_STOP on

-- begin transaction
begin transaction;

-- create roles (already created for the database cluster, not necessary in new databases)
-- create role unauth;
-- create role auth;

-- alter default privileges
alter default privileges in schema public grant all on tables to unauth;
alter default privileges in schema public grant all on tables to auth;
alter default privileges in schema public grant usage on sequences to unauth;
alter default privileges in schema public grant usage on sequences to auth;
alter default privileges in schema public grant execute on routines to unauth;
alter default privileges in schema public grant execute on routines to auth;

-- create custom types
create type asset_category_type as enum ('F', 'A');
create type person_category_type AS ENUM ('E', 'T');
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

-- create tables
create table assets (
  asset_id text not null primary key,
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
  contract_id integer not null primary key generated always as identity,
  parent integer references contracts (contract_id),
  contract_num integer,
  sign_date date not null,
  date_start date not null,
  date_end date,
  company text not null,
  description text not null,
  url text not null
);

create table departments (
  department_id text not null primary key,
  parent text not null references departments (department_id),
  full_name text not null,
  is_active boolean not null
);

create table persons (
  person_id integer primary key generated always as identity,
  email text not null unique check (email ~* '^.+@.+\..+$'),
  forename text not null,
  surname text not null,
  phone text not null,
  cellphone text,
  department_id text references departments (department_id),
  contract_id text references contracts (contract_id),
  category person_category_type
);

create table private.accounts (
  person_id integer not null references persons (person_id),
  password_hash text not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  is_active boolean not null default true
);

create table orders (
  order_id integer primary key generated always as identity,
  status order_status_type not null,
  priority order_priority_type not null,
  category order_category_type not null,
  parent integer references orders (order_id),
  contract_id text references contracts (contract_id),
  completed integer check (completed >= 0 and completed <= 100),
  request_text text not null,
  request_department text not null references departments (department_id),
  request_person text not null,
  request_contact_name text not null,
  request_contact_phone text not null,
  request_contact_email text not null,
  request_title text not null,
  request_local text,
  date_limit timestamptz,
  date_start timestamptz,
  date_end timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table order_messages (
  order_id integer not null references orders (order_id),
  person_id integer not null references persons (person_id),
  message text not null,
  created_at timestamptz not null,
  updated_at timestamptz not null
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
  spec_id integer not null primary key generated always as identity,
  spec_name text,
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
  contract_id integer not null references contracts (contract_id),
  supply_id text not null,
  spec_id integer references specs (spec_id),
  description text,
  qty_initial real not null,
  is_qty_real boolean not null,
  unit text not null,
  primary key (contract_id, supply_id)
);

create table order_supplies (
  order_id integer not null references orders (order_id),
  contract_id integer not null,
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
      select s.contract_id,
             s.supply_id,
             s.qty_available as qty_initial,
             coalesce(sum(blocked), 0) as blocked,
             coalesce(sum(consumed), 0) as consumed
        from supplies as s
        inner join unfinished using (contract_id, supply_id)
        full outer join finished using (contract_id, supply_id)
      group by s.contract_id, s.supply_id
    )
    select *,
          qty_initial - blocked - consumed as available
      from both_cases;

-- create functions
create or replace function register_user (
  person_attributes persons,
  input_password text
) returns persons
language plpgsql
strict
security definer
as $$
declare
  new_user persons;
begin

  insert into persons (
    person_id,
    email,
    forename,
    surname,
    phone,
    cellphone,
    department_id,
    contract_id,
    category
  ) values (
    default,
    person_attributes.email,
    person_attributes.forename,
    person_attributes.surname,
    person_attributes.phone,
    person_attributes.cellphone,
    person_attributes.department_id,
    person_attributes.contract_id,
    person_attributes.category
  ) returning * into new_user;
  
  insert into private.accounts (
    person_id,
    password_hash,
    created_at,
    updated_at,
    is_active
  ) values (
    new_user.person_id,
    crypt(input_password, gen_salt('bf', 10)),
    now(),
    now(),
    true
  );

  return new_user;

end; $$;

create or replace function authenticate (
  input_email    text,
  input_password text
) returns integer
language sql
stable
strict
security definer
as $$
  select p.person_id
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
  out new_appliance_id text
)
language plpgsql
as $$
begin
  insert into appliances values (appliance_attributes.*)
    returning asset_id into new_appliance_id;
  if departments_array is not null then
    insert into asset_departments select new_appliance_id, unnest(departments_array);
  end if;
end; $$;


create or replace function insert_facility (
  in facility_attributes facilities,
  in departments_array text[],
  out new_facility_id text
)
language plpgsql
as $$
begin
  insert into facilities values (facility_attributes.*)
    returning asset_id into new_facility_id;
  if departments_array is not null then
    insert into asset_departments select new_facility_id, unnest(departments_array);
  end if;
end; $$;

create or replace function insert_order (
  in order_attributes orders,
  in assets_array text[],
  out new_order_id integer
)
language plpgsql
strict -- this is to make all inputs mandatory (there must be assigned assets in order)
as $$
begin
  insert into orders (
    order_id,
    status,
    priority,
    category,
    parent,
    completed,
    request_text,
    request_department,
    request_person,
    request_contact_name,
    request_contact_phone,
    request_contact_email,
    request_title,
    request_local,
    date_limit,
    date_start,
    created_at,
    contract_id
  ) values (
    default,
    order_attributes.status,
    order_attributes.priority,
    order_attributes.category,
    order_attributes.parent,
    order_attributes.completed,
    order_attributes.request_text,
    order_attributes.request_department,
    order_attributes.request_person,
    order_attributes.request_contact_name,
    order_attributes.request_contact_phone,
    order_attributes.request_contact_email,
    order_attributes.request_title,
    order_attributes.request_local,
    order_attributes.date_limit,
    order_attributes.date_start,
    default,
    order_attributes.contract_id
  ) returning order_id into new_order_id;

  insert into order_assets select new_order_id, unnest(assets_array);

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

  delete from asset_departments where asset_id = appliance_attributes.asset_id;

  if departments_array is not null then
    insert into asset_departments select appliance_attributes.asset_id, unnest(departments_array);
  end if;

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

  delete from asset_departments where asset_id = facility_attributes.asset_id;

  if departments_array is not null then
    insert into asset_departments select facility_attributes.asset_id, unnest(departments_array);
  end if;

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
      contract_id,
      completed,
      request_text,
      request_department,
      request_person,
      request_contact_name,
      request_contact_phone,
      request_contact_email,
      request_title,
      request_local,
      date_limit,
      date_start,
      updated_at
    ) = (
      order_attributes.status,
      order_attributes.priority,
      order_attributes.category,
      order_attributes.parent,
      order_attributes.contract_id,
      order_attributes.completed,
      order_attributes.request_text,
      order_attributes.request_department,
      order_attributes.request_person,
      order_attributes.request_contact_name,
      order_attributes.request_contact_phone,
      order_attributes.request_contact_email,
      order_attributes.request_title,
      order_attributes.request_local,
      order_attributes.date_limit,
      order_attributes.date_start,
      now()
    ) where o.order_id = order_attributes.order_id;

  delete from order_assets as oa where oa.order_id = order_attributes.order_id;

  if assets_array is not null then
    insert into order_assets select order_attributes.order_id, unnest(assets_array);
  end if;

  modified_order_id = order_attributes.order_id;

end; $$;

-- create comments (included in inserts.sql file)

-- insert rows into tables (included in inserts.sql file)

-- alter sequences (included in inserts.sql file)

-- create triggers
create trigger check_before_insert
  before insert or update on assets
  for each row execute function check_asset_integrity();

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
  after insert or update or delete on assets
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on asset_departments
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on contracts
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on departments
  for each row execute function create_log();

-- create policies
alter table persons enable row level security;
-- create policy unauth_policy on persons for select to unauth
--   using (true);
create policy auth_policy on persons for all to auth
  using (current_setting('auth.data.person_id')::integer = person_id)
  with check (current_setting('auth.data.person_id')::integer = person_id);

alter table private.accounts enable row level security;
create policy auth_policy on private.accounts for all to auth
  using (current_setting('auth.data.person_id')::integer = person_id)
  with check (current_setting('auth.data.person_id')::integer = person_id);

alter table order_messages enable row level security;
create policy unauth_policy on order_messages for select to unauth
  using (true);
create policy auth_policy on order_messages for all to auth
  using (current_setting('auth.data.person_id')::integer = person_id)
  with check (current_setting('auth.data.person_id')::integer = person_id);

-- create smart comments
comment on function authenticate is E'@omit execute';
comment on table assets is E'@omit create,update,delete';
comment on table contracts is E'@omit all,create,update,delete';
comment on table departments is E'@omit create,update,delete';
comment on table persons is E'@omit all,create,update,delete';
comment on table orders is E'@omit create,update,delete';
comment on table asset_departments is E'@omit create,update,delete';
comment on table order_assets is E'@omit create,update,delete';
comment on table order_messages is E'@omit all,create,update,delete';
comment on table specs is E'@omit all,create,update,delete';
comment on table supplies is E'@omit read,all,many,create,update,delete';
comment on table order_supplies is E'@omit all,create,update,delete';
comment on view appliances is E'@omit create,update,delete';
comment on view facilities is E'@omit create,update,delete';
comment on constraint persons_pkey on persons is E'@omit';
comment on constraint persons_email_key on persons is E'@omit';
comment on constraint contracts_pkey on contracts is E'@omit';
comment on constraint specs_pkey on specs is E'@omit';

-- commit transaction
commit;