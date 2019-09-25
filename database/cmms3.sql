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
  contract text references contracts (contract_id),
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
  qty_available real not null,
  qty_blocked real not null,
  qty_consumed real not null,
  qty_type text not null, -- transformar em enum (integer or real)
  unit text,
  primary key (contract_id, supply_id)
);

create table order_supplies (
  order_id integer not null references orders (order_id),
  contract_id integer not null,
  supply_id text not null,
  qty real not null,
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
  appliance_attributes appliances,
  departments_array  text[]
)
returns text
language plpgsql
as $$
declare
  new_appliance_id text;
begin

insert into appliances values (appliance_attributes.*)
  returning asset_id into new_appliance_id;

if departments_array is not null then
  insert into asset_departments select new_appliance_id, unnest(departments_array);
end if;

return new_appliance_id;

end; $$;


create or replace function insert_facility (
  facility_attributes facilities,
  departments_array text[]
)
returns text
language plpgsql
as $$
declare 
  new_facility_id text;
begin

insert into facilities values (facility_attributes.*)
  returning asset_id into new_facility_id;

if departments_array is not null then
  insert into asset_departments select new_facility_id, unnest(departments_array);
end if;

return new_facility_id;

end; $$;



create or replace function insert_order (
  order_attributes orders,
  assets_array text[]
)
returns integer
language plpgsql
strict -- this is to enforce no null inputs (must have assigned assets in order)
as $$
declare 
  new_order_id  integer;
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
  contract
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
  order_attributes.contract
) returning order_id into new_order_id;

insert into order_assets select new_order_id, unnest(assets_array);

return new_order_id;

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
  appliance_attributes appliances,
  departments_array text[]
)
returns text
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

  return appliance_attributes.asset_id;

end; $$;

create or replace function modify_facility (
  facility_attributes facilities,
  departments_array text[]
)
returns text
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

  return facility_attributes.asset_id;

end; $$;

create or replace function modify_order (
  order_attributes orders,
  assets_array text[]
)
returns integer
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
      order_attributes.contract,
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

  return order_attributes.order_id;

end; $$;

-- create comments
-- comment on type order_status_type is E'
-- Significados dos poss�veis valores do enum order_status_type:\n
-- CAN: Cancelada;\n 
-- NEG: Negada;\n
-- PEN: Pendente;\n
-- SUS: Suspensa;\n
-- FIL: Fila de espera;\n
-- EXE: Execu��o;\n
-- CON: Conclu�da.\n
-- ';

-- comment on type order_category_type is E'
-- Significados dos poss�veis valores do enum order_category_type:\n
-- ARC: Ar-condicionado;\n
-- ELE: Instala��es el�tricas;\n
-- ELV: Elevadores;\n
-- EST: Avalia��o estrutural;\n
-- EXA: Exaustores;\n
-- FOR: Reparo em forro;\n
-- GRL: Geral;\n
-- HID: Instala��es hidrossanit�rias;\n
-- INF: Infiltra��o;\n
-- MAR: Marcenaria;\n
-- PIS: Reparo em piso;\n
-- REV: Revestimento;\n
-- SER: Serralheria;\n
-- VED: Veda��o espacial;\n
-- VID: Vidra�aria / Esquadria.\n
-- ';

-- comment on type order_priority_type is E'
-- Significados dos poss�veis valores do enum order_priority_type:\n
-- BAI: Baixa;\n
-- NOR: Normal;\n
-- ALT: Alta;\n
-- URG: Urgente.\n
-- ';

-- insert rows into tables
insert into assets values ('CASF-000-000', 'CASF-000-000', 'CASF-000-000', 'Complexo Arquitet�nico - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-000-000', 'CASF-000-000', 'CASF-000-000', 'Edif�cio Principal - Todos', 'Descri��o do ativo', 'F', -15.79925, -47.864063, 14942.27, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-SS1-000', 'EDPR-000-000', 'EDPR-000-000', 'Edif�cio Principal - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-SS1-051', 'EDPR-SS1-000', 'EDPR-SS1-000', 'Edif�cio Principal - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-SS1-052', 'EDPR-SS1-000', 'EDPR-SS1-000', 'Edif�cio Principal - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-SS1-062', 'EDPR-SS1-000', 'EDPR-SS1-000', 'Edif�cio Principal - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-SS1-063', 'EDPR-SS1-000', 'EDPR-SS1-000', 'Edif�cio Principal - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-000', 'EDPR-000-000', 'EDPR-000-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-002', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-031', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-032', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-033', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-034', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-035', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-036', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-037', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-045', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-047', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-051', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-052', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-054', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-055', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-056', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-057', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-061', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-062', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-063', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-064', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-065', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-070', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-071', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-072', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-073', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-074', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-075', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-083', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-085', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-087', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-088', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-091', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-093', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-095', 'EDPR-TER-000', 'EDPR-TER-000', 'Edif�cio Principal - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-000', 'EDPR-000-000', 'EDPR-000-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-001', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-002', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-003', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-004', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-005', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-006', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-007', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-011', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-012', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-014', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-015', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-017', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-021', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-023', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-024', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-025', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-026', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-027', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-028', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-029', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-040', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-050', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edif�cio Principal - Ala Dinarte Mariz', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-000', 'EDPR-000-000', 'EDPR-000-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-001', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-006', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-007', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-008', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-009', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-010', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-011', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-012', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-021', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-022', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-023', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-024', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-025', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-026', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-027', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-028', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-029', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-031', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-032', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-033', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-034', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-035', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-036', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-041', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-042', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-043', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-044', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-045', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-046', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-047', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-048', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-049', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-050', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-052', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-054', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-056', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-057', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-058', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-059', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-065', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-066', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-067', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-068', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-069', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-072', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-076', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-078', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-082', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-084', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-086', 'EDPR-P01-000', 'EDPR-P01-000', 'Edif�cio Principal - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-000', 'EDPR-000-000', 'EDPR-000-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-002', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-003', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-004', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-005', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-013', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-014', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-015', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-023', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-024', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-025', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-033', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-034', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-035', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edif�cio Principal - Ala Antonio Carlos Magalh�es', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-000', 'EDPR-000-000', 'EDPR-000-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-050', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-051', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-052', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-054', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-055', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-056', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-057', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-058', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-059', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-065', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-067', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-068', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-069', 'EDPR-P02-000', 'EDPR-P02-000', 'Edif�cio Principal - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-000', 'EDPR-000-000', 'EDPR-000-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-001', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-002', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-004', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-011', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-012', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-021', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-022', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-023', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-024', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-031', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-032', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-041', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-042', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-044', 'EDPR-COB-000', 'EDPR-COB-000', 'Edif�cio Principal - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-000-000', 'CASF-000-000', 'CASF-000-000', 'Anexo 1 - Todos', 'Descri��o do ativo', 'F', -15.799637, -47.863349, 14891.06, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS2-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS2-015', 'AX01-SS2-000', 'AX01-SS2-000', 'Anexo 1 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS2-016', 'AX01-SS2-000', 'AX01-SS2-000', 'Anexo 1 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS2-017', 'AX01-SS2-000', 'AX01-SS2-000', 'Anexo 1 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-002', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-003', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-004', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-005', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-006', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-007', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-008', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-009', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-010', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-012', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-013', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-014', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-015', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-016', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-017', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-018', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-019', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-030', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-045', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-062', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-063', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-064', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-065', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-067', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-002', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-003', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-004', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-005', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-006', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-007', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-008', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-009', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-010', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-012', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-013', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-014', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-015', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-016', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-017', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-018', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-019', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-020', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-030', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-036', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-038', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-042', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-045', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-052', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-055', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-062', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-065', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-067', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-072', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-082', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-088', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-002', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-003', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-004', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-005', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-006', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-007', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-008', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-009', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-010', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-012', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-013', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-014', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-015', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-016', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-017', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-018', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-019', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-020', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-030', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-002', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-003', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-004', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-005', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-006', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-007', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-008', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-009', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-010', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-012', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-013', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-014', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-015', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-016', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-017', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-018', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-019', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-020', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-030', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-002', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-003', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-004', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-005', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-006', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-007', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-008', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-009', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-010', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-012', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-013', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-014', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-015', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-016', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-017', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-018', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-019', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-020', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-030', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-002', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-003', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-004', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-005', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-006', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-007', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-008', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-009', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-010', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-012', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-013', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-014', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-015', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-016', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-017', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-018', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-019', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-020', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-030', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-002', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-003', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-004', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-005', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-006', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-007', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-008', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-009', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-010', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-012', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-013', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-014', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-015', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-016', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-017', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-018', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-019', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-020', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-030', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-002', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-003', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-004', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-005', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-006', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-007', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-008', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-009', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-010', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-012', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-013', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-014', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-015', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-016', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-017', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-018', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-019', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-020', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-030', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-002', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-003', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-004', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-005', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-006', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-007', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-008', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-009', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-010', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-012', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-013', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-014', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-015', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-016', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-017', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-018', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-019', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-020', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-030', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-002', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-003', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-004', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-005', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-006', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-007', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-008', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-009', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-010', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-012', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-013', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-014', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-015', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-016', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-017', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-018', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-019', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-020', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-030', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-002', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-003', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-004', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-005', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-006', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-007', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-008', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-009', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-010', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-012', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-013', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-014', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-015', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-016', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-017', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-018', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-019', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-020', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-030', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-002', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-003', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-004', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-005', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-006', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-007', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-008', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-009', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-010', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-012', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-013', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-014', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-015', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-016', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-017', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-018', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-019', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-020', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-030', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-002', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-003', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-004', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-005', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-006', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-007', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-008', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-009', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-010', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-012', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-013', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-014', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-015', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-016', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-017', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-018', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-019', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-020', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-030', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-002', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-003', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-004', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-005', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-006', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-007', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-008', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-009', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-010', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-012', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-013', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-014', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-015', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-016', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-017', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-018', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-019', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-020', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-030', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-002', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-003', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-004', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-005', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-006', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-007', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-008', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-009', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-010', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-012', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-013', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-014', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-015', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-016', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-017', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-018', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-019', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-020', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-030', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-036', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-002', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-003', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-004', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-005', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-006', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-007', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-008', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-009', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-010', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-012', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-013', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-014', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-015', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-016', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-017', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-018', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-019', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-020', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-030', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-036', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-002', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-003', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-004', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-005', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-006', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-007', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-008', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-009', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-010', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-012', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-013', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-014', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-015', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-016', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-017', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-018', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-019', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-020', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-030', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-036', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-002', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-003', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-004', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-005', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-006', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-007', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-008', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-009', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-010', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-012', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-013', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-014', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-015', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-016', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-017', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-018', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-019', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-020', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-030', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-002', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-003', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-004', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-005', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-006', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-007', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-008', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-009', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-010', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-012', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-013', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-014', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-015', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-016', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-017', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-018', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-019', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-020', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-030', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-002', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-003', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-004', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-005', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-006', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-007', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-008', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-009', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-010', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-012', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-013', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-014', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-015', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-016', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-017', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-018', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-019', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-020', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-030', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-002', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-003', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-004', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-005', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-006', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-007', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-008', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-009', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-010', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-012', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-013', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-014', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-015', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-016', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-017', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-018', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-019', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-020', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-030', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-002', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-003', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-004', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-005', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-006', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-007', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-008', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-009', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-010', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-012', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-013', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-014', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-015', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-016', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-017', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-018', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-019', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-020', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-030', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-002', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-003', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-004', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-005', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-006', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-007', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-008', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-009', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-010', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-012', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-013', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-014', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-015', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-016', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-017', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-018', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-019', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-020', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-030', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-002', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-003', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-004', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-005', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-006', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-007', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-008', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-009', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-010', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-012', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-013', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-014', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-015', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-016', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-017', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-018', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-019', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-020', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-030', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-002', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-003', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-004', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-005', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-006', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-007', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-008', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-009', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-010', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-012', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-013', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-014', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-015', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-016', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-017', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-018', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-019', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-020', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-030', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-002', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-003', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-004', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-005', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-006', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-007', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-008', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-009', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-010', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-012', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-013', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-014', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-015', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-016', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-017', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-018', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-019', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-020', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-030', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-002', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-003', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-004', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-005', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-006', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-007', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-008', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-009', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-010', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-012', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-013', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-014', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-015', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-016', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-017', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-018', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-019', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-020', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-030', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-002', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-003', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-004', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-005', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-006', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-007', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-008', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-009', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-010', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-012', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-013', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-014', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-015', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-016', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-017', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-018', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-019', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-020', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-030', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-002', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-003', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-004', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-005', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-006', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-007', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-008', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-009', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-010', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-013', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-014', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-015', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-016', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-017', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-018', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-019', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-020', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-002', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-003', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-004', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-005', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-006', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-007', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-008', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-009', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-010', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-014', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-015', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-016', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-017', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-018', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-019', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-020', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-036', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-000-000', 'CASF-000-000', 'CASF-000-000', 'Anexo 2 - Todos', 'Descri��o do ativo', 'F', -15.798156, -47.864237, 43788.02, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-051', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-052', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-060', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-076', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-085', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-086', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-087', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-001', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-002', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-003', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-004', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-005', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-006', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-007', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-008', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-009', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-011', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-012', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-013', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-014', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-015', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-018', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-019', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-021', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-022', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-023', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-024', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-025', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-026', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-027', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-028', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-038', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-039', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-041', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-042', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-043', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-044', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-045', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-046', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-047', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-048', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-049', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-050', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-051', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-052', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-053', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-058', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-059', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-060', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-064', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-065', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-066', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-067', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-068', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-069', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-071', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-072', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-073', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-074', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-075', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-076', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-077', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-078', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-079', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-081', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-082', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-083', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-084', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-086', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-087', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-088', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-089', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-091', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-092', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-093', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-094', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-095', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-096', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-097', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-098', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-099', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-011', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-012', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-014', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-016', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-018', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-020', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-022', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-028', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-030', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-031', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-032', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-034', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-036', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-038', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-040', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-041', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-042', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-044', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-046', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-048', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-054', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-058', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-060', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-062', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-064', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-065', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-066', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-068', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-076', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-078', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-079', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-081', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-082', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-083', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-084', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-085', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-086', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-087', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-088', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-089', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-091', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-093', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-095', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-096', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-098', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-099', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-001', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-002', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-003', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-004', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-005', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-006', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-007', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-008', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-009', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-010', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-011', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-012', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-013', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-031', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-032', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-033', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-034', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-035', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-036', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-037', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-038', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-039', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-040', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-041', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-042', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-043', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-061', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-062', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-063', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-064', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-065', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-066', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-067', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-068', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-070', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-071', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-072', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-094', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-097', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-098', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-099', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-001', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-002', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-003', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-004', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-005', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-006', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-007', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-008', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-009', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-010', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-011', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-012', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-013', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-014', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-015', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-031', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-032', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-033', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-034', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-035', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-036', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-037', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-038', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-039', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-040', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-041', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-042', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-043', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-044', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-045', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-061', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-062', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-063', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-064', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-065', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-066', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-067', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-068', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-069', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-070', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-071', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-072', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-073', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-074', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-075', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-084', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-087', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-088', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-089', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-097', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-099', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto M�ller', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-002', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-004', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-006', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-008', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-010', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-032', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-034', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-036', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-038', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-040', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-064', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-066', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-068', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-070', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-088', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-090', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-098', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-099', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-003', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-005', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-007', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-009', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-011', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-013', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-015', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-017', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-019', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-021', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-033', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-035', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-037', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-039', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-041', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-043', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-045', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-047', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-049', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-051', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-063', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-065', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-067', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-069', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-071', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-073', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-075', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-080', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-081', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-090', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-091', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-092', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-097', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-098', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-099', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-007', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-008', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-009', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-020', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-030', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-040', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-060', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-066', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-070', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-071', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-072', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-073', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-074', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-075', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-076', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-001', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-002', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-003', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-004', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-021', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-022', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-023', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-024', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-041', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-042', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-043', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-044', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-061', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-063', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-087', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-088', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-089', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-030', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-049', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-050', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-051', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-052', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-053', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-054', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-055', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-056', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-057', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-058', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-059', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-060', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-069', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-070', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-071', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-072', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-073', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-074', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-075', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-076', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-077', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-078', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-079', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-080', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-090', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-094', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-098', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-001', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-002', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-003', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-004', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-005', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-006', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-007', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-008', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-009', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-010', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-011', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-012', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-013', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-014', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-015', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-016', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-017', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-018', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-019', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-020', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-021', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-022', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-023', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-024', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-025', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-031', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-032', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-033', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-034', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-035', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-036', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-037', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-038', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-039', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-040', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-041', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-042', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-043', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-044', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-045', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-046', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-047', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-048', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-049', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-050', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-051', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-052', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-053', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-054', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-055', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-061', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-062', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-063', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-064', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-065', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-066', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-067', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-068', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-069', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-070', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-071', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-072', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-073', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-074', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-075', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-076', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-077', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-078', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-079', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-080', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-081', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-082', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-085', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-088', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-089', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-090', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-091', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-092', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-093', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-094', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-095', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-096', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-097', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-098', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teot�nio Vilela', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-004', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-006', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-008', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-010', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-032', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-036', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-040', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-066', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-070', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-088', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-090', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-001', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-003', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-005', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-007', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-009', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-011', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-013', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-015', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-017', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-019', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-021', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-031', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-032', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-035', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-041', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-047', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-051', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-065', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-071', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-077', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-081', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-088', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-090', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-091', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-092', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-070', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-076', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-080', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-086', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-090', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-096', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-001', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-002', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-003', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-004', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-012', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-013', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-021', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-022', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-032', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-033', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-042', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-044', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-050', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-051', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-052', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-053', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-054', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-055', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-056', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-057', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-058', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-059', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-060', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-061', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-062', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-063', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideran�as', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-001', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-002', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-003', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-004', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-005', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-006', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-007', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-008', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-009', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-010', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-011', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-012', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-017', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-021', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-022', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-023', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-024', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-025', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-026', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-027', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-028', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-029', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-030', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-031', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-032', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-037', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-041', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-042', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-043', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-044', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-045', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-046', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-047', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-048', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-049', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-050', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-051', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-052', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-061', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-062', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-063', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-064', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-065', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-066', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-067', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-068', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-069', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-070', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-071', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-072', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-073', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-074', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-075', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-077', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-081', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-083', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-085', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-087', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-089', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-091', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-093', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-095', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-097', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-099', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 01 - Todos', 'Descri��o do ativo', 'F', -15.797074, -47.86433, 5896.55, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala A', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-001', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-002', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-003', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-004', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-005', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-006', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-007', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-008', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-009', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-010', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-011', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-012', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-013', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-014', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-015', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-016', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-017', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-018', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-019', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-020', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-021', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala C', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-022', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-023', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-024', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-025', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-026', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-027', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-028', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-031', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-032', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala D', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-033', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-035', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-036', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-037', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-038', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-039', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-040', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-041', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-042', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-043', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-044', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-045', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-046', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-047', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-051', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-052', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-055', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-056', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-057', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-058', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-059', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-060', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-061', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALF-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala F', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALF-071', 'BL01-ALF-000', 'BL01-ALF-000', 'Bloco 01 - Ala F', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALF-072', 'BL01-ALF-000', 'BL01-ALF-000', 'Bloco 01 - Ala F', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALF-073', 'BL01-ALF-000', 'BL01-ALF-000', 'Bloco 01 - Ala F', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALF-074', 'BL01-ALF-000', 'BL01-ALF-000', 'Bloco 01 - Ala F', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALG-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala G', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALG-081', 'BL01-ALG-000', 'BL01-ALG-000', 'Bloco 01 - Ala G', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALG-082', 'BL01-ALG-000', 'BL01-ALG-000', 'Bloco 01 - Ala G', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALG-083', 'BL01-ALG-000', 'BL01-ALG-000', 'Bloco 01 - Ala G', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALG-084', 'BL01-ALG-000', 'BL01-ALG-000', 'Bloco 01 - Ala G', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-001', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-002', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-011', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-012', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-013', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-014', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-015', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-016', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-017', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-018', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-019', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-020', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-021', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-022', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-023', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-031', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-032', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-041', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-042', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-043', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-044', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-045', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-046', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-047', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-048', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-049', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-050', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-051', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-052', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-053', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-061', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-062', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-063', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 02 - Todos', 'Descri��o do ativo', 'F', -15.796191, -47.864551, 4448.31, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-000', 'BL02-000-000', 'BL02-000-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-001', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-002', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-003', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-004', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-005', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-006', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-007', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-008', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-011', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-012', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-013', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-014', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-015', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-016', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-017', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-018', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-024', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-027', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-000', 'BL02-000-000', 'BL02-000-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-001', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-002', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-003', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-004', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-005', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-006', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-007', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-012', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-013', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-014', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-015', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-016', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-017', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-033', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-034', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-035', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-036', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-037', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-041', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-042', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-043', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-044', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-051', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-052', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-053', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-054', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-000', 'BL02-000-000', 'BL02-000-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-001', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-002', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-003', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-004', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-005', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-006', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-007', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-011', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-012', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-013', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-014', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-015', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-016', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-017', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-000', 'BL02-000-000', 'BL02-000-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-001', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-002', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-003', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-004', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-005', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-006', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-007', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-011', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-012', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-013', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-014', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-015', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-016', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-017', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-000', 'BL02-000-000', 'BL02-000-000', 'Bloco 02 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-002', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-004', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-006', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-012', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-014', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-016', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-017', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-033', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-034', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-036', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 03 - Todos', 'Descri��o do ativo', 'F', 0, 0, 160.73, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-000', 'BL03-000-000', 'BL03-000-000', 'Bloco 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-001', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-002', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-003', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-004', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-011', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-014', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-COB-000', 'BL03-000-000', 'BL03-000-000', 'Bloco 03 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-COB-001', 'BL03-COB-000', 'BL03-COB-000', 'Bloco 03 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-COB-002', 'BL03-COB-000', 'BL03-COB-000', 'Bloco 03 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-COB-004', 'BL03-COB-000', 'BL03-COB-000', 'Bloco 03 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-COB-012', 'BL03-COB-000', 'BL03-COB-000', 'Bloco 03 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 04 - Todos', 'Descri��o do ativo', 'F', 0, 0, 1465.52, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-000', 'BL04-000-000', 'BL04-000-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-008', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-009', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-016', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-018', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-022', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-023', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-024', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-025', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-026', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-027', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-028', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-036', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-000', 'BL04-000-000', 'BL04-000-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-001', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-002', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-006', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-012', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-013', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-016', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-021', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-022', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-023', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-024', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-025', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-026', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-027', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-030', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P02-000', 'BL04-000-000', 'BL04-000-000', 'Bloco 04 - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-000', 'BL04-000-000', 'BL04-000-000', 'Bloco 04 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-012', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-014', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-016', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-018', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-022', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-024', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-026', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-028', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 05 - Todos', 'Descri��o do ativo', 'F', 0, 0, 777.29, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-000', 'BL05-000-000', 'BL05-000-000', 'Bloco 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-001', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-002', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-003', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-004', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-005', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-021', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-022', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-023', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-024', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-025', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-P01-000', 'BL05-000-000', 'BL05-000-000', 'Bloco 05 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-P01-003', 'BL05-P01-000', 'BL05-P01-000', 'Bloco 05 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-P01-004', 'BL05-P01-000', 'BL05-P01-000', 'Bloco 05 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-P01-005', 'BL05-P01-000', 'BL05-P01-000', 'Bloco 05 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-COB-000', 'BL05-000-000', 'BL05-000-000', 'Bloco 05 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-COB-001', 'BL05-COB-000', 'BL05-COB-000', 'Bloco 05 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-COB-002', 'BL05-COB-000', 'BL05-COB-000', 'Bloco 05 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-COB-003', 'BL05-COB-000', 'BL05-COB-000', 'Bloco 05 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-COB-004', 'BL05-COB-000', 'BL05-COB-000', 'Bloco 05 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 06 - Todos', 'Descri��o do ativo', 'F', 0, 0, 3357.96, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-000', 'BL06-000-000', 'BL06-000-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-002', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-003', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-004', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-005', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-006', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-007', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-008', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-009', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-010', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-011', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-012', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-000', 'BL06-000-000', 'BL06-000-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-001', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-002', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-003', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-004', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-005', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-006', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-007', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-008', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-009', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-010', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-011', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-012', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-013', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-014', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-015', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-024', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-025', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-026', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-027', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-028', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-029', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-030', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-033', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-037', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-040', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-000', 'BL06-000-000', 'BL06-000-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-001', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-002', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-003', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-004', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-011', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-012', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-013', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-014', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-021', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-022', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-023', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-024', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-COB-000', 'BL06-000-000', 'BL06-000-000', 'Bloco 06 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 07 - Todos', 'Descri��o do ativo', 'F', 0, 0, 3114.8, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-000', 'BL07-000-000', 'BL07-000-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-003', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-004', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-005', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-006', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-007', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-008', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-009', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-010', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-011', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-012', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-013', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-014', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-015', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-016', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-017', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-018', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-027', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-028', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-030', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-032', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-034', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-038', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-000', 'BL07-000-000', 'BL07-000-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-001', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-002', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-003', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-004', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-005', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-006', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-007', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-008', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-009', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-010', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-011', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-012', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-013', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-014', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-015', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-016', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-017', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-018', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-27', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-034', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-035', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-000', 'BL07-000-000', 'BL07-000-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-001', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-002', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-003', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-004', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-005', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-006', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-007', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-008', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-009', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-010', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-011', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-012', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-013', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-014', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-015', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-016', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-017', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-018', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 08 - Todos', 'Descri��o do ativo', 'F', 0, 0, 3357.96, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-000', 'BL08-000-000', 'BL08-000-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-001', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-002', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-003', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-004', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-005', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-006', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-007', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-008', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-009', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-010', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-011', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-012', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-013', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-014', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-015', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-020', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-021', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-022', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-023', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-024', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-033', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-035', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-000', 'BL08-000-000', 'BL08-000-000', 'Bloco 08 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-009', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-010', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-011', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-012', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-013', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-014', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-021', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-022', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-034', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-P01-000', 'BL08-000-000', 'BL08-000-000', 'Bloco 08 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-000', 'BL08-000-000', 'BL08-000-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-001', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-002', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-003', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-004', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-011', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-012', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-013', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-014', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-021', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-022', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-023', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-024', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 09 - Todos', 'Descri��o do ativo', 'F', 0, 0, 2935.87, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-000', 'BL09-000-000', 'BL09-000-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-001', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-002', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-003', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-004', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-005', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-006', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-007', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-008', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-009', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-010', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-011', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-012', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-013', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-014', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-020', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-021', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-022', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-031', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-033', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-035', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-037', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-039', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-041', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-043', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-047', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-055', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-057', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-059', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-060', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-061', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-063', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-065', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-067', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-069', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-071', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-073', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-075', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-077', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-079', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-081', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-MEZ-000', 'BL09-000-000', 'BL09-000-000', 'Bloco 09 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-MEZ-013', 'BL09-MEZ-000', 'BL09-MEZ-000', 'Bloco 09 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-MEZ-014', 'BL09-MEZ-000', 'BL09-MEZ-000', 'Bloco 09 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-MEZ-021', 'BL09-MEZ-000', 'BL09-MEZ-000', 'Bloco 09 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-MEZ-022', 'BL09-MEZ-000', 'BL09-MEZ-000', 'Bloco 09 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-P01-000', 'BL09-000-000', 'BL09-000-000', 'Bloco 09 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-000', 'BL09-000-000', 'BL09-000-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-001', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-002', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-003', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-004', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-005', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-011', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-012', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-013', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-014', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-015', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-021', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-022', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-023', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-024', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-025', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 10 - Todos', 'Descri��o do ativo', 'F', 0, 0, 3981.59, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-000', 'BL10-000-000', 'BL10-000-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-007', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-008', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-009', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-010', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-011', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-012', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-013', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-014', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-015', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-016', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-017', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-018', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-019', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-020', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-021', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-022', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-023', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-024', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-025', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-026', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-027', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-037', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-038', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-039', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-040', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-041', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-042', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-043', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-044', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-045', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-046', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-047', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-048', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-049', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-050', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-051', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-052', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-053', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-054', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-055', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-056', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-060', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-061', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-062', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-077', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-078', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-080', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-081', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-087', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-088', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-089', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-090', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-091', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-092', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-093', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-094', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-095', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-096', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-097', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-098', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-099', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-000', 'BL10-000-000', 'BL10-000-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-001', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-002', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-003', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-004', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-005', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-006', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-007', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-008', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-009', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-010', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-011', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-012', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-013', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-014', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-015', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-016', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-017', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-018', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-019', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-020', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-021', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-022', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-023', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-024', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-025', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-026', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-027', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-031', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-032', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-033', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-034', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-035', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-036', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-037', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-038', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-039', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-040', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-041', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-042', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-043', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-044', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-045', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-046', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-047', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-048', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-049', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-050', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-051', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-052', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-053', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-054', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-055', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-056', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-064', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-065', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-072', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-073', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-074', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-076', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-077', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-079', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-083', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-085', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-000', 'BL10-000-000', 'BL10-000-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-001', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-002', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-003', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-004', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-005', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-006', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-007', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-008', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-009', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-010', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-011', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-012', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-013', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-014', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-015', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-016', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-017', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-018', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-019', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-020', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-021', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-022', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-023', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-024', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-025', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-026', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-027', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-090', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-093', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-095', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 11 - Todos', 'Descri��o do ativo', 'F', 0, 0, 991.03, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-000', 'BL11-000-000', 'BL11-000-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-001', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-002', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-003', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-004', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-005', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-006', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-007', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-008', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-009', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-021', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-022', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-023', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-024', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-025', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-026', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-027', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-028', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-029', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-036', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-000', 'BL11-000-000', 'BL11-000-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-001', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-002', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-003', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-004', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-005', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-006', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-007', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-008', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-009', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-021', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-022', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-023', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-024', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-025', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-026', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-027', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-028', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-029', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-036', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 12 - Todos', 'Descri��o do ativo', 'F', 0, 0, 997.93, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-000', 'BL12-000-000', 'BL12-000-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-001', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-002', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-003', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-004', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-005', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-006', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-007', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-008', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-009', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-010', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-020', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-021', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-022', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-023', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-024', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-025', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-026', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-027', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-028', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-029', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-036', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-000', 'BL12-000-000', 'BL12-000-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-001', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-002', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-003', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-004', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-005', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-006', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-007', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-008', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-009', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-021', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-022', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-023', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-024', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-025', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-026', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-027', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-028', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-029', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-036', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 13 - Todos', 'Descri��o do ativo', 'F', 0, 0, 1575.77, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-000', 'BL13-000-000', 'BL13-000-000', 'Bloco 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-001', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-002', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-003', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-005', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-006', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-007', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-009', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-000', 'BL13-000-000', 'BL13-000-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-001', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-002', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-003', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-004', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-005', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-006', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-007', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-009', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-022', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-026', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-030', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-032', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-034', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-036', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-038', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-040', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-000', 'BL13-000-000', 'BL13-000-000', 'Bloco 13 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-002', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-003', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-004', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-005', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-006', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-007', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-008', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-009', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-000', 'BL13-000-000', 'BL13-000-000', 'Bloco 13 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-001', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-002', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-003', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-004', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-005', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-007', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-009', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 14 - Todos', 'Descri��o do ativo', 'F', 0, 0, 10719.12, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-000', 'BL14-000-000', 'BL14-000-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-027', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-028', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-029', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-030', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-031', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-032', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-033', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-034', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-035', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-036', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-037', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-038', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-039', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-040', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-041', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-042', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-043', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-044', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-045', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-046', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-047', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-078', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-079', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-080', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-081', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-088', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-092', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-093', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-096', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-097', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-000', 'BL14-000-000', 'BL14-000-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-001', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-002', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-003', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-004', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-005', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-006', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-007', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-008', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-009', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-010', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-011', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-012', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-013', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-014', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-015', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-016', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-017', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-018', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-019', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-020', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-021', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-022', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-023', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-024', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-025', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-026', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-027', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-028', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-029', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-030', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-031', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-032', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-033', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-034', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-035', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-036', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-037', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-038', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-039', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-040', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-041', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-042', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-043', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-044', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-045', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-046', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-047', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-048', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-049', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-050', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-051', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-056', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-058', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-059', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-064', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-065', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-068', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-072', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-073', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-076', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-080', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-084', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-088', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-090', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-092', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-096', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-097', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-098', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-099', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-000', 'BL14-000-000', 'BL14-000-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-014', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-030', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-035', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-036', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-037', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-038', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-039', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-040', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-041', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-042', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-043', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-046', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-047', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-049', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-050', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-057', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-058', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-060', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-063', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-065', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-068', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-071', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-072', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-073', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-074', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-075', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-076', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-077', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-078', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-079', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-080', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-081', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-082', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-083', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-084', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-087', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-090', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-094', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-096', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-000', 'BL14-000-000', 'BL14-000-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-001', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-002', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-003', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-004', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-005', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-006', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-007', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-008', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-009', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-010', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-011', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-012', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-013', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-014', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-015', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-016', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-017', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-018', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-019', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-020', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-021', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-022', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-023', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-024', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-025', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-026', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-027', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-028', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-029', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-030', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-031', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-032', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-033', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-034', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-035', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-036', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-037', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-038', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-039', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-040', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-041', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-042', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-043', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-044', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-045', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-046', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-047', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-048', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-049', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-051', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-052', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 15 - Todos', 'Descri��o do ativo', 'F', 0, 0, 1357.01, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-000', 'BL15-000-000', 'BL15-000-000', 'Bloco 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-002', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-011', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-012', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-013', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-021', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-022', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-023', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-031', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-032', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-033', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-MEZ-000', 'BL15-000-000', 'BL15-000-000', 'Bloco 15 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-MEZ-011', 'BL15-MEZ-000', 'BL15-MEZ-000', 'Bloco 15 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-MEZ-012', 'BL15-MEZ-000', 'BL15-MEZ-000', 'Bloco 15 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-MEZ-021', 'BL15-MEZ-000', 'BL15-MEZ-000', 'Bloco 15 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-MEZ-023', 'BL15-MEZ-000', 'BL15-MEZ-000', 'Bloco 15 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-000', 'BL15-000-000', 'BL15-000-000', 'Bloco 15 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-001', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-002', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-003', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-031', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-032', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-033', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 16 - Todos', 'Descri��o do ativo', 'F', 0, 0, 7198.68, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-000', 'BL16-000-000', 'BL16-000-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-001', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-002', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-003', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-004', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-005', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-006', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-007', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-008', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-009', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-021', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-022', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-023', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-024', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-025', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-026', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-027', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-028', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-034', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-041', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-042', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-045', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-048', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-052', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-062', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-070', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-071', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-072', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-075', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-076', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-080', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-081', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-000', 'BL16-000-000', 'BL16-000-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-001', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-002', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-003', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-004', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-007', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-008', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-009', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-021', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-022', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-023', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-025', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-026', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-027', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-028', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-031', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-034', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-041', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-042', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-045', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-047', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-048', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-COB-000', 'BL16-000-000', 'BL16-000-000', 'Bloco 16 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 17 - Todos', 'Descri��o do ativo', 'F', 0, 0, 2920.93, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-000', 'BL17-000-000', 'BL17-000-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-001', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-002', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-003', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-004', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-005', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-006', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-007', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-008', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-009', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-010', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-013', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-014', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-015', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-016', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-017', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-018', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-019', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-020', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-021', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-022', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-023', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-024', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-025', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-026', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-027', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-028', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-029', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-030', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-031', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-032', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-033', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-034', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-035', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-042', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-044', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-046', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-048', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-050', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-052', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-054', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-056', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-058', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-060', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-062', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-064', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-066', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-068', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-070', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-072', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-074', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-076', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-078', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-000', 'BL17-000-000', 'BL17-000-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-001', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-002', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-003', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-004', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-005', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-006', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-007', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-008', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-009', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-010', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-011', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-012', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-013', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-014', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-015', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-016', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-017', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-018', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-019', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-020', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-021', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-022', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-023', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-024', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-025', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-026', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-027', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-028', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-029', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-030', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-031', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-032', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-033', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-034', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-035', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-037', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-038', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-039', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-040', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-043', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-044', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-048', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-052', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-054', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-056', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-058', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-060', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-062', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-064', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-066', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-068', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-070', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-072', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-074', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-076', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-078', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-080', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-082', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-084', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-000', 'BL17-000-000', 'BL17-000-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-011', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-013', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-015', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-017', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-019', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-021', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-023', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-025', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-027', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-031', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-033', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-035', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-037', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-039', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-041', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-043', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-045', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-047', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-071', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-077', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-081', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-082', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-083', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-084', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-085', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-086', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-089', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-091', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-093', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-094', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-095', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-096', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-097', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 18 - Todos', 'Descri��o do ativo', 'F', 0, 0, 842.08, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-000', 'BL18-000-000', 'BL18-000-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-001', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-002', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-003', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-004', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-005', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-006', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-007', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-008', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-009', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-012', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-013', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-014', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-015', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-017', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-021', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-022', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-023', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-025', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-026', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-027', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-028', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-029', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-031', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-032', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-033', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-034', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-041', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-042', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-043', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-044', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-000', 'BL18-000-000', 'BL18-000-000', 'Bloco 18 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-001', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-003', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-007', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-009', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-013', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-017', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-021', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-023', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-027', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-029', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 19 - Todos', 'Descri��o do ativo', 'F', 0, 0, 3713.23, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-000', 'BL19-000-000', 'BL19-000-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-001', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-002', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-003', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-004', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-005', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-006', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-007', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-008', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-009', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-010', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-011', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-012', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-013', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-014', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-015', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-016', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-017', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-018', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-019', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-026', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-039', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-040', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-041', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-042', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-043', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-044', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-045', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-046', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-047', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-048', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-049', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-060', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-062', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-064', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-070', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-MEZ-000', 'BL19-000-000', 'BL19-000-000', 'Bloco 19 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-MEZ-009', 'BL19-MEZ-000', 'BL19-MEZ-000', 'Bloco 19 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-000', 'BL19-000-000', 'BL19-000-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-002', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-004', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-006', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-008', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-009', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-011', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-013', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-015', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-017', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-019', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-040', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-042', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-044', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-046', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-048', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-049', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 20 - Todos', 'Descri��o do ativo', 'F', 0, 0, 274.2, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-000', 'BL20-000-000', 'BL20-000-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-001', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-004', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-008', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-011', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-012', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-014', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-015', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-016', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-018', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-021', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-022', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-028', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-MEZ-000', 'BL20-000-000', 'BL20-000-000', 'Bloco 20 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-MEZ-016', 'BL20-MEZ-000', 'BL20-MEZ-000', 'Bloco 20 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-COB-000', 'BL20-000-000', 'BL20-000-000', 'Bloco 20 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 21 - Todos', 'Descri��o do ativo', 'F', 0, 0, 447.28, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-000', 'BL21-000-000', 'BL21-000-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-001', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-002', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-003', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-012', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-014', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-016', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-021', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-023', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-025', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-027', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-029', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-MEZ-000', 'BL21-000-000', 'BL21-000-000', 'Bloco 21 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-MEZ-001', 'BL21-MEZ-000', 'BL21-MEZ-000', 'Bloco 21 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-COB-000', 'BL21-000-000', 'BL21-000-000', 'Bloco 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-COB-001', 'BL21-COB-000', 'BL21-COB-000', 'Bloco 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-COB-003', 'BL21-COB-000', 'BL21-COB-000', 'Bloco 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-COB-012', 'BL21-COB-000', 'BL21-COB-000', 'Bloco 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-COB-014', 'BL21-COB-000', 'BL21-COB-000', 'Bloco 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-000-000', 'CASF-000-000', 'CASF-000-000', 'SHIS QL12 CJ11 Casa 01 - Todos', 'Descri��o do ativo', 'F', -15.829342, -47.861281, 979.67, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-000', 'SHIS-000-000', 'SHIS-000-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-001', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-002', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-003', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-004', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-005', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-006', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-007', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-008', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-009', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-010', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-012', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-013', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-014', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-015', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-018', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-019', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-020', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-024', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-026', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-030', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-032', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-038', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-040', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-041', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-042', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-043', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-044', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-045', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-046', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-050', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-052', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-060', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-064', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-066', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-068', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-069', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-070', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-074', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-090', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-092', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-094', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-000', 'SHIS-000-000', 'SHIS-000-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-003', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-004', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-005', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-006', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-007', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-008', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-010', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-012', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-013', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-019', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-020', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-024', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-030', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-038', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-000-000', 'CASF-000-000', 'CASF-000-000', 'SQS 309 BL C - Todos', 'Descri��o do ativo', 'F', -15.816814, -47.909043, 8260.33, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-001', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-002', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-003', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-004', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-005', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-006', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-007', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-008', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-009', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-010', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-011', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-012', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-023', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-024', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-029', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-030', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-001', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-002', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-003', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-004', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-005', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-006', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-007', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-008', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-009', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-010', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-011', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-012', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-021', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-022', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-023', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-024', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-025', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-026', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-027', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-028', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-029', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-060', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-062', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-064', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-066', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-068', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-070', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-072', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-074', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-076', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-080', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-082', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-084', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-086', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-088', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-001', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-003', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-101', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-102', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-103', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-104', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-111', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-112', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-113', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-114', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-121', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-122', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-123', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-124', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-001', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-003', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-201', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-202', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-203', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-204', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-211', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-212', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-213', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-214', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-221', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-222', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-223', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-224', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-001', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-003', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-301', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-302', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-303', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-304', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-311', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-312', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-313', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-314', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-321', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-322', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-323', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-324', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-001', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-003', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-401', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-402', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-403', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-404', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-411', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-412', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-413', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-414', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-421', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-422', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-423', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-424', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-001', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-003', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-501', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-502', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-503', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-504', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-511', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-512', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-513', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-514', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-521', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-522', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-523', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-524', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-001', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-003', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-601', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-602', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-603', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-604', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-611', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-612', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-613', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-614', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-621', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-622', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-623', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-624', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-001', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-003', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-011', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-012', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-013', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-014', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-021', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-022', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-023', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-024', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-000-000', 'CASF-000-000', 'CASF-000-000', 'SQS 309 BL D - Todos', 'Descri��o do ativo', 'F', -15.816553, -47.907293, 8282.38, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-001', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-002', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-003', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-004', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-005', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-006', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-007', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-008', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-009', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-010', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-011', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-012', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-023', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-024', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-029', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-030', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-031', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-032', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-001', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-002', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-003', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-004', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-005', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-006', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-007', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-008', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-009', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-010', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-011', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-012', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-023', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-024', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-025', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-026', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-027', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-028', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-029', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-030', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-050', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-060', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-062', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-064', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-066', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-068', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-070', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-072', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-074', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-076', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-078', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-080', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-082', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-084', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-086', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-088', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-092', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-094', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-096', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-098', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-001', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-003', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-101', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-102', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-103', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-104', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-111', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-112', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-113', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-114', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-121', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-122', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-123', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-124', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-001', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-003', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-201', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-202', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-203', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-204', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-211', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-212', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-213', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-214', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-221', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-222', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-223', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-224', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-001', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-003', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-301', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-302', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-303', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-304', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-311', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-312', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-313', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-314', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-321', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-322', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-323', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-324', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-001', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-003', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-401', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-402', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-403', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-404', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-411', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-412', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-413', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-414', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-421', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-422', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-423', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-424', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-001', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-003', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-501', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-502', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-503', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-504', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-511', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-512', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-513', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-514', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-521', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-522', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-523', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-524', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-001', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-003', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-601', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-602', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-603', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-604', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-611', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-612', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-613', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-614', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-621', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-622', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-623', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-624', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-001', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-003', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-011', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-012', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-013', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-014', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-021', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-022', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-023', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-024', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-000-000', 'CASF-000-000', 'CASF-000-000', 'SQS 309 BL G - Todos', 'Descri��o do ativo', 'F', 0, 0, 8260.33, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-001', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-002', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-003', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-004', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-005', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-006', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-007', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-008', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-009', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-010', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-011', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-012', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-023', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-024', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-029', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-030', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-001', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-002', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-003', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-004', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-005', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-006', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-007', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-008', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-009', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-010', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-011', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-012', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-023', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-024', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-025', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-026', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-027', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-028', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-029', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-031', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-050', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-052', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-054', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-056', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-060', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-062', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-064', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-066', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-068', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-070', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-072', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-074', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-076', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-078', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-082', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-084', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-086', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-088', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-001', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-003', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-101', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-102', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-103', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-104', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-111', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-112', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-113', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-114', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-121', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-122', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-123', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-124', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-001', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-003', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-201', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-202', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-203', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-204', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-211', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-212', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-213', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-214', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-221', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-222', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-223', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-224', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-001', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-003', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-301', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-302', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-303', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-304', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-311', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-312', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-313', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-314', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-321', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-322', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-323', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-324', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-001', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-003', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-401', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-402', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-403', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-404', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-411', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-412', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-413', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-414', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-421', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-422', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-423', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-424', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-001', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-003', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-501', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-502', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-503', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-504', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-511', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-512', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-513', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-514', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-521', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-522', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-523', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-524', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-001', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-003', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-601', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-602', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-603', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-604', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-611', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-612', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-613', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-614', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-621', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-622', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-623', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-624', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-001', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-003', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-011', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-012', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-013', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-014', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-021', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-022', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-023', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-024', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('316C-000-000', 'CASF-000-000', 'CASF-000-000', 'SQS 316 BL C - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('316C-P04-000', '316C-000-000', '316C-000-000', 'SQS 316 BL C - 4� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 01 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-000', 'AT01-000-000', 'AT01-000-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-001', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-002', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-003', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-004', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-005', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-006', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-007', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-008', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-009', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-010', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-011', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-012', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-013', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-014', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-021', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-022', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-023', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-024', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-031', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-041', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-042', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-043', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-050', 'AT01-SS2-000', 'AT01-SS2-000', '�rea t�cnica 01 - 2� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT02-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 02 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT02-SS1-000', 'AT02-000-000', 'AT02-000-000', '�rea t�cnica 02 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT02-TER-000', 'AT02-000-000', 'AT02-000-000', '�rea t�cnica 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT02-TER-001', 'AT02-TER-000', 'AT02-TER-000', '�rea t�cnica 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT03-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 03 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT03-SS1-000', 'AT03-000-000', 'AT03-000-000', '�rea t�cnica 03 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT03-TER-000', 'AT03-000-000', 'AT03-000-000', '�rea t�cnica 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT03-TER-001', 'AT03-TER-000', 'AT03-TER-000', '�rea t�cnica 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 10 - Todos', 'Descri��o do ativo', 'F', 0, 0, 1325.42, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-000', 'AT10-000-000', 'AT10-000-000', '�rea t�cnica 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-002', 'AT10-SEM-000', 'AT10-SEM-000', '�rea t�cnica 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-003', 'AT10-SEM-000', 'AT10-SEM-000', '�rea t�cnica 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-004', 'AT10-SEM-000', 'AT10-SEM-000', '�rea t�cnica 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-005', 'AT10-SEM-000', 'AT10-SEM-000', '�rea t�cnica 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-007', 'AT10-SEM-000', 'AT10-SEM-000', '�rea t�cnica 10 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-000', 'AT10-000-000', 'AT10-000-000', '�rea t�cnica 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-001', 'AT10-COB-000', 'AT10-COB-000', '�rea t�cnica 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-002', 'AT10-COB-000', 'AT10-COB-000', '�rea t�cnica 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-003', 'AT10-COB-000', 'AT10-COB-000', '�rea t�cnica 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-004', 'AT10-COB-000', 'AT10-COB-000', '�rea t�cnica 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-006', 'AT10-COB-000', 'AT10-COB-000', '�rea t�cnica 10 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT11-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 11 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT11-TER-000', 'AT11-000-000', 'AT11-000-000', '�rea t�cnica 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT11-TER-001', 'AT11-TER-000', 'AT11-TER-000', '�rea t�cnica 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT11-COB-000', 'AT11-000-000', 'AT11-000-000', '�rea t�cnica 11 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT12-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 12 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT12-SS1-000', 'AT12-000-000', 'AT12-000-000', '�rea t�cnica 12 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT12-TER-000', 'AT12-000-000', 'AT12-000-000', '�rea t�cnica 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT12-TER-001', 'AT12-TER-000', 'AT12-TER-000', '�rea t�cnica 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT12-TER-002', 'AT12-TER-000', 'AT12-TER-000', '�rea t�cnica 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 13 - Todos', 'Descri��o do ativo', 'F', 0, 0, 623.29, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-000', 'AT13-000-000', 'AT13-000-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-001', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-005', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-008', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-011', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-013', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-014', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-015', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-016', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-017', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-018', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-020', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-021', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-022', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-025', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-029', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-033', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-035', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-037', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-038', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-041', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-043', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-045', 'AT13-SS1-000', 'AT13-SS1-000', '�rea t�cnica 13 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-000', 'AT13-000-000', 'AT13-000-000', '�rea t�cnica 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-008', 'AT13-TER-000', 'AT13-TER-000', '�rea t�cnica 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-020', 'AT13-TER-000', 'AT13-TER-000', '�rea t�cnica 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-029', 'AT13-TER-000', 'AT13-TER-000', '�rea t�cnica 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-033', 'AT13-TER-000', 'AT13-TER-000', '�rea t�cnica 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-037', 'AT13-TER-000', 'AT13-TER-000', '�rea t�cnica 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 14 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-000', 'AT14-000-000', 'AT14-000-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-001', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-002', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-003', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-004', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-005', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-006', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-007', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-008', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-009', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-010', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-011', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-012', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-013', 'AT14-SS1-000', 'AT14-SS1-000', '�rea t�cnica 14 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-000', 'AT14-000-000', 'AT14-000-000', '�rea t�cnica 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-001', 'AT14-TER-000', 'AT14-TER-000', '�rea t�cnica 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-003', 'AT14-TER-000', 'AT14-TER-000', '�rea t�cnica 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-005', 'AT14-TER-000', 'AT14-TER-000', '�rea t�cnica 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-007', 'AT14-TER-000', 'AT14-TER-000', '�rea t�cnica 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-009', 'AT14-TER-000', 'AT14-TER-000', '�rea t�cnica 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-011', 'AT14-TER-000', 'AT14-TER-000', '�rea t�cnica 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-013', 'AT14-TER-000', 'AT14-TER-000', '�rea t�cnica 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 20 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-SS1-000', 'AT20-000-000', 'AT20-000-000', '�rea t�cnica 20 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-SS1-001', 'AT20-SS1-000', 'AT20-SS1-000', '�rea t�cnica 20 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-SS1-002', 'AT20-SS1-000', 'AT20-SS1-000', '�rea t�cnica 20 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-SS1-003', 'AT20-SS1-000', 'AT20-SS1-000', '�rea t�cnica 20 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-SS1-004', 'AT20-SS1-000', 'AT20-SS1-000', '�rea t�cnica 20 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-TER-000', 'AT20-000-000', 'AT20-000-000', '�rea t�cnica 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-TER-001', 'AT20-TER-000', 'AT20-TER-000', '�rea t�cnica 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-TER-002', 'AT20-TER-000', 'AT20-TER-000', '�rea t�cnica 20 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 21 - Todos', 'Descri��o do ativo', 'F', 0, 0, 1855.91, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-000', 'AT21-000-000', 'AT21-000-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-001', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-002', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-003', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-004', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-005', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-006', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-010', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-011', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-012', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-013', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-014', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-015', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-016', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-023', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-024', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-025', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-026', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-033', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-034', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-035', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-036', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-040', 'AT21-SEM-000', 'AT21-SEM-000', '�rea t�cnica 21 - Pavimento Semienterrado', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-000', 'AT21-000-000', 'AT21-000-000', '�rea t�cnica 21 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-011', 'AT21-MEZ-000', 'AT21-MEZ-000', '�rea t�cnica 21 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-012', 'AT21-MEZ-000', 'AT21-MEZ-000', '�rea t�cnica 21 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-013', 'AT21-MEZ-000', 'AT21-MEZ-000', '�rea t�cnica 21 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-014', 'AT21-MEZ-000', 'AT21-MEZ-000', '�rea t�cnica 21 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-015', 'AT21-MEZ-000', 'AT21-MEZ-000', '�rea t�cnica 21 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-023', 'AT21-MEZ-000', 'AT21-MEZ-000', '�rea t�cnica 21 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-035', 'AT21-MEZ-000', 'AT21-MEZ-000', '�rea t�cnica 21 - Mezanino', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-000', 'AT21-000-000', 'AT21-000-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-001', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-002', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-003', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-004', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-005', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-006', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-011', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-012', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-013', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-014', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-015', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-016', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-033', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-034', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-035', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-036', 'AT21-COB-000', 'AT21-COB-000', '�rea t�cnica 21 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT22-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 22 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT22-TER-000', 'AT22-000-000', 'AT22-000-000', '�rea t�cnica 22 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT22-TER-001', 'AT22-TER-000', 'AT22-TER-000', '�rea t�cnica 22 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT22-COB-000', 'AT22-000-000', 'AT22-000-000', '�rea t�cnica 22 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT23-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 23 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT23-TER-000', 'AT23-000-000', 'AT23-000-000', '�rea t�cnica 23 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT23-TER-001', 'AT23-TER-000', 'AT23-TER-000', '�rea t�cnica 23 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT23-COB-000', 'AT23-000-000', 'AT23-000-000', '�rea t�cnica 23 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT23-COB-001', 'AT23-COB-000', 'AT23-COB-000', '�rea t�cnica 23 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 24 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-SS1-000', 'AT24-000-000', 'AT24-000-000', '�rea t�cnica 24 - 1� Subsolo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-TER-000', 'AT24-000-000', 'AT24-000-000', '�rea t�cnica 24 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-TER-001', 'AT24-TER-000', 'AT24-TER-000', '�rea t�cnica 24 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-TER-002', 'AT24-TER-000', 'AT24-TER-000', '�rea t�cnica 24 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-TER-011', 'AT24-TER-000', 'AT24-TER-000', '�rea t�cnica 24 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-TER-012', 'AT24-TER-000', 'AT24-TER-000', '�rea t�cnica 24 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT30-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 30 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT30-TER-000', 'AT30-000-000', 'AT30-000-000', '�rea t�cnica 30 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT30-TER-001', 'AT30-TER-000', 'AT30-TER-000', '�rea t�cnica 30 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT30-TER-002', 'AT30-TER-000', 'AT30-TER-000', '�rea t�cnica 30 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 31 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-000', 'AT31-000-000', 'AT31-000-000', '�rea t�cnica 31 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-001', 'AT31-TER-000', 'AT31-TER-000', '�rea t�cnica 31 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-002', 'AT31-TER-000', 'AT31-TER-000', '�rea t�cnica 31 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-003', 'AT31-TER-000', 'AT31-TER-000', '�rea t�cnica 31 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-004', 'AT31-TER-000', 'AT31-TER-000', '�rea t�cnica 31 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-005', 'AT31-TER-000', 'AT31-TER-000', '�rea t�cnica 31 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-006', 'AT31-TER-000', 'AT31-TER-000', '�rea t�cnica 31 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-007', 'AT31-TER-000', 'AT31-TER-000', '�rea t�cnica 31 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-000', 'AT31-000-000', 'AT31-000-000', '�rea t�cnica 31 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-001', 'AT31-COB-000', 'AT31-COB-000', '�rea t�cnica 31 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-002', 'AT31-COB-000', 'AT31-COB-000', '�rea t�cnica 31 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-003', 'AT31-COB-000', 'AT31-COB-000', '�rea t�cnica 31 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-004', 'AT31-COB-000', 'AT31-COB-000', '�rea t�cnica 31 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-012', 'AT31-COB-000', 'AT31-COB-000', '�rea t�cnica 31 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-013', 'AT31-COB-000', 'AT31-COB-000', '�rea t�cnica 31 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT32-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 32 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT32-TER-000', 'AT32-000-000', 'AT32-000-000', '�rea t�cnica 32 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT32-TER-001', 'AT32-TER-000', 'AT32-TER-000', '�rea t�cnica 32 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT32-TER-002', 'AT32-TER-000', 'AT32-TER-000', '�rea t�cnica 32 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 33 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-TER-000', 'AT33-000-000', 'AT33-000-000', '�rea t�cnica 33 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-TER-001', 'AT33-TER-000', 'AT33-TER-000', '�rea t�cnica 33 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-TER-002', 'AT33-TER-000', 'AT33-TER-000', '�rea t�cnica 33 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-TER-003', 'AT33-TER-000', 'AT33-TER-000', '�rea t�cnica 33 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-TER-004', 'AT33-TER-000', 'AT33-TER-000', '�rea t�cnica 33 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-COB-000', 'AT33-000-000', 'AT33-000-000', '�rea t�cnica 33 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT40-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 40 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT40-TER-000', 'AT40-000-000', 'AT40-000-000', '�rea t�cnica 40 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT40-TER-001', 'AT40-TER-000', 'AT40-TER-000', '�rea t�cnica 40 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT40-TER-002', 'AT40-TER-000', 'AT40-TER-000', '�rea t�cnica 40 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT40-COB-000', 'AT40-000-000', 'AT40-000-000', '�rea t�cnica 40 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT41-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 41 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT41-TER-000', 'AT41-000-000', 'AT41-000-000', '�rea t�cnica 41 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT41-TER-001', 'AT41-TER-000', 'AT41-TER-000', '�rea t�cnica 41 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT41-COB-000', 'AT41-000-000', 'AT41-000-000', '�rea t�cnica 41 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 42 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-TER-000', 'AT42-000-000', 'AT42-000-000', '�rea t�cnica 42 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-TER-001', 'AT42-TER-000', 'AT42-TER-000', '�rea t�cnica 42 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-TER-002', 'AT42-TER-000', 'AT42-TER-000', '�rea t�cnica 42 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-TER-003', 'AT42-TER-000', 'AT42-TER-000', '�rea t�cnica 42 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-COB-000', 'AT42-000-000', 'AT42-000-000', '�rea t�cnica 42 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-COB-001', 'AT42-COB-000', 'AT42-COB-000', '�rea t�cnica 42 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-COB-002', 'AT42-COB-000', 'AT42-COB-000', '�rea t�cnica 42 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-COB-003', 'AT42-COB-000', 'AT42-COB-000', '�rea t�cnica 42 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT43-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 43 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT43-TER-000', 'AT43-000-000', 'AT43-000-000', '�rea t�cnica 43 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT43-TER-001', 'AT43-TER-000', 'AT43-TER-000', '�rea t�cnica 43 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT43-TER-002', 'AT43-TER-000', 'AT43-TER-000', '�rea t�cnica 43 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 44 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-TER-000', 'AT44-000-000', 'AT44-000-000', '�rea t�cnica 44 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-COB-000', 'AT44-000-000', 'AT44-000-000', '�rea t�cnica 44 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-COB-001', 'AT44-COB-000', 'AT44-COB-000', '�rea t�cnica 44 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-COB-003', 'AT44-COB-000', 'AT44-COB-000', '�rea t�cnica 44 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-COB-005', 'AT44-COB-000', 'AT44-COB-000', '�rea t�cnica 44 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-COB-006', 'AT44-COB-000', 'AT44-COB-000', '�rea t�cnica 44 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 50 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-000', 'AT50-000-000', 'AT50-000-000', '�rea t�cnica 50 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-002', 'AT50-TER-000', 'AT50-TER-000', '�rea t�cnica 50 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-008', 'AT50-TER-000', 'AT50-TER-000', '�rea t�cnica 50 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-015', 'AT50-TER-000', 'AT50-TER-000', '�rea t�cnica 50 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-022', 'AT50-TER-000', 'AT50-TER-000', '�rea t�cnica 50 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-025', 'AT50-TER-000', 'AT50-TER-000', '�rea t�cnica 50 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-028', 'AT50-TER-000', 'AT50-TER-000', '�rea t�cnica 50 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-035', 'AT50-TER-000', 'AT50-TER-000', '�rea t�cnica 50 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-045', 'AT50-TER-000', 'AT50-TER-000', '�rea t�cnica 50 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-COB-000', 'AT50-000-000', 'AT50-000-000', '�rea t�cnica 50 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-COB-015', 'AT50-COB-000', 'AT50-COB-000', '�rea t�cnica 50 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-COB-025', 'AT50-COB-000', 'AT50-COB-000', '�rea t�cnica 50 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-COB-035', 'AT50-COB-000', 'AT50-COB-000', '�rea t�cnica 50 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-COB-045', 'AT50-COB-000', 'AT50-COB-000', '�rea t�cnica 50 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT51-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 51 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT51-TER-000', 'AT51-000-000', 'AT51-000-000', '�rea t�cnica 51 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT51-TER-001', 'AT51-TER-000', 'AT51-TER-000', '�rea t�cnica 51 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT51-COB-000', 'AT51-000-000', 'AT51-000-000', '�rea t�cnica 51 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 52 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-TER-000', 'AT52-000-000', 'AT52-000-000', '�rea t�cnica 52 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-TER-002', 'AT52-TER-000', 'AT52-TER-000', '�rea t�cnica 52 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-TER-004', 'AT52-TER-000', 'AT52-TER-000', '�rea t�cnica 52 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-COB-000', 'AT52-000-000', 'AT52-000-000', '�rea t�cnica 52 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-COB-004', 'AT52-COB-000', 'AT52-COB-000', '�rea t�cnica 52 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 53 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-000', 'AT53-000-000', 'AT53-000-000', '�rea t�cnica 53 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-001', 'AT53-TER-000', 'AT53-TER-000', '�rea t�cnica 53 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-002', 'AT53-TER-000', 'AT53-TER-000', '�rea t�cnica 53 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-004', 'AT53-TER-000', 'AT53-TER-000', '�rea t�cnica 53 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-012', 'AT53-TER-000', 'AT53-TER-000', '�rea t�cnica 53 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-013', 'AT53-TER-000', 'AT53-TER-000', '�rea t�cnica 53 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-014', 'AT53-TER-000', 'AT53-TER-000', '�rea t�cnica 53 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-015', 'AT53-TER-000', 'AT53-TER-000', '�rea t�cnica 53 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-016', 'AT53-TER-000', 'AT53-TER-000', '�rea t�cnica 53 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-COB-000', 'AT53-000-000', 'AT53-000-000', '�rea t�cnica 53 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-COB-001', 'AT53-COB-000', 'AT53-COB-000', '�rea t�cnica 53 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-COB-014', 'AT53-COB-000', 'AT53-COB-000', '�rea t�cnica 53 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-COB-016', 'AT53-COB-000', 'AT53-COB-000', '�rea t�cnica 53 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 60 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-000', 'AT60-000-000', 'AT60-000-000', '�rea t�cnica 60 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-002', 'AT60-TER-000', 'AT60-TER-000', '�rea t�cnica 60 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-003', 'AT60-TER-000', 'AT60-TER-000', '�rea t�cnica 60 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-005', 'AT60-TER-000', 'AT60-TER-000', '�rea t�cnica 60 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-011', 'AT60-TER-000', 'AT60-TER-000', '�rea t�cnica 60 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-013', 'AT60-TER-000', 'AT60-TER-000', '�rea t�cnica 60 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-015', 'AT60-TER-000', 'AT60-TER-000', '�rea t�cnica 60 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-022', 'AT60-TER-000', 'AT60-TER-000', '�rea t�cnica 60 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-023', 'AT60-TER-000', 'AT60-TER-000', '�rea t�cnica 60 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-025', 'AT60-TER-000', 'AT60-TER-000', '�rea t�cnica 60 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-000', 'AT60-000-000', 'AT60-000-000', '�rea t�cnica 60 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-001', 'AT60-COB-000', 'AT60-COB-000', '�rea t�cnica 60 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-003', 'AT60-COB-000', 'AT60-COB-000', '�rea t�cnica 60 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-005', 'AT60-COB-000', 'AT60-COB-000', '�rea t�cnica 60 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-013', 'AT60-COB-000', 'AT60-COB-000', '�rea t�cnica 60 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-015', 'AT60-COB-000', 'AT60-COB-000', '�rea t�cnica 60 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-023', 'AT60-COB-000', 'AT60-COB-000', '�rea t�cnica 60 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-025', 'AT60-COB-000', 'AT60-COB-000', '�rea t�cnica 60 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT61-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 61 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT61-P01-000', 'AT61-000-000', 'AT61-000-000', '�rea t�cnica 61 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT61-P01-001', 'AT61-P01-000', 'AT61-P01-000', '�rea t�cnica 61 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT61-P01-002', 'AT61-P01-000', 'AT61-P01-000', '�rea t�cnica 61 - 1� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT62-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 62 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT62-TER-000', 'AT62-000-000', 'AT62-000-000', '�rea t�cnica 62 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT62-TER-002', 'AT62-TER-000', 'AT62-TER-000', '�rea t�cnica 62 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT62-TER-003', 'AT62-TER-000', 'AT62-TER-000', '�rea t�cnica 62 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT62-TER-004', 'AT62-TER-000', 'AT62-TER-000', '�rea t�cnica 62 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 63 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-000', 'AT63-000-000', 'AT63-000-000', '�rea t�cnica 63 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-001', 'AT63-TER-000', 'AT63-TER-000', '�rea t�cnica 63 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-002', 'AT63-TER-000', 'AT63-TER-000', '�rea t�cnica 63 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-003', 'AT63-TER-000', 'AT63-TER-000', '�rea t�cnica 63 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-004', 'AT63-TER-000', 'AT63-TER-000', '�rea t�cnica 63 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-005', 'AT63-TER-000', 'AT63-TER-000', '�rea t�cnica 63 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT64-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 64 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT64-TER-000', 'AT64-000-000', 'AT64-000-000', '�rea t�cnica 64 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT64-TER-001', 'AT64-TER-000', 'AT64-TER-000', '�rea t�cnica 64 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 65 - Todos', 'Descri��o do ativo', 'F', 0, 0, 199.06, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-000', 'AT65-000-000', 'AT65-000-000', '�rea t�cnica 65 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-008', 'AT65-P11-000', 'AT65-P11-000', '�rea t�cnica 65 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-009', 'AT65-P11-000', 'AT65-P11-000', '�rea t�cnica 65 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-010', 'AT65-P11-000', 'AT65-P11-000', '�rea t�cnica 65 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-011', 'AT65-P11-000', 'AT65-P11-000', '�rea t�cnica 65 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-018', 'AT65-P11-000', 'AT65-P11-000', '�rea t�cnica 65 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-019', 'AT65-P11-000', 'AT65-P11-000', '�rea t�cnica 65 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-020', 'AT65-P11-000', 'AT65-P11-000', '�rea t�cnica 65 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-021', 'AT65-P11-000', 'AT65-P11-000', '�rea t�cnica 65 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-030', 'AT65-P11-000', 'AT65-P11-000', '�rea t�cnica 65 - 11� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-000', 'AT65-000-000', 'AT65-000-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-001', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-002', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-003', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-004', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-005', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-006', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-007', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-008', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-009', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-010', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-011', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-012', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-013', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-014', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-015', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-016', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-017', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-018', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-019', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-020', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-021', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-022', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-026', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-027', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-028', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-030', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-031', 'AT65-P12-000', 'AT65-P12-000', '�rea t�cnica 65 - 12� Pavimento', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT66-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 66 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT67-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 67 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT67-TER-000', 'AT67-000-000', 'AT67-000-000', '�rea t�cnica 67 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT67-TER-001', 'AT67-TER-000', 'AT67-TER-000', '�rea t�cnica 67 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT67-COB-000', 'AT67-000-000', 'AT67-000-000', '�rea t�cnica 67 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT67-COB-001', 'AT67-COB-000', 'AT67-COB-000', '�rea t�cnica 67 - Cobertura', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT70-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 70 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT71-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 71 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT72-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 72 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT73-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 73 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT74-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 74 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT75-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 75 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT76-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 76 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT77-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 77 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT78-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 78 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT79-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 79 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT80-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 80 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT81-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 81 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT82-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 82 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT83-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 83 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT84-000-000', 'CASF-000-000', 'CASF-000-000', '�rea t�cnica 84 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES01-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 01 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES01-TER-000', 'ES01-000-000', 'ES01-000-000', 'Estacionamento 01 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES01-TER-001', 'ES01-TER-000', 'ES01-TER-000', 'Estacionamento 01 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES01-TER-002', 'ES01-TER-000', 'ES01-TER-000', 'Estacionamento 01 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES01-TER-003', 'ES01-TER-000', 'ES01-TER-000', 'Estacionamento 01 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 02 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-000', 'ES02-000-000', 'ES02-000-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-001', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-003', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-005', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-007', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-011', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-013', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-014', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-016', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-017', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-018', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-019', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-020', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-025', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-027', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 03 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-TER-000', 'ES03-000-000', 'ES03-000-000', 'Estacionamento 03 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-TER-001', 'ES03-TER-000', 'ES03-TER-000', 'Estacionamento 03 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-TER-002', 'ES03-TER-000', 'ES03-TER-000', 'Estacionamento 03 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-TER-003', 'ES03-TER-000', 'ES03-TER-000', 'Estacionamento 03 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-TER-004', 'ES03-TER-000', 'ES03-TER-000', 'Estacionamento 03 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 04 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-000', 'ES04-000-000', 'ES04-000-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-007', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-008', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-009', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-010', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-011', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-012', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-021', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-022', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-023', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-024', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-025', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-026', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-027', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-028', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-029', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-030', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-031', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-032', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-041', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-043', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-045', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-051', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-052', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-053', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-054', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-055', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-061', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-062', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-063', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-064', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-065', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-091', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-092', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-093', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-094', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-095', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-096', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-097', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-098', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-099', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 05 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-000', 'ES05-000-000', 'ES05-000-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-001', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-005', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-009', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-011', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-015', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-019', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-021', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-029', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-031', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-033', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-035', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-037', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-039', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-041', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-049', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-051', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-055', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-059', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-061', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-062', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-063', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-064', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-065', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-066', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-067', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-068', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-069', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-070', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-071', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-072', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-073', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-074', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-083', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-089', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 06 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-000', 'ES06-000-000', 'ES06-000-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-001', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-003', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-005', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-011', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-013', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-015', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-017', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-019', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-021', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-023', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-031', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-033', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-035', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-041', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-043', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-045', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-047', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-049', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-051', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-053', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-055', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-057', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-059', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-061', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-071', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 07 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-000', 'ES07-000-000', 'ES07-000-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-001', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-005', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-007', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-009', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-011', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-012', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-013', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-014', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-015', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-016', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-017', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-019', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-020', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-021', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-023', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-024', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-025', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-026', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-027', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-031', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-032', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-033', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-034', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-035', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-036', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-037', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-039', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-040', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-041', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-043', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-044', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-045', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-046', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-047', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-051', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-052', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-053', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-054', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-055', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-056', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-057', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-059', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-060', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-061', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-063', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-064', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-065', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-066', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-067', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-071', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-072', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-073', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-074', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-075', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-076', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-077', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-079', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-080', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-081', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-083', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-084', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-087', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-090', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento T�rreo ', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 08 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-000', 'ES08-000-000', 'ES08-000-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-001', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-003', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-005', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-011', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-013', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-015', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-025', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-027', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-035', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-037', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-039', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-045', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-047', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-049', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 09 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-000', 'ES09-000-000', 'ES09-000-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-001', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-003', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-005', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-011', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-013', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-015', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-021', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-023', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-025', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-031', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-033', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-035', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 10 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-000', 'ES10-000-000', 'ES10-000-000', 'Estacionamento 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-001', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-003', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-005', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-011', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-013', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-021', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-023', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-025', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 11 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-000', 'ES11-000-000', 'ES11-000-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-007', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-008', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-009', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-010', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-011', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-012', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-013', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-014', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-015', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-016', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-017', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-018', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-019', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-020', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-021', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-022', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-023', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-031', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-032', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-033', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-034', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-035', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-036', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-037', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-038', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-039', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-040', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-041', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-042', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-043', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-044', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-045', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-046', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-047', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-048', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-049', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-050', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-051', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-052', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-053', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-061', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-062', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-063', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-064', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-065', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-066', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-067', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-068', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-069', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-070', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-071', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-072', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-073', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-074', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-075', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-076', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-077', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-078', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-079', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-080', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-081', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-082', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-083', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 12 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-000', 'ES12-000-000', 'ES12-000-000', 'Estacionamento 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-001', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-011', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-012', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-013', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-014', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-021', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-022', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-023', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-024', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 01 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-000', 'JA01-000-000', 'JA01-000-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-001', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-005', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-007', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-011', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-025', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-027', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-031', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-045', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-047', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-051', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-065', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-067', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 02 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-000', 'JA02-000-000', 'JA02-000-000', 'Jardim 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-001', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-011', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-021', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-031', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-041', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-051', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-061', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-071', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-081', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-091', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 03 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-000', 'JA03-000-000', 'JA03-000-000', 'Jardim 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-001', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-003', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-005', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-007', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-009', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-011', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-025', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-039', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-041', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 04 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-000', 'JA04-000-000', 'JA04-000-000', 'Jardim 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-001', 'JA04-TER-000', 'JA04-TER-000', 'Jardim 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-003', 'JA04-TER-000', 'JA04-TER-000', 'Jardim 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-005', 'JA04-TER-000', 'JA04-TER-000', 'Jardim 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-007', 'JA04-TER-000', 'JA04-TER-000', 'Jardim 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-009', 'JA04-TER-000', 'JA04-TER-000', 'Jardim 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 05 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-000', 'JA05-000-000', 'JA05-000-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-003', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-013', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-015', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-021', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-023', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-025', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-031', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-035', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-041', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-043', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-045', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 06 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-TER-000', 'JA06-000-000', 'JA06-000-000', 'Jardim 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-TER-001', 'JA06-TER-000', 'JA06-TER-000', 'Jardim 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-TER-003', 'JA06-TER-000', 'JA06-TER-000', 'Jardim 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-TER-005', 'JA06-TER-000', 'JA06-TER-000', 'Jardim 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-TER-007', 'JA06-TER-000', 'JA06-TER-000', 'Jardim 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 07 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-000', 'JA07-000-000', 'JA07-000-000', 'Jardim 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-001', 'JA07-TER-000', 'JA07-TER-000', 'Jardim 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-003', 'JA07-TER-000', 'JA07-TER-000', 'Jardim 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-005', 'JA07-TER-000', 'JA07-TER-000', 'Jardim 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-007', 'JA07-TER-000', 'JA07-TER-000', 'Jardim 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-009', 'JA07-TER-000', 'JA07-TER-000', 'Jardim 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 08 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-000', 'JA08-000-000', 'JA08-000-000', 'Jardim 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-001', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-003', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-005', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-007', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-009', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-011', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-013', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 09 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-000', 'JA09-000-000', 'JA09-000-000', 'Jardim 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-001', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-011', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-015', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-021', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-023', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-025', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 10 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-000', 'JA10-000-000', 'JA10-000-000', 'Jardim 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-001', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-003', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-005', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-007', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-009', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-011', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-013', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-015', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-017', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-019', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 11 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-000', 'JA11-000-000', 'JA11-000-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-001', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-003', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-005', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-007', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-009', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-011', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-021', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-023', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-025', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-027', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-029', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-031', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 12 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-000', 'JA12-000-000', 'JA12-000-000', 'Jardim 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-001', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-003', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-005', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-007', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-009', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-011', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-013', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 13 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-000', 'JA13-000-000', 'JA13-000-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-001', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-003', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-009', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-011', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-013', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-015', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-017', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-019', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-023', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-025', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-027', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 14 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-000', 'JA14-000-000', 'JA14-000-000', 'Jardim 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-001', 'JA14-TER-000', 'JA14-TER-000', 'Jardim 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-003', 'JA14-TER-000', 'JA14-TER-000', 'Jardim 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-005', 'JA14-TER-000', 'JA14-TER-000', 'Jardim 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-007', 'JA14-TER-000', 'JA14-TER-000', 'Jardim 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-009', 'JA14-TER-000', 'JA14-TER-000', 'Jardim 14 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 15 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-000', 'JA15-000-000', 'JA15-000-000', 'Jardim 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-001', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-003', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-005', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-015', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-021', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-025', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 16 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-TER-000', 'JA16-000-000', 'JA16-000-000', 'Jardim 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-TER-001', 'JA16-TER-000', 'JA16-TER-000', 'Jardim 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-TER-011', 'JA16-TER-000', 'JA16-TER-000', 'Jardim 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-TER-021', 'JA16-TER-000', 'JA16-TER-000', 'Jardim 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-TER-031', 'JA16-TER-000', 'JA16-TER-000', 'Jardim 16 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 17 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-TER-000', 'JA17-000-000', 'JA17-000-000', 'Jardim 17 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-TER-001', 'JA17-TER-000', 'JA17-TER-000', 'Jardim 17 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-TER-011', 'JA17-TER-000', 'JA17-TER-000', 'Jardim 17 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-TER-021', 'JA17-TER-000', 'JA17-TER-000', 'Jardim 17 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-TER-031', 'JA17-TER-000', 'JA17-TER-000', 'Jardim 17 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 18 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-000', 'JA18-000-000', 'JA18-000-000', 'Jardim 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-001', 'JA18-TER-000', 'JA18-TER-000', 'Jardim 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-007', 'JA18-TER-000', 'JA18-TER-000', 'Jardim 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-017', 'JA18-TER-000', 'JA18-TER-000', 'Jardim 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-027', 'JA18-TER-000', 'JA18-TER-000', 'Jardim 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-037', 'JA18-TER-000', 'JA18-TER-000', 'Jardim 18 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 01 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-000', 'VI01-000-000', 'VI01-000-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-001', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-002', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-003', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-004', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-005', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-013', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-014', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-015', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-016', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-017', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-018', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-019', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-020', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-021', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 02 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-000', 'VI02-000-000', 'VI02-000-000', 'Via interna 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-001', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-003', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-005', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-007', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-009', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-011', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 03 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-000', 'VI03-000-000', 'VI03-000-000', 'Via interna 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-001', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-003', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-005', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-007', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-009', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-011', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-013', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-031', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 04 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-000', 'VI04-000-000', 'VI04-000-000', 'Via interna 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-001', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-003', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-005', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-007', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-009', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-011', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-013', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-015', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-017', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-019', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 05 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-000', 'VI05-000-000', 'VI05-000-000', 'Via interna 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-001', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-003', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-005', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-007', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-009', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-011', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 06 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-000', 'VI06-000-000', 'VI06-000-000', 'Via interna 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-001', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-003', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-005', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-007', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-009', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-011', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 07 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-000', 'VI07-000-000', 'VI07-000-000', 'Via interna 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-001', 'VI07-TER-000', 'VI07-TER-000', 'Via interna 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-003', 'VI07-TER-000', 'VI07-TER-000', 'Via interna 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-005', 'VI07-TER-000', 'VI07-TER-000', 'Via interna 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-007', 'VI07-TER-000', 'VI07-TER-000', 'Via interna 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-011', 'VI07-TER-000', 'VI07-TER-000', 'Via interna 07 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 08 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-000', 'VI08-000-000', 'VI08-000-000', 'Via interna 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-001', 'VI08-TER-000', 'VI08-TER-000', 'Via interna 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-003', 'VI08-TER-000', 'VI08-TER-000', 'Via interna 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-005', 'VI08-TER-000', 'VI08-TER-000', 'Via interna 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-007', 'VI08-TER-000', 'VI08-TER-000', 'Via interna 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-009', 'VI08-TER-000', 'VI08-TER-000', 'Via interna 08 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 09 - Todos', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-000', 'VI09-000-000', 'VI09-000-000', 'Via interna 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-006', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-016', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-021', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-022', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-023', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-024', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-025', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-026', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-031', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento T�rreo', 'Descri��o do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');

insert into assets values ('ELET-00-0000', 'ELET-00-0000', 'CASF-000-000', 'Sistema el�trico', 'Engloba todos os quadros el�tricos, geradores e nobreaks do Senado Federal', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-ET-0000', 'ELET-00-0000', 'CASF-000-000', 'Esta��es Transformadoras', 'Engloba todas as esta��es transformadoras do Senado Federal', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-ET-0001', 'ELET-ET-0000', 'AT42-000-000', 'Esta��o Transformadora 01 - Blocos de Apoio', 'Capacidade X, Transformadores A, B, C', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-ET-0002', 'ELET-ET-0000', 'AT22-000-000', 'Esta��o Transformadora 02 - Gr�fica', 'Capacidade X, Transformadores A, B, C', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-ET-0003', 'ELET-ET-0000', 'AT03-000-000', 'Esta��o Transformadora 03 - Ed. Principal e Anexo 1', 'Capacidade X, Transformadores A, B, C', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-ET-0004', 'ELET-ET-0000', 'AT53-000-000', 'Esta��o Transformadora 04 - Setran', 'Capacidade X, Transformadores A, B, C', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-ET-0005', 'ELET-ET-0000', 'AT12-000-000', 'Esta��o Transformadora 05 - Anexo 2', 'Capacidade X, Transformadores A, B, C', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-TF-0001', 'ELET-ET-0001', 'AT42-000-000', 'Transformador 01 da ET 01', 'Capacidade Z, Tens�o Nominal V', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-TF-0002', 'ELET-ET-0001', 'AT42-000-000', 'Transformador 02 da ET 01', 'Capacidade Z, Tens�o Nominal V', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-TF-0003', 'ELET-ET-0002', 'AT22-000-000', 'Transformador 01 da ET 02', 'Capacidade Z, Tens�o Nominal V', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-TF-0004', 'ELET-ET-0002', 'AT22-000-000', 'Transformador 02 da ET 02', 'Capacidade Z, Tens�o Nominal V', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-TF-0005', 'ELET-ET-0003', 'AT03-000-000', 'Transformador 01 da ET 03', 'Capacidade Z, Tens�o Nominal V', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-TF-0006', 'ELET-ET-0003', 'AT03-000-000', 'Transformador 02 da ET 03', 'Capacidade Z, Tens�o Nominal V', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-TF-0007', 'ELET-ET-0004', 'AT53-000-000', 'Transformador 01 da ET 04', 'Capacidade Z, Tens�o Nominal V', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-TF-0008', 'ELET-ET-0004', 'AT53-000-000', 'Transformador 02 da ET 04', 'Capacidade Z, Tens�o Nominal V', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-TF-0009', 'ELET-ET-0005', 'AT12-000-000', 'Transformador 01 da ET 05', 'Capacidade Z, Tens�o Nominal V', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-TF-0010', 'ELET-ET-0005', 'AT12-000-000', 'Transformador 02 da ET 05', 'Capacidade Z, Tens�o Nominal V', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-QD-0001', 'ELET-TF-0002', 'BL14-P01-000', 'Quadro Geral de energia el�trica - Bloco 14 - Pavimento 01', 'Quadro de energia el�trica com 10 disjuntores de 80A', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-NB-0001', 'ELET-QD-0001', 'BL14-P01-046', 'No break - Sinfra', 'Nobreak com capacidade para XXXXX.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-QD-0002', 'ELET-NB-0001', 'BL14-P01-046', 'Quadro de energia el�trica - Sinfra', 'Quadro de energia el�trica com 20 disjuntores de 30A', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CA-0001', 'ELET-QD-0002', 'BL14-MEZ-043', 'Circuito de alimenta��o el�trica (tomadas) - COEMANT', 'Circuito el�trico para tomadas', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('MECN-SR-0001', 'MECN-SR-0001', 'CASF-000-000', 'Sistem de refrigera��o do Senado Federal', 'Sistem de refrigera��o do Senado Federal', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('MECN-CA-0001', 'MECN-SR-0001', 'CASF-000-000', 'Central de �gua Gelada - Blocos de Apoio', 'Capacidade de X BTUS. Alimenta todo o sistema de refrigera��o dos Blocos de Apoio', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('MECN-FC-0001', 'MECN-CA-0001', 'BL10-P01-003', 'Fancolete - DGER', 'Capacidade de X BTUS. ', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('MECN-CA-0002', 'MECN-SR-0001', 'AX02-000-000', 'Central de �gua Gelada - CM3', 'Capacidade de X BTUS. Alimenta todo o sistema de refrigera��o do Anexo I, Anexo II e Edif�cio Principal', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('MECN-FC-0002', 'MECN-CA-0002', 'AX01-P09-010', 'Fancolete - EDGER', 'Capacidade de X BTUS. ', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-QD-0003', 'ELET-TF-0006', 'BL14-P01-000', 'Quadro Geral de energia el�trica - Bloco 14 - Pavimento 01', 'Quadro de energia el�trica com 10 disjuntores de 80A', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-QD-0004', 'ELET-QD-0003', 'EDPR-P01-000', 'Quadro de energia el�trica - PRSECR', 'Quadro de energia el�trica com 20 disjuntores de 30A', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CI-0001', 'ELET-QD-0004', 'EDPR-P01-024', 'Circuito de ilumina��o - PRSECR', 'Circuito de ilumina��o com l�mpadas de xxxW.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('MECN-FC-0003', 'MECN-CA-0001', 'BL14-P01-043', 'Fancolete - COPROJ', 'Capacidade de X BTUS.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('MECN-FC-0004', 'MECN-CA-0001', 'BL14-MEZ-096', 'Fancolete - SINFRA', 'Capacidade de X BTUS.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('CIVL-HD-0001', 'CIVL-HD-0001', 'CASF-000-000', 'Sistema hidr�ulico do Senado Federal', 'Engloba todas as bombas, tubula��es, caixas d''�gua.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('CIVL-BM-0001', 'CIVL-HD-0001', 'BL10-P01-003', 'Bomba de esgoto pr�xima � DGER.', 'Pot�ncia xxxxx W.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('MECN-FC-0005', 'MECN-CA-0001', 'BL14-MEZ-043', 'Fancolete - SEMAC', 'Capacidade de X BTUS.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('MECN-FC-0006', 'MECN-CA-0001', 'BL14-MEZ-043', 'Fancolete - COEMANT', 'Capacidade de X BTUS.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('MECN-FC-0007', 'MECN-CA-0001', 'BL14-MEZ-046', 'Fancolete - SEAU', 'Capacidade de X BTUS.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CA-0002', 'ELET-QD-0002', 'BL14-MEZ-046', 'Circuito de alimenta��o el�trica (tomadas) - SEPLAG', 'Circuito el�trico para tomadas', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-NB-0002', 'ELET-TF-0003', 'AX01-000-000', 'No break - Almoxarifado', 'Nobreak com capacidade para XXXXX.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-NB-0003', 'ELET-TF-0004', 'AX02-000-000', 'No break - Almoxarifado', 'Nobreak com capacidade para XXXXX.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-NB-0004', 'ELET-TF-0005', 'EDPR-000-000', 'No break - Almoxarifado', 'Nobreak com capacidade para XXXXX.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CI-0002', 'ELET-QD-0002', 'BL14-MEZ-043', 'Circuito de ilumina��o - COEMANT', 'Circuito de ilumina��o com l�mpadas de xxxW.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CI-0003', 'ELET-QD-0002', 'BL14-P01-044', 'Circuito de ilumina��o - COPROJ', 'Circuito de ilumina��o com l�mpadas de xxxW.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CI-0004', 'ELET-QD-0002', 'BL14-MEZ-046', 'Circuito de ilumina��o - SEPLAG', 'Circuito de ilumina��o com l�mpadas de xxxW.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CI-0005', 'ELET-QD-0002', 'BL14-P01-043', 'Circuito de ilumina��o - COPRE', 'Circuito de ilumina��o com l�mpadas de xxxW.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CI-0006', 'ELET-QD-0002', 'BL14-MEZ-046', 'Circuito de ilumina��o - SEAU', 'Circuito de ilumina��o com l�mpadas de xxxW.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CI-0007', 'ELET-QD-0002', 'BL14-MEZ-096', 'Circuito de ilumina��o - SINFRA', 'Circuito de ilumina��o com l�mpadas de xxxW.', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CA-0003', 'ELET-QD-0002', 'BL14-P01-044', 'Circuito de alimenta��o el�trica (tomadas) - COPROJ', 'Circuito el�trico para tomadas', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CA-0004', 'ELET-QD-0002', 'BL14-P01-043', 'Circuito de alimenta��o el�trica (tomadas) - COPRE', 'Circuito el�trico para tomadas', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CA-0005', 'ELET-QD-0002', 'BL14-MEZ-046', 'Circuito de alimenta��o el�trica (tomadas) - SEAU', 'Circuito el�trico para tomadas', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CA-0006', 'ELET-QD-0002', 'BL14-MEZ-096', 'Circuito de alimenta��o el�trica (tomadas) - SINFRA', 'Circuito el�trico para tomadas', 'A', null, null, null, null, null, null, null, null);
insert into assets values ('ELET-CA-0007', 'ELET-TF-0005', 'AX02-AN1-070', 'Circuito de alimenta��o el�trica (tomadas) - CORTV', 'Circuito el�trico para tomadas', 'A', null, null, null, null, null, null, null, null);

insert into contracts values ('CT-2016-0134', '2016-09-23', null, '2016-09-23', 'Contrato de Compra de Energia Regulada - CCER - entre o SENADO FEDERAL e a CEB Distribui��o S/A, de energia el�trica para as unidades consumidoras de identifica��o n� 466.453-1; 491.042-7; 491.747-2; 491.750-2; 493.169-6; 605.120-0; 623.849-1; 675.051-6; 966.027-5 e 1.089.425-X.', 'CEB Distribui��o S.A.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/3842');
insert into contracts values ('CTA-2017-0119', '2017-12-29', null, '2017-12-29', 'Estabelecer as principais condi��es da presta��o e utiliza��o do servi�o p�blico de energia el�trica entre a CEB Distribui��o S.A e o SENADO FEDERAL, de acordo com as condi��es gerais de fornecimento de energia el�trica e demais regulamentos expedidos pela Ag�ncia Nacional de Energia El�trica - ANEEL - no fornecimento continuado de energia el�trica para as diversas Unidades Consumidoras do Senado Federal, durante o per�odo de 60 (sessenta) meses consecutivos.', 'CEB Distribui��o S.A.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/4306');
insert into contracts values ('TE-2017-0014', '2017-11-23', null, '2017-11-23', 'O Minist�rio de Estado do Planejamento, Desenvolvimento e Gest�o, atrav�s da Secretaria de Patrim�nio da Uni�o - MPDG/SPU - e a Presid�ncia do SENADO FEDERAL, no uso de suas atribui��es legais, resolvem celebrar a transfer�ncia ao Senado Federal, por meio de cess�o de uso, do im�vel de propriedade da Uni�o situado no Setor de Clubes Esportivos Sul - SCE/SUL - Trecho 3 - Lote 07 - Bras�lia - Distrito Federal.', 'N/A', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/4262');
insert into contracts values ('CT-2016-0165', '2016-12-19', null, '2016-12-19', 'Contrata��o de empresa prestadora, de forma cont�nua, dos servi�os p�blicos de abastecimento de �gua e esgotamento sanit�rio, a serem utilizados no Complexo Arquitet�nico do SENADO FEDERAL pela Companhia de Saneamento Ambiental do Distrito Federal - CAESB - durante o per�odo indeterminado de vig�ncia contratual.', 'CAESB - Companhia de Saneamento Ambiental do Distrito Federal', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/3931');
insert into contracts values ('CT-2014-0088', '2014-12-09', '2019-12-08', '2014-12-09', 'Contrata��o de empresa especializada para a presta��o de servi�os de manuten��o no Sistema de Gera��o de Energia El�trica de Emerg�ncia, do Complexo Arquitet�nico do SENADO FEDERAL, composto de 05 (cinco) grupos motores-geradores, movidos � �leo diesel, durante o per�odo de 36 (trinta e seis) meses consecutivos.', 'RCS Tecnologia Ltda.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/3095');
insert into contracts values ('CT-2016-110', '2016-08-25', '2021-08-24', '2016-08-25', 'Contrata��o de empresa especializada para a presta��o de servi�os continuados e sob demanda, referentes � opera��o e manuten��o preventiva e corretiva do Sistema El�trico do Complexo Arquitet�nico do SENADO FEDERAL, com opera��o de sistema informatizado de gerenciamento de manuten��o e suprimento de insumos necess�rios � execu��o dos servi�os, durante o per�odo de 36 (trinta e seis) meses consecutivos.', 'RCS Tecnologia Ltda.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/3769');
insert into contracts values ('CT-2017-0084', '2017-10-24', '2017-12-01', '2020-11-30', 'Contrata��o de empresa especializada para presta��o de servi�os continuados e sob demanda, referentes � opera��o, manuten��o preventiva e corretiva do Sistema Hidrossanit�rio em todo o Complexo Arquitet�nico do SENADO FEDERAL, incluindo a opera��o de sistema de controle de manuten��o informatizado, fornecimento de suprimentos, insumos e de m�o de obra necess�rios � plena execu��o dos servi�os, durante o per�odo de 36 (trinta e seis) meses consecutivos.', 'RCS Tecnologia Ltda.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/4298');



-- ceb_meters
-- ceb_meter_assets
-- ceb_bills
-- caesb_meters
-- caesb_meter_assets
-- caesb_bills

insert into departments values ('SF', 'SF', 'Senado Federal', true);
insert into departments values ('COMDIR', 'SF', 'COMISS�O DIRETORA', true);
insert into departments values ('PRVPRE', 'COMDIR', 'PRIMEIRA VICE-PRESID�NCIA', true);
insert into departments values ('SGVPRE', 'COMDIR', 'SEGUNDA VICE-PRESID�NCIA', true);
insert into departments values ('PRSECR', 'COMDIR', 'PRIMEIRA SECRETARIA', true);
insert into departments values ('SGSECR', 'COMDIR', 'SEGUNDA SECRETARIA', true);
insert into departments values ('TRSECR', 'COMDIR', 'TERCEIRA SECRETARIA', true);
insert into departments values ('QTSECR', 'COMDIR', 'QUARTA SECRETARIA', true);
insert into departments values ('PRSUPL', 'COMDIR', 'GABINETE DO PRIMEIRO SUPLENTE DE SECRET�RIO', true);
insert into departments values ('SGSUPL', 'COMDIR', 'GABINETE DO SEGUNDO SUPLENTE DE SECRET�RIO', true);
insert into departments values ('TRSUPL', 'COMDIR', 'GABINETE DO TERCEIRO SUPLENTE DE SECRET�RIO', true);
insert into departments values ('QTSUPL', 'COMDIR', 'GABINETE DO QUARTO SUPLENTE DE SECRET�RIO', true);
insert into departments values ('CEDIT', 'COMDIR', 'CONSELHO EDITORIAL', true);
insert into departments values ('CGCGE', 'COMDIR', 'COMIT� DE GOVERNAN�A CORPORATIVA E GEST�O ESTRAT�GICA', true);
insert into departments values ('COSILB', 'COMDIR', 'CONSELHO DE SUPERVIS�O DO ILB', true);
insert into departments values ('CSIS', 'COMDIR', 'CONSELHO DE SUPERVIS�O DO SISTEMA INTEGRADO DE SA�DE(SIS)', true);
insert into departments values ('PRESID', 'SF', 'PRESID�NCIA', true);
insert into departments values ('CEPRES', 'PRESID', 'CERIMONIAL DA PRESIDENCIA', true);
insert into departments values ('SECOEV', 'CEPRES', 'SERVI�O DE COORDENA��O DE EVENTOS', true);
insert into departments values ('SEPGPR', 'CEPRES', 'SERVI�O DE PLANEJAMENTO E GEST�O', true);
insert into departments values ('SERAGE', 'CEPRES', 'SERVI�O DE RECEP��O E AGENDA', true);
insert into departments values ('GBPRES', 'PRESID', 'GABINETE DA PRESID�NCIA', true);
insert into departments values ('ASIMP', 'PRESID', 'ASSESSORIA DE IMPRENSA DA PRESID�NCIA', true);
insert into departments values ('ASPRES', 'PRESID', 'ASSESSORIA T�CNICA DA PRESID�NCIA', true);
insert into departments values ('SERINT', 'PRESID', 'SECRETARIA DE RELA��ES INTERNACIONAIS DA PRESID�NCIA', true);
insert into departments values ('STRANS', 'PRESID', 'SECRETARIA DE TRANSPAR�NCIA', true);
insert into departments values ('ATSTRANS', 'STRANS', 'ASSESSORIA T�CNICA DA STRANS', true);
insert into departments values ('DATASEN', 'STRANS', 'INSTITUTO DE PESQUISA DATASENADO', true);
insert into departments values ('SEGS', 'DATASEN', 'SERVI�O DE GERENCIAMENTO DE SISTEMAS', true);
insert into departments values ('SEPEA', 'DATASEN', 'SERVI�O DE PESQUISA E AN�LISE', true);
insert into departments values ('OMV', 'DATASEN', 'OBSERVAT�RIO DA MULHER CONTRA A VIOL�NCIA', true);
insert into departments values ('DATJUR', 'PRESID', 'DIRETORIA DE ASSUNTOS T�CNICOS E JUR�DICOS', true);
insert into departments values ('GABSEN', 'SF', 'GABINETES DOS SENADORES', true);
insert into departments values ('GSAANAST', 'GABSEN', 'GABINETE DO SENADOR ANTONIO ANASTASIA', true);
insert into departments values ('E1AANAST', 'GSAANAST', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR ANTONIO ANASTASIA', true);
insert into departments values ('GSACORON', 'GABSEN', 'GABINETE DO SENADOR ANGELO CORONEL', true);
insert into departments values ('E1ACORON', 'GSACORON', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR ANGELO CORONEL', true);
insert into departments values ('GSADIA', 'GABSEN', 'GABINETE DO SENADOR ALVARO DIAS', true);
insert into departments values ('EAADIA', 'GSADIA', 'ESCRIT�RIO DE AP. N� 01 DO SENADOR ALVARO DIAS', true);
insert into departments values ('GSAGUR', 'GABSEN', 'GABINETE DO SENADOR ACIR GURGACZ', true);
insert into departments values ('EAAGUR', 'GSAGUR', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR ACIR GURGACZ', true);
insert into departments values ('GSAOLIVE', 'GABSEN', 'GABINETE DO SENADOR AROLDE DE OLIVEIRA', true);
insert into departments values ('E1AOLIVE', 'GSAOLIVE', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR AROLDE DE OLIVEIRA', true);
insert into departments values ('GSAVIEIR', 'GABSEN', 'GABINETE DO SENADOR ALESSANDRO VIEIRA', true);
insert into departments values ('E1AVIEIR', 'GSAVIEIR', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR ALESSANDRO VIEIRA', true);
insert into departments values ('GSCGOMES', 'GABSEN', 'GABINETE DO SENADOR CID GOMES', true);
insert into departments values ('E1CGOMES', 'GSCGOMES', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR CID GOMES', true);
insert into departments values ('GSCMOURA', 'GABSEN', 'GABINETE DO SENADOR CONF�CIO MOURA', true);
insert into departments values ('E1CMOURA', 'GSCMOURA', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR SENADOR CONF�CIO MOURA', true);
insert into departments values ('GSCNOG', 'GABSEN', 'GABINETE DO SENADOR CIRO NOGUEIRA', true);
insert into departments values ('E1CNOG', 'GSCNOG', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR CIRO NOGUEIRA', true);
insert into departments values ('GSCRODRI', 'GABSEN', 'GABINETE DO SENADOR CHICO RODRIGUES', true);
insert into departments values ('E1CRODRI', 'GSCRODRI', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR CHICO RODRIGUES', true);
insert into departments values ('GSCVIANA', 'GABSEN', 'GABINETE DO SENADOR CARLOS VIANA', true);
insert into departments values ('E1CVIANA', 'GSCVIANA', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR CARLOS VIANA', true);
insert into departments values ('GSDALCOL', 'GABSEN', 'GABINETE DO SENADOR DAVI ALCOLUMBRE', true);
insert into departments values ('E1DALCOL', 'GSDALCOL', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR DAVI ALCOLUMBRE', true);
insert into departments values ('GSDBERGE', 'GABSEN', 'GABINETE DO SENADOR D�RIO BERGER', true);
insert into departments values ('E1DBERGE', 'GSDBERGE', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR D�RIO BERGER', true);
insert into departments values ('GSDRIBEI', 'GABSEN', 'GABINETE DA SENADORA DANIELLA RIBEIRO', true);
insert into departments values ('E1DRIBEI', 'GSDRIBEI', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA DANIELLA RIBEIRO', true);
insert into departments values ('GSEAMI', 'GABSEN', 'GABINETE DO SENADOR ESPERIDI�O AMIN', true);
insert into departments values ('E1EAMI', 'GSEAMI', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR ESPERIDI�O AMIN', true);
insert into departments values ('GSEBRA', 'GABSEN', 'GABINETE DO SENADOR EDUARDO BRAGA', true);
insert into departments values ('E1EBRA', 'GSEBRA', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR EDUARDO BRAGA', true);
insert into departments values ('GSEFERRE', 'GABSEN', 'GABINETE DO SENADOR ELMANO F�RRER', true);
insert into departments values ('E1EFERRE', 'GSEFERRE', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR ELMANO F�RRER', true);
insert into departments values ('GSEGAMA', 'GABSEN', 'GABINETE DA SENADORA ELIZIANE GAMA', true);
insert into departments values ('E1EGAMA', 'GSEGAMA', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA ELIZIANE GAMA', true);
insert into departments values ('GSEGIRAO', 'GABSEN', 'GABINETE DO SENADOR EDUARDO GIR�O', true);
insert into departments values ('E1EGIRAO', 'GSEGIRAO', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR EDUARDO GIR�O', true);
insert into departments values ('GSFARN', 'GABSEN', 'GABINETE DO SENADOR FL�VIO ARNS', true);
insert into departments values ('EAFARN', 'GSFARN', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR FL�VIO ARNS', true);
insert into departments values ('GSFB', 'GABSEN', 'GABINETE DO SENADOR FL�VIO BOLSONARO', true);
insert into departments values ('E1FB', 'GSFB', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR FL�VIO BOLSONARO', true);
insert into departments values ('GSFCONTA', 'GABSEN', 'GABINETE DO SENADOR FABIANO CONTARATO', true);
insert into departments values ('E1FCONTA', 'GSFCONTA', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR FABIANO CONTARATO', true);
insert into departments values ('GSFERCOE', 'GABSEN', 'GABINETE DO SENADOR FERNANDO BEZERRA COELHO', true);
insert into departments values ('E1FERCOE', 'GSFERCOE', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR FERNANDO BEZERRA COELHO', true);
insert into departments values ('E2FERCOE', 'GSFERCOE', 'ESCRIT�RIO DE APOIO N� 02 DO SENADOR FERNANDO BEZERRA COELHO', true);
insert into departments values ('GSHCST', 'GABSEN', 'GABINETE DO SENADOR HUMBERTO COSTA', true);
insert into departments values ('E1HCST', 'GSHCST', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR HUMBERTO COSTA', true);
insert into departments values ('E2HCST', 'GSHCST', 'ESCRIT�RIO DE APOIO N� 02 DO SENADOR HUMBERTO COSTA', true);
insert into departments values ('GSIRAJA', 'GABSEN', 'GABINETE DO SENADOR IRAJ�', true);
insert into departments values ('E1IRAJA', 'GSIRAJA', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR IRAJ�', true);
insert into departments values ('GSIZALCI', 'GABSEN', 'GABINETE DO SENADOR IZALCI LUCAS', true);
insert into departments values ('E1IZALCI', 'GSIZALCI', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR IZALCI LUCAS', true);
insert into departments values ('GSJAYM', 'GABSEN', 'GABINETE DO SENADOR JAYME CAMPOS', true);
insert into departments values ('E1JAYM', 'GSJAYM', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR JAYME CAMPOS', true);
insert into departments values ('GSJBAR', 'GABSEN', 'GABINETE DO SENADOR JADER BARBALHO', true);
insert into departments values ('E1JBAR', 'GSJBAR', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR JADER BABALHO', true);
insert into departments values ('GSJKAJUR', 'GABSEN', 'GABINETE DO SENADOR JORGE KAJURU', true);
insert into departments values ('E1JKAJUR', 'GSJKAJUR', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR JORGE KAJURU', true);
insert into departments values ('GSJMAR', 'GABSEN', 'GABINETE DO SENADOR JOS� MARANH�O', true);
insert into departments values ('E1JMAR', 'GSJMAR', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR JOS� MARANH�O', true);
insert into departments values ('GSJMELLO', 'GABSEN', 'GABINETE DO SENADOR JORGINHO MELLO', true);
insert into departments values ('E1JMELLO', 'GSJMELLO', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR JORGINHO MELLO', true);
insert into departments values ('GSJPRAT', 'GABSEN', 'GABINETE DO SENADOR JEAN PAUL PRATES', true);
insert into departments values ('E1JPRAT', 'GSJPRAT', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR JEAN PAUL PRATES', true);
insert into departments values ('GSJSELMA', 'GABSEN', 'GABINETE DA SENADORA JU�ZA SELMA', true);
insert into departments values ('E1JSELMA', 'GSJSELMA', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA JU�ZA SELMA', true);
insert into departments values ('GSJSER', 'GABSEN', 'GABINETE DO SENADOR JOS� SERRA', true);
insert into departments values ('E1JSER', 'GSJSER', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR JOS� SERRA', true);
insert into departments values ('GSJVAS', 'GABSEN', 'GABINETE DO SENADOR JARBAS VASCONCELOS', true);
insert into departments values ('EAJVAS', 'GSJVAS', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR JARBAS VASCONCELOS', true);
insert into departments values ('GSJWAG', 'GABSEN', 'GABINETE DO SENADOR JAQUES WAGNER', true);
insert into departments values ('E1JWAG', 'GSJWAG', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR JAQUES WAGNER', true);
insert into departments values ('GSKAAB', 'GABSEN', 'GABINETE DA SENADORA K�TIA ABREU', true);
insert into departments values ('EAKAAB', 'GSKAAB', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA K�TIA ABREU', true);
insert into departments values ('E2KAAB', 'GSKAAB', 'ESCRIT�RIO DE APOIO N� 02 DA SENADORA K�TIA ABREU', true);
insert into departments values ('GSLBARRE', 'GABSEN', 'GABINETE DO SENADOR LUCAS BARRETO', true);
insert into departments values ('E1LBARRE', 'GSLBARRE', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR LUCAS BARRETO', true);
insert into departments values ('GSLCARM', 'GABSEN', 'GABINETE DO SENADOR LUIZ CARLOS DO CARMO', true);
insert into departments values ('E1LCARM', 'GSLCARM', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR LUIZ CARLOS DO CARMO', true);
insert into departments values ('GSLEILAB', 'GABSEN', 'GABINETE DA SENADORA LEILA BARROS', true);
insert into departments values ('E1LEILAB', 'GSLEILAB', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA LEILA BARROS', true);
insert into departments values ('GSLHEINZ', 'GABSEN', 'GABINETE DO SENADOR LUIS CARLOS HEINZE', true);
insert into departments values ('E1LHEINZ', 'GSLHEINZ', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR LUIS CARLOS HEINZE', true);
insert into departments values ('E2LHEINZ', 'GSLHEINZ', 'ESCRIT�RIO DE APOIO N� 02 DO SENADOR LUIS CARLOS HEINZE', true);
insert into departments values ('GSLMARTI', 'GABSEN', 'GABINETE DO SENADOR LASIER MARTINS', true);
insert into departments values ('E1LMARTI', 'GSLMARTI', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR LASIER MARTINS', true);
insert into departments values ('GSMALV', 'GABSEN', 'GABINETE DA SENADORA MARIA DO CARMO ALVES', true);
insert into departments values ('EAMALV', 'GSMALV', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA MARIA DO CARMO ALVES', true);
insert into departments values ('GSMBITTA', 'GABSEN', 'GABINETE DO SENADOR MARCIO BITTAR', true);
insert into departments values ('E1MBITTA', 'GSMBITTA', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR MARCIO BITTAR', true);
insert into departments values ('GSMCASTR', 'GABSEN', 'GABINETE DO SENADOR MARCELO CASTRO', true);
insert into departments values ('E1MCASTR', 'GSMCASTR', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR MARCELO CASTRO', true);
insert into departments values ('GSMGABRI', 'GABSEN', 'GABINETE DA SENADORA MARA GABRILLI', true);
insert into departments values ('E1MGABRI', 'GSMGABRI', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA MARA GABRILLI', true);
insert into departments values ('GSMGOM', 'GABSEN', 'GABINETE DA SENADORA MAILZA GOMES', true);
insert into departments values ('EAMGOM', 'GSMGOM', 'ESCRIT�RIO DE APOIO N�01 DA SENADORA MAILZA GOMES', true);
insert into departments values ('GSMJESUS', 'GABSEN', 'GABINETE DO SENADOR MECIAS DE JESUS', true);
insert into departments values ('E1MJESUS', 'GSMJESUS', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR MECIAS DE JESUS', true);
insert into departments values ('GSMROGER', 'GABSEN', 'GABINETE DO SENADOR MARCOS ROG�RIO', true);
insert into departments values ('E1MROGER', 'GSMROGER', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR MARCOS ROG�RIO', true);
insert into departments values ('GSMVAL', 'GABSEN', 'GABINETE DO SENADOR MARCOS DO VAL', true);
insert into departments values ('E1MVAL', 'GSMVAL', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR MARCOS DO VAL', true);
insert into departments values ('GSNTRAD', 'GABSEN', 'GABINETE DO SENADOR NELSINHO TRAD', true);
insert into departments values ('E1NTRAD', 'GSNTRAD', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR NELSINHO TRAD', true);
insert into departments values ('GSOALENC', 'GABSEN', 'GABINETE DO SENADOR OTTO ALENCAR', true);
insert into departments values ('E1OALENC', 'GSOALENC', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR OTTO ALENCAR', true);
insert into departments values ('GSOAZIZ', 'GABSEN', 'GABINETE DO SENADOR OMAR AZIZ', true);
insert into departments values ('E1OAZIZ', 'GSOAZIZ', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR OMAR AZIZ', true);
insert into departments values ('GSOGUIMA', 'GABSEN', 'GABINETE DO SENADOR ORIOVISTO GUIMAR�ES', true);
insert into departments values ('E1OGUIMA', 'GSOGUIMA', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR ORIOVISTO GUIMAR�ES', true);
insert into departments values ('GSOLIMPI', 'GABSEN', 'GABINETE DO SENADOR MAJOR OLIMPIO', true);
insert into departments values ('E1OLIMPI', 'GSOLIMPI', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR MAJOR OLIMPIO', true);
insert into departments values ('GSPAULOR', 'GABSEN', 'GABINETE DO SENADOR PAULO ROCHA', true);
insert into departments values ('E1PAULOR', 'GSPAULOR', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR PAULO ROCHA', true);
insert into departments values ('GSPPAI', 'GABSEN', 'GABINETE DO SENADOR PAULO PAIM', true);
insert into departments values ('EAPPAI', 'GSPPAI', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR PAULO PAIM', true);
insert into departments values ('GSPVALER', 'GABSEN', 'GABINETE DO SENADOR PL�NIO VAL�RIO', true);
insert into departments values ('E1PVALER', 'GSPVALER', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR PL�NIO VAL�RIO', true);
insert into departments values ('GSRBULH', 'GABSEN', 'GABINETE DA SENADORA RENILDE BULH�ES', true);
insert into departments values ('E1RBULH', 'GSRBULH', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA RENILDE BULH�ES', true);
insert into departments values ('GSRCAL', 'GABSEN', 'GABINETE DO SENADOR RENAN CALHEIROS', true);
insert into departments values ('EARCAL', 'GSRCAL', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR RENAN CALHEIROS', true);
insert into departments values ('GSRCUNHA', 'GABSEN', 'GABINETE DO SENADOR RODRIGO CUNHA', true);
insert into departments values ('E1RCUNHA', 'GSRCUNHA', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR RODRIGO CUNHA', true);
insert into departments values ('GSREGUFF', 'GABSEN', 'GABINETE DO SENADOR REGUFFE', true);
insert into departments values ('GSRFREIT', 'GABSEN', 'GABINETE DA SENADORA ROSE DE FREITAS', true);
insert into departments values ('E1RFREIT', 'GSRFREIT', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA ROSE DE FREITAS', true);
insert into departments values ('GSROMARI', 'GABSEN', 'GABINETE DO SENADOR ROM�RIO', true);
insert into departments values ('E1ROMARI', 'GSROMARI', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR ROM�RIO', true);
insert into departments values ('GSRPACHE', 'GABSEN', 'GABINETE DO SENADOR RODRIGO PACHECO', true);
insert into departments values ('E1RPACHE', 'GSRPACHE', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR RODRIGO PACHECO', true);
insert into departments values ('GSRROCHA', 'GABSEN', 'GABINETE DO SENADOR ROBERTO ROCHA', true);
insert into departments values ('E1RROCHA', 'GSRROCHA', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR ROBERTO ROCHA', true);
insert into departments values ('GSRROD', 'GABSEN', 'GABINETE DO SENADOR RANDOLFE RODRIGUES', true);
insert into departments values ('E1RROD', 'GSRROD', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR RANDOLFE RODRIGUES', true);
insert into departments values ('GSRSANT', 'GABSEN', 'GABINETE DO SENADOR ROG�RIO CARVALHO', true);
insert into departments values ('E1RSANT', 'GSRSANT', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR ROG�RIO CARVALHO', true);
insert into departments values ('GSSCAM', 'GABSEN', 'GABINETE DO SENADOR SIQUEIRA CAMPOS', true);
insert into departments values ('GSSCASTR', 'GABSEN', 'GABINETE DO SENADOR S�RGIO DE CASTRO', true);
insert into departments values ('E1SCASTR', 'GSSCASTR', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR S�RGIO DE CASTRO', true);
insert into departments values ('GSSPET', 'GABSEN', 'GABINETE DO SENADOR S�RGIO PETEC�O', true);
insert into departments values ('E1SPET', 'GSSPET', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR S�RGIO PETEC�O', true);
insert into departments values ('GSSTEBET', 'GABSEN', 'GABINETE DA SENADORA SIMONE TEBET', true);
insert into departments values ('E1STEBET', 'GSSTEBET', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA SIMONE TEBET', true);
insert into departments values ('GSSTHRON', 'GABSEN', 'GABINETE DA SENADORA SORAYA THRONICKE', true);
insert into departments values ('E1STHRON', 'GSSTHRON', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA SORAYA THRONICKE', true);
insert into departments values ('GSSTYVEN', 'GABSEN', 'GABINETE DO SENADOR STYVENSON VALENTIM', true);
insert into departments values ('E1STYVEN', 'GSSTYVEN', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR STYVENSON VALENTIM', true);
insert into departments values ('GSTJER', 'GABSEN', 'GABINETE DO SENADOR TASSO JEREISSATI', true);
insert into departments values ('EATJER', 'GSTJER', 'ESCRIT�RIO DE AP. N� 01 DO SENADOR TASSO JEREISSATI', true);
insert into departments values ('GSTMOTA', 'GABSEN', 'GABINETE DO SENADOR TELM�RIO MOTA', true);
insert into departments values ('E1TMOTA', 'GSTMOTA', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR TELM�RIO MOTA', true);
insert into departments values ('GSTPINTO', 'GABSEN', 'GABINETE DO SENADOR THIERES PINTO', true);
insert into departments values ('E1TPINTO', 'GSTPINTO', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR THIERES PINTO', true);
insert into departments values ('GSVANDER', 'GABSEN', 'GABINETE DO SENADOR VANDERLAN CARDOSO', true);
insert into departments values ('E1VANDER', 'GSVANDER', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR VANDERLAN CARDOSO', true);
insert into departments values ('GSVENEZI', 'GABSEN', 'GABINETE DO SENADOR VENEZIANO VITAL DO R�GO', true);
insert into departments values ('E1VENEZI', 'GSVENEZI', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR VENEZIANO VITAL R�GO', true);
insert into departments values ('GSWEVERT', 'GABSEN', 'GABINETE DO SENADOR WEVERTON ROCHA', true);
insert into departments values ('E1WEVERT', 'GSWEVERT', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR WEVERTON ROCHA', true);
insert into departments values ('GSWFAGUN', 'GABSEN', 'GABINETE DO SENADOR WELLINGTON FAGUNDES', true);
insert into departments values ('E1WFAGUN', 'GSWFAGUN', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR WELLINGTON FAGUNDES', true);
insert into departments values ('E2WFAGUN', 'GSWFAGUN', 'ESCRIT�RIO DE APOIO N� 02 DO SENADOR WELLINGTON FAGUNDES', true);
insert into departments values ('GSZMAIA', 'GABSEN', 'GABINETE DA SENADORA ZENAIDE MAIA', true);
insert into departments values ('E1ZMAIA', 'GSZMAIA', 'ESCRIT�RIO DE APOIO N� 01 DA SENADORA ZENAIDE MAIA', true);
insert into departments values ('GSZMARIN', 'GABSEN', 'GABINETE DO SENADOR ZEQUINHA MARINHO', true);
insert into departments values ('E1ZMARIN', 'GSZMARIN', 'ESCRIT�RIO DE APOIO N� 01 DO SENADOR ZEQUINHA MARINHO', true);
insert into departments values ('GABLID', 'SF', 'GABINETES DE LIDERAN�AS', true);
insert into departments values ('BLMCON', 'GABLID', 'BLOCO DA LIDERAN�A DA MINORIA NO CONGRESSO NACIONAL', true);
insert into departments values ('BLPP', 'GABLID', 'BLOCO PARLAMENTAR PSDB/PSL', true);
insert into departments values ('BLPRD', 'GABLID', 'BLOCO PARLAMENTAR DA RESIST�NCIA DEMOCR�TICA', true);
insert into departments values ('BLSENIND', 'GABLID', 'BLOCO PARLAMENTAR SENADO INDEPENDENTE', true);
insert into departments values ('BLUNIDB', 'GABLID', 'BLOCO PARLAMENTAR UNIDOS PELO BRASIL', true);
insert into departments values ('BLVANG', 'GABLID', 'BLOCO PARLAMENTAR VANGUARDA', true);
insert into departments values ('GLCID', 'GABLID', 'GABINETE DA LIDERAN�A DO CIDADANIA', true);
insert into departments values ('GLDEM', 'GABLID', 'GABINETE DA LIDERAN�A DOS DEMOCRATAS', true);
insert into departments values ('GLDGCN', 'GABLID', 'GABINETE DA LIDERAN�A DO GOVERNO NO CONGRESSO NACIONAL', true);
insert into departments values ('GLDGOV', 'GABLID', 'GABINETE DA LIDERAN�A DO GOVERNO', true);
insert into departments values ('GLDMAI', 'GABLID', 'GABINETE DA LIDERAN�A DO BLOCO DA MAIORIA', true);
insert into departments values ('GLDMIN', 'GABLID', 'GABINETE DA LIDERAN�A DO BLOCO DA MINORIA', true);
insert into departments values ('GLDPDT', 'GABLID', 'GABINETE DA LIDERAN�A DO PDT', true);
insert into departments values ('GLDPP', 'GABLID', 'GABINETE DA LIDERAN�A DO PARTIDO PROGRESSISTA', true);
insert into departments values ('GLDPR', 'GABLID', 'GABINETE DA LIDERAN�A DO PARTIDO DA REPUBLICA', true);
insert into departments values ('GLDPSB', 'GABLID', 'GABINETE DA LIDERAN�A DO PSB', true);
insert into departments values ('GLDPT', 'GABLID', 'GABINETE DA LIDERAN�A DO PT', true);
insert into departments values ('GLIDPSL', 'GABLID', 'GABINETE DA LIDERAN�A DO PSL', true);
insert into departments values ('GLMDB', 'GABLID', 'GABINETE DA LIDERAN�A DO MDB', true);
insert into departments values ('GLPL', 'GABLID', 'GABINETE DA LIDERAN�A DO PARTIDO LIBERAL', true);
insert into departments values ('GLPODEMOS', 'GABLID', 'GABINETE DA LIDERAN�A DO PODEMOS', true);
insert into departments values ('GLPPL', 'GABLID', 'GABINETE DA LIDERAN�A DO PPL', true);
insert into departments values ('GLPRB', 'GABLID', 'GABINETE DA LIDERAN�A DO PRB', true);
insert into departments values ('GLPROS', 'GABLID', 'GABINETE DA LIDERAN�A DO PARTIDO REPUBLICANO DA ORDEM SOCIAL � PROS', true);
insert into departments values ('GLPSC', 'GABLID', 'GABINETE DA LIDERAN�A DO PSC', true);
insert into departments values ('GLPSD', 'GABLID', 'GABINETE DA LIDERAN�A DO PSD', true);
insert into departments values ('GLPSDB', 'GABLID', 'GABINETE DA LIDERAN�A DO PSDB', true);
insert into departments values ('GLPV', 'GABLID', 'GABINETE DA LIDERAN�A DO PV', true);
insert into departments values ('GLREDE', 'GABLID', 'GABINETE DA LIDERAN�A DO REDE SUSTENTABILIDADE', true);
insert into departments values ('OSE', 'SF', '�RG�OS SUPERIORES DE EXECU��O', true);
insert into departments values ('DGER', 'OSE', 'DIRETORIA-GERAL', true);
insert into departments values ('GBDGER', 'DGER', 'GABINETE DA DIRETORIA GERAL', true);
insert into departments values ('SEADGR', 'GBDGER', 'SERVI�O DE APOIO ADMINISTRATIVO DO GBDGER', true);
insert into departments values ('EDGER', 'GBDGER', 'ESCRIT�RIO SETORIAL DE GEST�O DA DGER', true);
insert into departments values ('ASQUALOG', 'DGER', 'ASSESSORIA DE QUALIDADE DE ATENDIMENTO E LOG�STICA', true);
insert into departments values ('SEGEPAVI', 'ASQUALOG', 'SERVI�O DE GEST�O DE PASSAGENS A�REAS, PASSAPORTES E VISTOS', true);
insert into departments values ('SEQUALOG', 'ASQUALOG', 'SERVI�O DE APOIO ADMINISTRATIVO DA ASQUALOG', true);
insert into departments values ('ATDGER', 'DGER', 'ASSESSORIA T�CNICA DA DIRETORIA-GERAL', true);
insert into departments values ('PRDSTI', 'DGER', 'SECRETARIA DE TECNOLOGIA DA INFORMA��O PRODASEN', true);
insert into departments values ('GBPRD', 'PRDSTI', 'GABINETE ADMINISTRATIVO DO PRODASEN', true);
insert into departments values ('SACTI', 'PRDSTI', 'SERVI�O DE APOIO �S CONTRATA��ES DE TI', true);
insert into departments values ('COATEN', 'PRDSTI', 'COORDENA��O DE ATENDIMENTO', true);
insert into departments values ('SAEQUI', 'COATEN', 'SERVI�O DE ADMINISTRA��O DE EQUIPAMENTOS', true);
insert into departments values ('SEAATE', 'COATEN', 'SERVI�O DE APOIO ADMINISTRATIVO DA COATEN', true);
insert into departments values ('SEADMT', 'COATEN', 'SERVI�O DE ATENDIMENTO ADMINISTRATIVO', true);
insert into departments values ('SEARE', 'COATEN', 'SERVI�O DE ATENDIMENTO �S �REAS ESPECIAIS', true);
insert into departments values ('SEARP', 'COATEN', 'SERVI�O DE ATENDIMENTO REMOTO E PRESENCIAL', true);
insert into departments values ('SEATLE', 'COATEN', 'SERVI�O DE ATENDIMENTO LEGISLATIVO', true);
insert into departments values ('SEMOTI', 'COATEN', 'SERVI�O DE CONTROLE DE QUALIDADE E MONITORA��O DA PLATAFORMA DE TECNOLOGIA DA INFORMA��O', true);
insert into departments values ('SEPARL', 'COATEN', 'SERVI�O DE ATENDIMENTO PARLAMENTAR', true);
insert into departments values ('SERMAN', 'COATEN', 'SERVI�O DE RELACIONAMENTO COM MANTENEDORES', true);
insert into departments values ('COINTI', 'PRDSTI', 'COORDENA��O DE INFRAESTRUTURA DE TECNOLOGIA DA INFORMA��O', true);
insert into departments values ('SEAINT', 'COINTI', 'SERVI�O DE APOIO ADMINISTRATIVO DA COINTI', true);
insert into departments values ('SEINDC', 'COINTI', 'SERVI�O DE APOIO � INFRAESTRUTURA DE DATACENTER', true);
insert into departments values ('SEPRTI', 'COINTI', 'SERVI�O DE PRODU��O DA COINTI', true);
insert into departments values ('SESBD', 'COINTI', 'SERVI�O DE SUPORTE A BANCO DE DADOS', true);
insert into departments values ('SESIA', 'COINTI', 'SERVI�O DE SUPORTE � INFRAESTRUTURA DE APLICA��ES', true);
insert into departments values ('SESIER', 'COINTI', 'SERVI�O DE SUPORTE � INFRAESTRUTURA DE REDE', true);
insert into departments values ('SESIET', 'COINTI', 'SERVI�O DE SUPORTE � INFRAESTRUTURA E ESTA��ES DE TRABALHO', true);
insert into departments values ('SESSR', 'COINTI', 'SERVI�O DE SUPORTE A EQUIPAMENTOS SERVIDORES DE REDE', true);
insert into departments values ('SGMD', 'COINTI', 'SERVI�O DE GER�NCIA DE MUDAN�AS', true);
insert into departments values ('COLEP', 'PRDSTI', 'COORDENA��O DE INFORM�TICA LEGISLATIVA E PARLAMENTAR', true);
insert into departments values ('SEALEP', 'COLEP', 'SERVI�O DE APOIO ADMINISTRATIVO DA COLEP', true);
insert into departments values ('SECN', 'COLEP', 'SERVI�O DE SOLU��ES PARA O CONGRESSO NACIONAL', true);
insert into departments values ('SEDSVE', 'COLEP', 'SERVI�O DE DESENVOLVIMENTO DO SISTEMA DE VOTA��O ELETR�NICA', true);
insert into departments values ('SEGAB', 'COLEP', 'SERVI�O DE SOLU��ES PARA GABINETES PARLAMENTARES', true);
insert into departments values ('SELEJU', 'COLEP', 'SERVI�O DE SOLU��ES PARA INFORMA��O LEGISLATIVA E JUR�DICA', true);
insert into departments values ('SEPLE', 'COLEP', 'SERVI�O DE SOLU��ES PARA O PROCESSO LEGISLATIVO ELETR�NICO', true);
insert into departments values ('SESAP', 'COLEP', 'SERVI�O DE SOLU��ES PARA A ATIVIDADE PARLAMENTAR E CONSULTORIAS', true);
insert into departments values ('SESCOM', 'COLEP', 'SERVI�O DE SOLU��ES PARA AS COMISS�ES', true);
insert into departments values ('SESOF', 'COLEP', 'SERVI�O DE SOLU��ES PARA O OR�AMENTO E FISCALIZA��O', true);
insert into departments values ('SESPLE', 'COLEP', 'SERVI�O DE SOLU��ES PARA O PLEN�RIO', true);
insert into departments values ('COSTIC', 'PRDSTI', 'COORDENA��O DE SOLU��ES DE TECNOLOGIA DA INFORMA��O CORPORATIVA', true);
insert into departments values ('SEAIND', 'COSTIC', 'SERVI�O DE ARQUITETURA DA INFORMA��O E DESIGN', true);
insert into departments values ('SEATIC', 'COSTIC', 'SERVI�O DE APOIO ADMINISTRATIVO DA COSTIC', true);
insert into departments values ('SEIDIC', 'COSTIC', 'SERVI�O DE SOLU��ES PARA �REAS DE INFORMA��O, DOCUMENTA��O E COMUNICA��O SOCIAL', true);
insert into departments values ('SEPOR', 'COSTIC', 'SERVI�O DE SOLU��ES PARA PORTAIS', true);
insert into departments values ('SESADM', 'COSTIC', 'SERVI�O DE SOLU��ES PARA �REAS T�CNICAS E ADMINISTRATIVAS', true);
insert into departments values ('SESAS', 'COSTIC', 'SERVI�O DE SOLU��ES PARA �REAS DE ASSESSORAMENTO SUPERIOR', true);
insert into departments values ('SESIC', 'COSTIC', 'SERVI�O DE SOLU��ES DE INTELIG�NCIA CORPORATIVA', true);
insert into departments values ('SESOC', 'COSTIC', 'SERVI�O DE SOLU��ES CORPORATIVAS', true);
insert into departments values ('SESRH', 'COSTIC', 'SERVI�O DE SOLU��ES PARA �REA DE RECURSOS HUMANOS', true);
insert into departments values ('EPRD', 'PRDSTI', 'ESCRIT�RIO SETORIAL DE GEST�O DO PRODASEN', true);
insert into departments values ('NQPPPS', 'PRDSTI', 'N�CLEO DE QUALIDADE E PADRONIZA��O DE PROCESSOS E PRODUTOS DE SOFTWARE', true);
insert into departments values ('SADCON', 'DGER', 'SECRETARIA DE ADMINISTRA��O DE CONTRATA��ES', true);
insert into departments values ('COATC', 'SADCON', 'COORDENA��O DE APOIO T�CNICO A CONTRATA��ES', true);
insert into departments values ('SACT', 'COATC', 'SERVI�O DE APOIO A CONTRATA��ES EM TECNOLOGIA', true);
insert into departments values ('SEEDIT', 'COATC', 'SERVI�O DE ELABORA��O DE EDITAIS', true);
insert into departments values ('SEELAC', 'COATC', 'SERVI�O DE ELABORA��O DE CONTRATOS', true);
insert into departments values ('COCDIR', 'SADCON', 'COORDENA��O DE CONTRATA��ES DIRETAS', true);
insert into departments values ('SEECON', 'COCDIR', 'SERVI�O DE EXECU��O DE CONTRATOS', true);
insert into departments values ('SEEXCO', 'COCDIR', 'SERVI�O DE EXECU��O DE COMPRAS', true);
insert into departments values ('SEGREP', 'COCDIR', 'SERVI�O DE GERENCIAMENTO DE REGISTRO DE PRE�OS', true);
insert into departments values ('COCVAP', 'SADCON', 'COORDENA��O DE CONTROLE E VALIDA��O DE PROCESSOS', true);
insert into departments values ('SELESC', 'COCVAP', 'SERVI�O DE ELABORA��O DE ESTIMATIVA DE CUSTOS', true);
insert into departments values ('COPLAC', 'SADCON', 'COORDENA��O DE PLANEJAMENTO E CONTROLE DE CONTRATA��ES', true);
insert into departments values ('SECON', 'COPLAC', 'SERVI�O DE CONTRATOS', true);
insert into departments values ('SEINPE', 'COPLAC', 'SERVI�O DE INSTRU��O DE PENALIDADES', true);
insert into departments values ('SEPCO', 'COPLAC', 'SERVI�O DE PLANEJAMENTO E CONTROLE', true);
insert into departments values ('SIRC', 'COPLAC', 'SERVI�O DE INSTRU��O DE REAJUSTES CONTRATUAIS', true);
insert into departments values ('COPELI', 'SADCON', 'COMISS�O PERMANENTE DE LICITA��O', true);
insert into departments values ('SEACPL', 'COPELI', 'SERVI�O DE APOIO ADMINISTRATIVO DA COPELI', true);
insert into departments values ('SECADFOR', 'COPELI', 'SERVI�O DE CADASTRO DE FORNECEDORES', true);
insert into departments values ('SEINPLP', 'COPELI', 'SERVI�O DE INSTRU��O PROCESSUAL', true);
insert into departments values ('EDCON', 'SADCON', 'ESCRIT�RIO SETORIAL DE GEST�O DA SADCON', true);
insert into departments values ('SAFIN', 'DGER', 'SECRETARIA DE FINAN�AS, OR�AMENTO E CONTABILIDADE', true);
insert into departments values ('SEGCPA', 'SAFIN', 'SERVI�O DE GEST�O', true);
insert into departments values ('COEXECO', 'SAFIN', 'COORDENA��O DE EXECU��O OR�AMENT�RIA', true);
insert into departments values ('SERCOE', 'COEXECO', 'SERVI�O DE REVIS�O E CONTROLE DE EMPENHOS', true);
insert into departments values ('COEXEFI', 'SAFIN', 'COORDENA��O DE EXECU��O FINANCEIRA', true);
insert into departments values ('SEPADA', 'COEXEFI', 'SERVI�O DE PAGAMENTO DE DESPESAS ADMINISTRATIVAS', true);
insert into departments values ('SEPAF', 'COEXEFI', 'SERVI�O DE PAGAMENTO A FORNECEDORES', true);
insert into departments values ('SEPAFOL', 'COEXEFI', 'SERVI�O DE PAGAMENTO DA FOLHA DE PESSOAL', true);
insert into departments values ('CONTAB', 'SAFIN', 'COORDENA��O DE CONTABILIDADE', true);
insert into departments values ('SEACONF', 'CONTAB', 'SERVI�O DE AN�LISE DE CONFORMIDADE', true);
insert into departments values ('SECOB', 'CONTAB', 'SERVI�O DE COBRAN�A ADMINISTRATIVA', true);
insert into departments values ('SECONTA', 'CONTAB', 'SERVI�O DE CONTABILIDADE ANAL�TICA', true);
insert into departments values ('COPAC', 'SAFIN', 'COORDENA��O DE PLANEJAMENTO E ACOMPANHAMENTO OR�AMENT�RIO', true);
insert into departments values ('SEAOIG', 'COPAC', 'SERVI�O DE ACOMPANHAMENTO OR�AMENT�RIO E INFORMA��ES GERENCIAIS', true);
insert into departments values ('SEPEO', 'COPAC', 'SERVI�O DE PLANEJAMENTO E ESTUDOS OR�AMENT�RIOS', true);
insert into departments values ('ESAFIN', 'SAFIN', 'ESCRIT�RIO SETORIAL DE GEST�O DA SAFIN', true);
insert into departments values ('SEGP', 'DGER', 'SECRETARIA DE GEST�O DE PESSOAS', true);
insert into departments values ('GBSEGP', 'SEGP', 'GABINETE ADMINISTRATIVO DA SEGP', true);
insert into departments values ('NSTSF', 'GBSEGP', 'N�CLEO DE SERVIDORES EM TR�NSITO - SF', true);
insert into departments values ('SEACOMP', 'SEGP', 'SERVI�O DE APOIO A COMISS�ES PROCESSANTES', true);
insert into departments values ('SEARQP', 'SEGP', 'SERVI�O DE ARQUIVO DE PESSOAL', true);
insert into departments values ('SEATUS', 'SEGP', 'SERVI�O DE ATENDIMENTO AO USU�RIO', true);
insert into departments values ('SEPUGP', 'SEGP', 'SERVI�O DE PUBLICA��O DA SEGP', true);
insert into departments values ('SESTI', 'SEGP', 'SERVI�O DE SUPORTE EM TECNOLOGIA DA INFORMA��O', true);
insert into departments values ('COAPES', 'SEGP', 'COORDENA��O DE ADMINISTRA��O DE PESSOAL', true);
insert into departments values ('SEAPES', 'COAPES', 'SERVI�O DE APOIO ADMINISTRATIVO DA COAPES', true);
insert into departments values ('SEDDEV', 'COAPES', 'SERVI�O DE DIREITOS E DEVERES FUNCIONAIS', true);
insert into departments values ('SEFREQ', 'COAPES', 'SERVI�O DE CONTROLE DE FREQU�NCIA', true);
insert into departments values ('SEPCOM', 'COAPES', 'SERVI�O DE CADASTRO PARLAMENTAR E PESSOAL COMISSIONADO', true);
insert into departments values ('SERCOPE', 'COAPES', 'SERVI�O DE REGISTRO E CONTROLE DE PESSOAL EFETIVO', true);
insert into departments values ('SGEST', 'COAPES', 'SERVI�O DE GEST�O DE EST�GIOS', true);
insert into departments values ('NSASF', 'COAPES', 'N�CLEO DE SERVIDORES AFASTADOS - SF', true);
insert into departments values ('COASAS', 'SEGP', 'COORDENA��O DE ATEN��O � SA�DE DO SERVIDOR', true);
insert into departments values ('SEJM', 'COASAS', 'SERVI�O DE JUNTA M�DICA', true);
insert into departments values ('SEMEDE', 'COASAS', 'SERVI�O M�DICO DE EMERG�NCIA', true);
insert into departments values ('SESOQVT', 'COASAS', 'SERVI�O DE SA�DE OCUPACIONAL E QUALIDADE DE VIDA NO TRABALHO', true);
insert into departments values ('COASIS', 'SEGP', 'COORDENA��O DE AUTORIZA��O DO SIS', true);
insert into departments values ('COATREL', 'SEGP', 'COORDENA��O DE ATENDIMENTO E RELACIONAMENTO', true);
insert into departments values ('SEABEN', 'COATREL', 'SERVI�O DE ATENDIMENTO A BENEFICI�RIOS', true);
insert into departments values ('SECRER', 'COATREL', 'SERVI�O DE CREDENCIAMENTO E RELACIONAMENTO', true);
insert into departments values ('COBEP', 'SEGP', 'COORDENA��O DE BENEF�CIOS PREVIDENCI�RIOS', true);
insert into departments values ('SEAPOPE', 'COBEP', 'SERVI�O DE APOIO OPERACIONAL', true);
insert into departments values ('SEAPOS', 'COBEP', 'SERVI�O DE APOSENTADORIA DE SERVIDORES', true);
insert into departments values ('SECOPE', 'COBEP', 'SERVI�O DE CONCESS�O DE PENS�ES', true);
insert into departments values ('SEINF', 'COBEP', 'SERVI�O DE INSTRU��O E REGISTROS FUNCIONAIS', true);
insert into departments values ('SEIPRE', 'COBEP', 'SERVI�O DE CONTROLE E INFORMA��ES PREVIDENCI�RIAS', true);
insert into departments values ('SESPAR', 'COBEP', 'SERVI�O DE SEGURIDADE PARLAMENTAR', true);
insert into departments values ('COGEFI', 'SEGP', 'COORDENA��O DE GEST�O FINANCEIRA DO SIS', true);
insert into departments values ('SECOBR', 'COGEFI', 'SERVI�O DE COBRAN�A', true);
insert into departments values ('SEPASI', 'COGEFI', 'SERVI�O DE PAGAMENTO', true);
insert into departments values ('COPAG', 'SEGP', 'COORDENA��O DE PAGAMENTO DE PESSOAL', true);
insert into departments values ('SEACFP', 'COPAG', 'SERVI�O DE AN�LISE E CONFER�NCIA DA FOLHA DE PAGAMENTO', true);
insert into departments values ('SEAPAG', 'COPAG', 'SERVI�O DE APOIO ADMINISTRATIVO DA COPAG', true);
insert into departments values ('SECOCR', 'COPAG', 'SERVI�O DE CONSTITUI��O E COBRAN�A DE CR�DITOS REMUNERAT�RIOS', true);
insert into departments values ('SECONF', 'COPAG', 'SERVI�O DE CONSIGNA��ES FACULTATIVAS', true);
insert into departments values ('SEEFOL', 'COPAG', 'SERVI�O DE ELABORA��O DE FOLHA', true);
insert into departments values ('SEICAP', 'COPAG', 'SERVI�O DE INSTRU��O E C�LCULOS', true);
insert into departments values ('SEOTIS', 'COPAG', 'SERVI�O DE OBRIGA��ES TRIBUT�RIAS E INFORMA��ES SOCIAIS', true);
insert into departments values ('COPOPE', 'SEGP', 'COORDENA��O DE POL�TICAS DE PESSOAL', true);
insert into departments values ('SECODEPE', 'COPOPE', 'SERVI�O DE GEST�O DE COMPET�NCIAS, DESEMPENHO E POL�TICAS DE', true);
insert into departments values ('SEGCAS', 'COPOPE', 'SERVI�O DE GEST�O DE CARGOS, SAL�RIOS E SELE��O', true);
insert into departments values ('ESEGP', 'SEGP', 'ESCRIT�RIO SETORIAL DE GEST�O DA SEGP', true);
insert into departments values ('NAPOPD', 'SEGP', 'APOSENTADOS - PD', true);
insert into departments values ('NAPOSE', 'SEGP', 'APOSENTADOS - SEEP', true);
insert into departments values ('NAPOSF', 'SEGP', 'APOSENTADOS - SF', true);
insert into departments values ('NFALPD', 'SEGP', 'FALECIDOS - PD', true);
insert into departments values ('NFALSE', 'SEGP', 'FALECIDOS - SEEP', true);
insert into departments values ('NFALSF', 'SEGP', 'FALECIDOS - SF', true);
insert into departments values ('SEGRAF', 'DGER', 'SECRETARIA DE EDITORA��O E PUBLICA��ES', true);
insert into departments values ('GBGRAF', 'SEGRAF', 'GABINETE ADMINISTRATIVO DA SEGRAF', true);
insert into departments values ('SECFAT', 'SEGRAF', 'SERVI�O DE CONV�NIOS E FATURAMENTO', true);
insert into departments values ('SEDTI', 'SEGRAF', 'SERVI�O DE DESENVOLVIMENTO DE TI E ATUALIZA��O TECNOL�GICA', true);
insert into departments values ('COEDIT', 'SEGRAF', 'COORDENA��O DE EDI��ES T�CNICAS', true);
insert into departments values ('SEAEDI', 'COEDIT', 'SERVI�O DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SEDACERV', 'COEDIT', 'SERVI�O DE DISTRIBUI��O E CONTROLE DO ACERVO', true);
insert into departments values ('SELIVR', 'COEDIT', 'SERVI�O DE LIVRARIA', true);
insert into departments values ('SEMID', 'COEDIT', 'SERVI�O DE MULTIM�DIA', true);
insert into departments values ('SEPQS', 'COEDIT', 'SERVI�O DE PESQUISA DA COEDIT', true);
insert into departments values ('SEPUBT', 'COEDIT', 'SERVI�O DE PUBLICA��ES T�CNICO LEGISLATIVAS', true);
insert into departments values ('COGEP', 'SEGRAF', 'COORDENA��O DE GEST�O DA PRODU��O', true);
insert into departments values ('SAUSEP', 'COGEP', 'SERVI�O DE ATENDIMENTO AO USU�RIO', true);
insert into departments values ('SEAGEP', 'COGEP', 'SERVI�O DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SECOQU', 'COGEP', 'SERVI�O DE CONTROLE DE QUALIDADE', true);
insert into departments values ('SEEREM', 'COGEP', 'SERVI�O DE EXPEDI��O E REMESSA', true);
insert into departments values ('SEGING', 'COGEP', 'SERVI�O DE GEST�O DE INSUMOS GR�FICOS', true);
insert into departments values ('COIND', 'SEGRAF', 'COORDENA��O INDUSTRIAL', true);
insert into departments values ('SEACAB', 'COIND', 'SERVI�O DE ACABAMENTO', true);
insert into departments values ('SEACOI', 'COIND', 'SERVI�O DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SECPRO', 'COIND', 'SERVI�O DE CONTROLE DA PRODU��O', true);
insert into departments values ('SEFPRO', 'COIND', 'SERVI�O DE FORMATA��O E PROGRAMA��O VISUAL', true);
insert into departments values ('SEIB', 'COIND', 'SERVI�O DE IMPRESS�O EM BRAILLE', true);
insert into departments values ('SEID', 'COIND', 'SERVI�O DE IMPRESS�O DIGITAL', true);
insert into departments values ('SEIMOF', 'COIND', 'SERVI�O DE IMPRESS�O OFFSET', true);
insert into departments values ('SEMAIN', 'COIND', 'SERVI�O DE MANUTEN��O INDUSTRIAL', true);
insert into departments values ('SEPDIG', 'COIND', 'SERVI�O DE PROCESSAMENTO DIGITAL', true);
insert into departments values ('SEPIND', 'COIND', 'SERVI�O DE PROGRAMA��O INDUSTRIAL', true);
insert into departments values ('SEPUBL', 'COIND', 'SERVI�O DE PUBLICA��ES OFICIAIS', true);
insert into departments values ('SERVSO', 'COIND', 'SERVI�O DE REVIS�O', true);
insert into departments values ('EGRAF', 'SEGRAF', 'ESCRIT�RIO SETORIAL DE GEST�O DA SEGRAF', true);
insert into departments values ('SGIDOC', 'DGER', 'SECRETARIA DE GEST�O DE INFORMA��O E DOCUMENTA��O', true);
insert into departments values ('GBSGID', 'SGIDOC', 'GABINETE ADMINISTRATIVO DA SGIDOC', true);
insert into departments values ('SEADAJ', 'SGIDOC', 'SERVI�O DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SETRIN', 'SGIDOC', 'SERVI�O DE TRADU��O E INTERPRETA��O', true);
insert into departments values ('SICLAI', 'SGIDOC', 'SERVI�O DE INFORMA��O AO CIDAD�O', true);
insert into departments values ('COARQ', 'SGIDOC', 'COORDENA��O DE ARQUIVO', true);
insert into departments values ('SEAHIS', 'COARQ', 'SERVI�O DE ARQUIVO HIST�RICO', true);
insert into departments values ('SEALEG', 'COARQ', 'SERVI�O DE ARQUIVO LEGISLATIVO', true);
insert into departments values ('SEARAD', 'COARQ', 'SERVI�O DE ARQUIVO ADMINISTRATIVO', true);
insert into departments values ('SECPAC', 'COARQ', 'SERVI�O DE CONSERVA��O E PRESERVA��O DO ACERVO', true);
insert into departments values ('SECTA', 'COARQ', 'SERVI�O DE CONSULTORIA T�CNICA ARQUIV�STICA', true);
insert into departments values ('SEPESA', 'COARQ', 'SERVI�O DE PESQUISA E ATENDIMENTO AO USU�RIO', true);
insert into departments values ('SEPROELE', 'COARQ', 'SERVI�O DE PROCESSO ELETR�NICO', true);
insert into departments values ('SEPROT', 'COARQ', 'SERVI�O DE PROTOCOLO ADMINISTRATIVO', true);
insert into departments values ('SEQARQ', 'COARQ', 'SERVI�O DE APOIO ADMINISTRATIVO DA COARQ', true);
insert into departments values ('COBIB', 'SGIDOC', 'COORDENA��O DE BIBLIOTECA', true);
insert into departments values ('SEABIB', 'COBIB', 'SERVI�O DE APOIO ADMINISTRATIVO DA COBIB', true);
insert into departments values ('SEART', 'COBIB', 'SERVI�O DE PROCESSAMENTO DE ARTIGOS DE REVISTA', true);
insert into departments values ('SEBIBT', 'COBIB', 'SERVI�O DE BIBLIOTECA T�CNICA DE INFORM�TICA', true);
insert into departments values ('SEBID', 'COBIB', 'SERVI�O DE BIBLIOTECA DIGITAL', true);
insert into departments values ('SEDECO', 'COBIB', 'SERVI�O DE DESENVOLVIMENTO DE COLE��ES', true);
insert into departments values ('SEEMP', 'COBIB', 'SERVI�O DE EMPR�STIMO E DEVOLU��O DE MATERIAL BIBLIOGR�FICO', true);
insert into departments values ('SEGER', 'COBIB', 'SERVI�O DE GER�NCIA DA REDE VIRTUAL DE BIBLIOTECAS', true);
insert into departments values ('SEJOR', 'COBIB', 'SERVI�O DE PROCESSAMENTO DE JORNAIS', true);
insert into departments values ('SELIV', 'COBIB', 'SERVI�O DE PROCESSAMENTO DE LIVROS', true);
insert into departments values ('SEMACO', 'COBIB', 'SERVI�O DE MANUTEN��O E CONSERVA��O DO ACERVO', true);
insert into departments values ('SEPESP', 'COBIB', 'SERVI�O DE PESQUISA PARLAMENTAR', true);
insert into departments values ('SEPRIB', 'COBIB', 'SERVI�O DE PESQUISA E RECUPERA��O DE INFORMA��ES BIBLIOGR�FICAS', true);
insert into departments values ('SERCOR', 'COBIB', 'SERVI�O DE REGISTRO DE COLE��ES DE REVISTAS', true);
insert into departments values ('COMUS', 'SGIDOC', 'COORDENA��O DE MUSEU', true);
insert into departments values ('SEAAD', 'COMUS', 'SERVI�O DE APOIO DE ADMINISTRATIVO', true);
insert into departments values ('SEAGEC', 'COMUS', 'SERVI�O DE ATENDIMENTO E GEST�O DE ESPA�OS CULTURAIS', true);
insert into departments values ('SECPM', 'COMUS', 'SERVI�O DE CONSERVA��O E PRESERVA��O DO MUSEU', true);
insert into departments values ('SEECC', 'COMUS', 'SERVI�O DE EXPOSI��ES, CURADORIA E COMUNICA��O', true);
insert into departments values ('SEGAM', 'COMUS', 'SERVI�O DE GEST�O DE ACERVO MUSEOL�GICO', true);
insert into departments values ('ESGID', 'SGIDOC', 'ESCRIT�RIO SETORIAL DE GEST�O DA SGIDOC', true);
insert into departments values ('SINFRA', 'DGER', 'SECRETARIA DE INFRAESTRUTURA', true);
insert into departments values ('SEAU', 'SINFRA', 'SERVI�O DE ATENDIMENTO AO USU�RIO', true);
insert into departments values ('SEDACOPE', 'SINFRA', 'SERVI�O DE DIRETRIZES ARQUITET�NICAS PARA O PATRIM�NIO EDIFICADO', true);
insert into departments values ('SEORC', 'SINFRA', 'SERVI�O DE OR�AMENTOS', true);
insert into departments values ('COEMANT', 'SINFRA', 'COORDENA��O DE ENGENHARIA DE MANUTEN��O', true);
insert into departments values ('SEGEEN', 'COEMANT', 'SERVI�O DE GEST�O DE ENERGIA EL�TRICA', true);
insert into departments values ('SEMAC', 'COEMANT', 'SERVI�O DE MANUTEN��O CIVIL', true);
insert into departments values ('SEMAINST', 'COEMANT', 'SERVI�O DE MANUTEN��O DE INSTALA��ES', true);
insert into departments values ('SEMEL', 'COEMANT', 'SERVI�O DE MANUTEN��O ELETROMEC�NICA', true);
insert into departments values ('SEPLAG', 'COEMANT', 'SERVI�O DE PLANEJAMENTO E GEST�O', true);
insert into departments values ('COPRE', 'SINFRA', 'COORDENA��O DE PROJETOS E REFORMAS', true);
insert into departments values ('SEFIS', 'COPRE', 'SERVI�O DE FISCALIZA��O', true);
insert into departments values ('SEPINF', 'COPRE', 'SERVI�O DE PROJETOS DE INFRAESTRUTURA', true);
insert into departments values ('SEPROARQ', 'COPRE', 'SERVI�O DE PROJETOS DE ARQUITETURA', true);
insert into departments values ('COPROJ', 'SINFRA', 'COORDENA��O DE PROJETOS E OBRAS DE INFRAESTRUTURA', true);
insert into departments values ('EINFRA', 'SINFRA', 'ESCRIT�RIO SETORIAL DE GEST�O DA SINFRA', true);
insert into departments values ('SPATR', 'DGER', 'SECRETARIA DE PATRIM�NIO', true);
insert into departments values ('GBPATR', 'SPATR', 'GABINETE ADMINISTRATIVO DA SPATR', true);
insert into departments values ('SEAIM', 'SPATR', 'SERVI�O DE DOCUMENTA��O E ADMINISTRA��O DE IM�VEIS', true);
insert into departments values ('SECQEC', 'SPATR', 'SERVI�O DE CONTROLE DE QUALIDADE E ESPECIFICA��ES DE MATERIAIS E BENS COMUNS', true);
insert into departments values ('SECQEE', 'SPATR', 'SERVI�O DE CONTROLE DE QUALIDADE E ESPECIFICA��ES DE MATERIAIS E BENS ESPECIAIS', true);
insert into departments values ('COAPAT', 'SPATR', 'COORDENA��O DE ADMINISTRA��O PATRIMONIAL', true);
insert into departments values ('SEAPAT', 'COAPAT', 'SERVI�O DE APOIO ADMINISTRATIVO DA COAPAT', true);
insert into departments values ('SEINV', 'COAPAT', 'SERVI�O DE INVENT�RIOS', true);
insert into departments values ('SESIN', 'COAPAT', 'SERVI�O DE SINALIZA��O', true);
insert into departments values ('SETTP', 'COAPAT', 'SERVI�O DE TOMBAMENTO E DE TRANSFER�NCIAS PATRIMONIAIS', true);
insert into departments values ('COARO', 'SPATR', 'COORDENA��O DE ADMINISTRA��O DE RESID�NCIAS OFICIAIS', true);
insert into departments values ('SECMAN', 'COARO', 'SERVI�O DE CONSERVA��O E MANUTEN��O', true);
insert into departments values ('SEODIU', 'COARO', 'SERVI�O DE APOIO OPERACIONAL DIURNO', true);
insert into departments values ('SEONOT', 'COARO', 'SERVI�O DE APOIO OPERACIONAL NOTURNO', true);
insert into departments values ('COASAL', 'SPATR', 'COORDENA��O DE ADMINISTRA��O E SUPRIMENTO DE ALMOXARIFADOS', true);
insert into departments values ('SAINF', 'COASAL', 'SERVI�O DE ALMOXARIFADO DE INFORM�TICA', true);
insert into departments values ('SAPF', 'COASAL', 'SERVI�O DE ALMOXARIFADO DE PRODUTOS GR�FICOS', true);
insert into departments values ('SEALMX', 'COASAL', 'SERVI�O DE ADMINISTRA��O DE ALMOXARIFADOS', true);
insert into departments values ('SEASAL', 'COASAL', 'SERVI�O DE APOIO ADMINISTRATIVO DA COASAL', true);
insert into departments values ('SEPLSU', 'COASAL', 'SERVI�O DE PLANEJAMENTO E SUPRIMENTO DE BENS DE ALMOXARIFADOS', true);
insert into departments values ('COGER', 'SPATR', 'COORDENA��O DE SERVI�OS GERAIS', true);
insert into departments values ('SEAOP', 'COGER', 'SERVI�O DE ATENDIMENTO OPERACIONAL', true);
insert into departments values ('SECOLI', 'COGER', 'SERVI�O DE CONSERVA��O E LIMPEZA', true);
insert into departments values ('SEPOZE', 'COGER', 'SERVI�O DE PORTARIA E ZELADORIA', true);
insert into departments values ('SETRAN', 'COGER', 'SERVI�O DE TRANSPORTES', true);
insert into departments values ('COOTELE', 'SPATR', 'COORDENA��O DE TELECOMUNICA��ES', true);
insert into departments values ('SEALMAT', 'COOTELE', 'SERVI�O DE ALMOXARIFADO DE MATERIAL DE TELECOMUNICA��ES', true);
insert into departments values ('SECACD', 'COOTELE', 'SERVI�O CENTRAL DE ATENDIMENTO E CONTROLE DE DADOS T�CNICOS', true);
insert into departments values ('SECOMUT', 'COOTELE', 'SERVI�O DE COMUTA��O TELEF�NICA', true);
insert into departments values ('SEQUALI', 'COOTELE', 'SERVI�O DE APOIO ADMINISTRATIVO E CONTROLE DE QUALIDADE', true);
insert into departments values ('SERETE', 'COOTELE', 'SERVI�O DE REDE TELEF�NICA', true);
insert into departments values ('SETARIF', 'COOTELE', 'SERVI�O DE TARIFA��O', true);
insert into departments values ('SETEMO', 'COOTELE', 'SERVI�O DE TELECOMUNICA��ES M�VEIS', true);
insert into departments values ('SETIIN', 'COOTELE', 'SERVI�O DE TECNOLOGIA DA INFORMA��O', true);
insert into departments values ('EPATR', 'SPATR', 'ESCRIT�RIO SETORIAL DE GEST�O DA SPATR', true);
insert into departments values ('SPOL', 'DGER', 'SECRETARIA DE POL�CIA DO SENADO FEDERAL', true);
insert into departments values ('GBSPSF', 'SPOL', 'GABINETE ADMINISTRATIVO DA SPOL', true);
insert into departments values ('SECEAA', 'SPOL', 'SERVI�O CENTRAL DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SECOP', 'SPOL', 'SERVI�O DE CONTROLE OPERACIONAL', true);
insert into departments values ('SEINTE', 'SPOL', 'SERVI�O DE INTELIG�NCIA POLICIAL', true);
insert into departments values ('SEPOLI', 'SPOL', 'SERVI�O DE POLICIAMENTO', true);
insert into departments values ('SEPREV', 'SPOL', 'SERVI�O DE PREVEN��O DE ACIDENTES E SEGURAN�A DO TRABALHO', true);
insert into departments values ('COPINV', 'SPOL', 'COORDENA��O DE POL�CIA DE INVESTIGA��O', true);
insert into departments values ('SECART', 'COPINV', 'SERVI�O CARTOR�RIO', true);
insert into departments values ('SERINV', 'COPINV', 'SERVI�O DE INVESTIGA��ES', true);
insert into departments values ('SESTEC', 'COPINV', 'SERVI�O DE SUPORTE T�CNICO', true);
insert into departments values ('COPROT', 'SPOL', 'COORDENA��O DE PROTE��O A AUTORIDADES', true);
insert into departments values ('SEAERE', 'COPROT', 'SERVI�O DE APOIO AEROPORTU�RIO', true);
insert into departments values ('SEPDIGN', 'COPROT', 'SERVI�O DE PROTE��O DE DIGNIT�RIOS', true);
insert into departments values ('SEPPLEC', 'COPROT', 'SERVI�O DE PROTE��O DE PLEN�RIOS E COMISS�ES', true);
insert into departments values ('SEPPRES', 'COPROT', 'SERVI�O DE PROTE��O PRESIDENCIAL', true);
insert into departments values ('COSUP', 'SPOL', 'COORDENA��O DE SUPORTE �S ATIVIDADES POLICIAIS', true);
insert into departments values ('SECRED', 'COSUP', 'SERVI�O DE CREDENCIAMENTO', true);
insert into departments values ('SELOG', 'COSUP', 'SERVI�O DE LOG�STICA', true);
insert into departments values ('SESTIN', 'COSUP', 'SERVI�O DE SUPORTE EM TECNOLOGIA DA INFORMA��O', true);
insert into departments values ('SETRE', 'COSUP', 'SERVI�O DE TREINAMENTO E PROJETOS', true);
insert into departments values ('ESPSF', 'SPOL', 'ESCRIT�RIO SETORIAL DE GEST�O DA SPOL', true);
insert into departments values ('DIRECON', 'DGER', 'DIRETORIA-EXECUTIVA DE CONTRATA��ES', true);
insert into departments values ('SEINTP', 'DIRECON', 'SERVI�O DE INSTRU��O PROCESSUAL', true);
insert into departments values ('ASSETEC', 'DIRECON', 'ASSESSORIA T�CNICA', true);
insert into departments values ('ESGEST', 'DIRECON', 'ESCRIT�RIO SETORIAL DE GEST�O', true);
insert into departments values ('NGACTI', 'DIRECON', 'N�CLEO DE GEST�O E APOIO �S CONTRATA��ES DE TECNOLOGIA DA INFORMA��O', true);
insert into departments values ('NGCIC', 'DIRECON', 'N�CLEO DE GEST�O DE CONTRATOS DE INFRAESTRUTURA E COMUNICA��O', true);
insert into departments values ('NGCOT', 'DIRECON', 'N�CLEO DE GEST�O DE CONTRATOS DE TERCEIRIZA��O', true);
insert into departments values ('SEAGCO', 'NGCOT', 'SERVI�O DE APOIO ADMINISTRATIVO DA NGCOT', true);
insert into departments values ('DIREG', 'DGER', 'DIRETORIA-EXECUTIVA DE GEST�O', true);
insert into departments values ('ATEC', 'DIREG', 'ASSESSORIA T�CNICA', true);
insert into departments values ('ESEG', 'DIREG', 'ESCRIT�RIO SETORIAL DE GEST�O', true);
insert into departments values ('NCAS', 'DIREG', 'N�CLEO DE COORDENA��O DE A��ES SOCIOAMBIENTAIS', true);
insert into departments values ('EGOV', 'DGER', 'ESCRIT�RIO CORPORATIVO DE GOVERNAN�A E GEST�O ESTRAT�GICA', true);
insert into departments values ('SGM', 'OSE', 'SECRETARIA GERAL DA MESA', true);
insert into departments values ('GBSGME', 'SGM', 'GABINETE DA SECRETARIA GERAL DA MESA', true);
insert into departments values ('ATRSGM', 'SGM', 'ASSESSORIA T�CNICA', true);
insert into departments values ('SAOP', 'SGM', 'SECRETARIA DE APOIO A �RG�OS DO PARLAMENTO', true);
insert into departments values ('GBSAOP', 'SAOP', 'GABINETE ADMINISTRATIVO DA SAOP', true);
insert into departments values ('COAPOP', 'SAOP', 'COORDENA��O DE APOIO A �RG�OS DE PREMIA��ES', true);
insert into departments values ('SAPREMI', 'COAPOP', 'SERVI�O DE APOIO A PREMIA��ES', true);
insert into departments values ('COAPOT', 'SAOP', 'COORDENA��O DE APOIO A �RG�OS T�CNICOS', true);
insert into departments values ('SACCS', 'COAPOT', 'SERVI�O DE APOIO AO CONSELHO DE COMUNICA��O SOCIAL DO CONGRESSO NACIONAL', true);
insert into departments values ('SCOM', 'SGM', 'SECRETARIA DE COMISS�ES', true);
insert into departments values ('GBSCOM', 'SCOM', 'GABINETE ADMINISTRATIVO DA SECRETARIA DE COMISS�ES', true);
insert into departments values ('SEACOM', 'SCOM', 'SERVI�O DE APOIO OPERACIONAL �S COMISS�ES', true);
insert into departments values ('COAPEC', 'SCOM', 'COORDENA��O DE APOIO AO PROGRAMA E-CIDADANIA', true);
insert into departments values ('COCETI', 'SCOM', 'COORDENA��O DE COMISS�ES ESPECIAIS, TEMPOR�RIAS E PARLAMENTARES DE INQU�RITO', true);
insert into departments values ('COCM', 'SCOM', 'COORDENA��O DE COMISS�ES MISTAS', true);
insert into departments values ('SACCAI', 'COCM', 'SECRETARIA DE APOIO � COMISS�O MISTA DE CONTROLE DAS ATIVIDADES DE INTELIG�NCIA', true);
insert into departments values ('SACMCF', 'COCM', 'SECRETARIA DE APOIO � COMISS�O MISTA PERMANENTE DE REGULAMENTA��O E CONSOLIDA��O DA LEGISLA��O FEDERAL', true);
insert into departments values ('SACMCPLP', 'COCM', 'SECRETARIA DE APOIO � COMISS�O MISTA PERMANENTE DE ASSUNTOS', true);
insert into departments values ('SACMCVM', 'COCM', 'SECRETARIA DE APOIO � COMISS�O MISTA PERMANENTE DE COMBATE �', true);
insert into departments values ('SACMMC', 'COCM', 'SECRETARIA DE APOIO � COMISS�O MISTA PERMANENTE SOBRE MUDAN�AS', true);
insert into departments values ('COCPSF', 'SCOM', 'COORDENA��O DE COMISS�ES PERMANENTES DO SENADO FEDERAL', true);
insert into departments values ('SACAE', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE ASSUNTOS ECON�MICOS', true);
insert into departments values ('SACAS', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE ASSUNTOS SOCIAIS', true);
insert into departments values ('SACCJ', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE CONSTITUI��O, JUSTI�A E CIDADANIA', true);
insert into departments values ('SACCT', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE CI�NCIA, TECNOLOGIA, INOVA��O,', true);
insert into departments values ('SACDH', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE DIREITOS HUMANOS E LEGISLA��O', true);
insert into departments values ('SACDIR', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DIRETORA', true);
insert into departments values ('SACDR', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE DESENVOLVIMENTO REGIONAL E TURISMO', true);
insert into departments values ('SACE', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE EDUCA��O, CULTURA E ESPORTE', true);
insert into departments values ('SACIFR', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE SERVI�OS DE INFRAESTRUTURA', true);
insert into departments values ('SACMA', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE MEIO AMBIENTE', true);
insert into departments values ('SACRA', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE AGRICULTURA E REFORMA AGR�RIA', true);
insert into departments values ('SACRE', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE RELA��ES EXTERIORES E DEFESA NACIONAL', true);
insert into departments values ('SACTFC', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O DE TRANSPAR�NCIA, GOVERNAN�A,', true);
insert into departments values ('SAPCSF', 'COCPSF', 'SECRETARIA DE APOIO � COMISS�O SENADO DO FUTURO', true);
insert into departments values ('SEADI', 'SGM', 'SECRETARIA DE ATAS E DI�RIOS', true);
insert into departments values ('GBSEADI', 'SEADI', 'GABINETE ADMINISTRATIVO DA SEADI', true);
insert into departments values ('COELDI', 'SEADI', 'COORDENA��O DE ELABORA��O DE DI�RIOS', true);
insert into departments values ('SEELAD', 'COELDI', 'SERVI�O DE ELABORA��O DE DI�RIOS', true);
insert into departments values ('SERSAD', 'COELDI', 'SERVI�O DE REVIS�O DE SUM�RIOS, ATAS E DI�RIOS', true);
insert into departments values ('SESUMA', 'COELDI', 'SERVI�O DE ELABORA��O DE SUM�RIOS E ATAS', true);
insert into departments values ('CORTEL', 'SEADI', 'COORDENA��O DE REGISTROS E TEXTOS LEGISLATIVOS DE PLEN�RIOS', true);
insert into departments values ('SEPTEX', 'CORTEL', 'SERVI�O DE PROCESSAMENTO DE TEXTOS LEGISLATIVOS', true);
insert into departments values ('SERLEP', 'CORTEL', 'SERVI�O DE REGISTROS LEGISLATIVOS DE PLEN�RIOS', true);
insert into departments values ('SERTEP', 'CORTEL', 'SERVI�O DE REVIS�O DE REGISTROS E TEXTOS LEGISLATIVOS DE PLEN�RIOS', true);
insert into departments values ('SERERP', 'SGM', 'SECRETARIA DE REGISTRO E REDA��O PARLAMENTAR', true);
insert into departments values ('GBSERERP', 'SERERP', 'GABINETE ADMINISTRATIVO DA SERERP', true);
insert into departments values ('SEOPE', 'SERERP', 'SERVI�O DE APOIO OPERACIONAL', true);
insert into departments values ('SETAUD', 'SERERP', 'SERVI�O DE T�CNICA DE �UDIO', true);
insert into departments values ('CORCOM', 'SERERP', 'COORDENA��O DE REGISTRO EM COMISS�ES', true);
insert into departments values ('SEACO', 'CORCOM', 'SERVI�O DE APOIO �S ATIVIDADES EM COMISS�ES', true);
insert into departments values ('SERCOMIS', 'CORCOM', 'SERVI�O DE REGISTRO EM COMISS�ES', true);
insert into departments values ('SESUCOM', 'CORCOM', 'SERVI�O DE SUPERVIS�O DO REGISTRO EM COMISS�ES', true);
insert into departments values ('COREM', 'SERERP', 'COORDENA��O DE REDA��O E MONTAGEM', true);
insert into departments values ('SEREDA', 'COREM', 'SERVI�O DE REDA��O', true);
insert into departments values ('SERMON', 'COREM', 'SERVI�O DE MONTAGEM', true);
insert into departments values ('CORER', 'SERERP', 'COORDENA��O DE REVIS�O DE REGISTRO', true);
insert into departments values ('SERER', 'CORER', 'SERVI�O DE REVIS�O DE REGISTRO', true);
insert into departments values ('CORPLEN', 'SERERP', 'COORDENA��O DE REGISTRO EM PLEN�RIO', true);
insert into departments values ('SERPLEN', 'CORPLEN', 'SERVI�O DE REGISTRO EM PLEN�RIO', true);
insert into departments values ('SEXPE', 'SGM', 'SECRETARIA DE EXPEDIENTE', true);
insert into departments values ('GBSEXP', 'SEXPE', 'GABINETE ADMINISTRATIVO DA SEXPE', true);
insert into departments values ('COEMAT', 'SEXPE', 'COORDENA��O DE EXPEDI��O E ACOMPANHAMENTO DE MAT�RIAS LEGISLATIVAS', true);
insert into departments values ('SEAMAT', 'COEMAT', 'SERVI�O DE ACOMPANHAMENTO DE MAT�RIAS LEGISLATIVAS', true);
insert into departments values ('SEEXPED', 'COEMAT', 'SERVI�O DE EXPEDI��O', true);
insert into departments values ('COEXPO', 'SEXPE', 'COORDENA��O DE ELABORA��O DE EXPEDIENTES OFICIAIS', true);
insert into departments values ('SEDOCE', 'COEXPO', 'SERVI�O DE DOCUMENTA��O ELETR�NICA', true);
insert into departments values ('SEINPL', 'COEXPO', 'SERVI�O DE INSPE��O DOS PROCESSADOS LEGISLATIVOS', true);
insert into departments values ('SINFLEG', 'SGM', 'SECRETARIA DE INFORMA��O LEGISLATIVA', true);
insert into departments values ('SEAIL', 'SINFLEG', 'SERVI�O DE APOIO ADMINISTRATIVO', true);
insert into departments values ('COER', 'SINFLEG', 'COORDENA��O DE ESTAT�STICAS, PESQUISA E RELAT�RIOS LEGISLATIVOS', true);
insert into departments values ('SEPEL', 'COER', 'SERVI�O DE PESQUISA LEGISLATIVA', true);
insert into departments values ('SERAP', 'COER', 'SERVI�O DO RELAT�RIO DA PRESID�NCIA', true);
insert into departments values ('SEREL', 'COER', 'SERVI�O DE RELAT�RIOS MENSAIS E ESTAT�STICAS LEGISLATIVAS', true);
insert into departments values ('COPIL', 'SINFLEG', 'COORDENA��O DE PADRONIZA��O DA INFORMA��O LEGISLATIVA', true);
insert into departments values ('SEDAN', 'COPIL', 'SERVI�O DE ANAIS', true);
insert into departments values ('SEPRON', 'COPIL', 'SERVI�O DE TRATAMENTO DE PRONUNCIAMENTOS', true);
insert into departments values ('SESINO', 'COPIL', 'SERVI�O DE SINOPSE', true);
insert into departments values ('NMIL', 'SINFLEG', 'N�CLEO DE MODERNIZA��O DA INFORMA��O LEGISLATIVA', true);
insert into departments values ('SEGEPROL', 'NMIL', 'SERVI�O DE GEST�O DE PROCESSOS LEGISLATIVOS', true);
insert into departments values ('SEMOP', 'NMIL', 'SERVI�O DE MODERNIZA��O E PROJETOS', true);
insert into departments values ('SLCN', 'SGM', 'SECRETARIA LEGISLATIVA DO CONGRESSO NACIONAL', true);
insert into departments values ('GBADM', 'SLCN', 'GABINETE ADMINISTRATIVO', true);
insert into departments values ('COLECN', 'SLCN', 'COORDENA��O DAS MAT�RIAS LEGISLATIVAS DO CONGRESSO NACIONAL', true);
insert into departments values ('SECOLEG', 'COLECN', 'SERVI�O DE COLEGIADOS', true);
insert into departments values ('SEMORC', 'COLECN', 'SERVI�O DE MAT�RIAS OR�AMENT�RIAS', true);
insert into departments values ('CORDIACN', 'SLCN', 'COORDENA��O DA ORDEM DO DIA DO CONGRESSO NACIONAL', true);
insert into departments values ('SEMEPRO', 'CORDIACN', 'SERVI�O DE MEDIDAS PROVIS�RIAS', true);
insert into departments values ('SEVETOS', 'CORDIACN', 'SERVI�O DE VETOS', true);
insert into departments values ('SLSF', 'SGM', 'SECRETARIA LEGISLATIVA DO SENADO FEDERAL', true);
insert into departments values ('GBLSF', 'SLSF', 'GABINETE ADMINISTRATIVO', true);
insert into departments values ('COINTEL', 'SLSF', 'COORDENA��O DE INTELIG�NCIA LEGISLATIVA', true);
insert into departments values ('SEAPIL', 'COINTEL', 'SERVI�O DE AN�LISE E PRODU��O DE INFORMA��ES LEGISLATIVAS', true);
insert into departments values ('COMIL', 'SLSF', 'COORDENA��O DE MAT�RIAS E INSTRU��O LEGISLATIVA', true);
insert into departments values ('SEINLEG', 'COMIL', 'SERVI�O DE INSTRU��O LEGISLATIVA', true);
insert into departments values ('SEPME', 'COMIL', 'SERVI�O DE PREPARA��O DE MAT�RIAS E EXPEDIENTES', true);
insert into departments values ('COORD', 'SLSF', 'COORDENA��O DA ORDEM DO DIA', true);
insert into departments values ('SEAPLER', 'COORD', 'SERVI�O DE ACOMPANHAMENTO DE PLEN�RIO E REVIS�O', true);
insert into departments values ('SEPORD', 'COORD', 'SERVI�O DE PREPARA��O DA ORDEM DO DIA', true);
insert into departments values ('COALSGM', 'SGM', 'COORDENA��O DE APOIO LOG�STICO', true);
insert into departments values ('SEAPA', 'COALSGM', 'SERVI�O DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SEAPLEN', 'COALSGM', 'SERVI�O DE APOIO AO PLEN�RIO', true);
insert into departments values ('COAME', 'SGM', 'COORDENA��O DE APOIO � MESA', true);
insert into departments values ('CORELE', 'SGM', 'COORDENA��O DE REDA��O LEGISLATIVA', true);
insert into departments values ('COVESP', 'SGM', 'COORDENA��O DOS SISTEMAS DE VOTA��ES ELETR�NICAS E DE SONORIZA��O DE PLEN�RIOS', true);
insert into departments values ('SEAP', 'COVESP', 'SERVI�O DE OPERA��O DE �UDIO DE PLEN�RIOS', true);
insert into departments values ('SEMAAP', 'COVESP', 'SERVI�O DE MANUTEN��O E ATENDIMENTO AUDIOVISUAL DE PLEN�RIOS', true);
insert into departments values ('SESVE', 'COVESP', 'SERVI�O DE OPERA��O DO SISTEMA DE VOTA��ES ELETR�NICAS', true);
insert into departments values ('ESGM', 'SGM', 'ESCRIT�RIO SETORIAL DE GEST�O DA SGM', true);
insert into departments values ('OAS', 'SF', '�RG�OS DE ASSESSORAMENTO SUPERIOR', true);
insert into departments values ('CONLEG', 'OAS', 'CONSULTORIA LEGISLATIVA', true);
insert into departments values ('GBCLEG', 'CONLEG', 'GABINETE ADMINISTRATIVO DA CONLEG', true);
insert into departments values ('CONTEC', 'CONLEG', 'CONSELHO T�CNICO DA CONLEG', true);
insert into departments values ('ECOLEG', 'CONLEG', 'ESCRIT�RIO SETORIAL DE GEST�O DA CONLEG', true);
insert into departments values ('NALEG', 'CONLEG', 'N�CLEO DE ACOMPANHAMENTO LEGISLATIVO', true);
insert into departments values ('NDIR', 'CONLEG', 'N�CLEO DE DIREITO', true);
insert into departments values ('NDISC', 'CONLEG', 'N�CLEO DE DISCURSOS', true);
insert into departments values ('NECO', 'CONLEG', 'N�CLEO DE ECONOMIA', true);
insert into departments values ('NEPLEG', 'CONLEG', 'N�CLEO DE ESTUDOS E PESQUISAS DA CONSULTORIA LEGISLATIVA', true);
insert into departments values ('NSOC', 'CONLEG', 'N�CLEO SOCIAL', true);
insert into departments values ('NSTLEG', 'CONLEG', 'N�CLEO DE SUPORTE T�CNICO-LEGISLATIVO', true);
insert into departments values ('SEAPG', 'NSTLEG', 'SERVI�O DE APOIO GERENCIAL', true);
insert into departments values ('SEATCN', 'NSTLEG', 'SERVI�O DE APOIO T�CNICO DA CONLEG', true);
insert into departments values ('CONORF', 'OAS', 'CONSULTORIA DE OR�AMENTOS, FISCALIZA��O E CONTROLE', true);
insert into departments values ('GBCORF', 'CONORF', 'GABINETE ADMINISTRATIVO DA CONORF', true);
insert into departments values ('ECONOR', 'CONORF', 'ESCRIT�RIO SETORIAL DE GEST�O DA CONORF', true);
insert into departments values ('NGIOS', 'CONORF', 'N�CLEO DE SUPORTE T�CNICO, GEST�O DA INFORMA��O OR�AMENT�RIA E SIGA-BRASIL', true);
insert into departments values ('SEEOR�', 'NGIOS', 'SERVI�O DE PESQUISA E ACOMPANHAMENTO DA EXECU��O OR�AMENT�RIA', true);
insert into departments values ('SEPROR', 'NGIOS', 'SERVI�O DE APOIO AO PROCESSO OR�AMENT�RIO', true);
insert into departments values ('SESOR�', 'NGIOS', 'SERVI�O DE GEST�O DOS SISTEMAS OR�AMENT�RIOS', true);
insert into departments values ('NUCI', 'CONORF', 'N�CLEO DE EDUCA��O, CULTURA, CI�NCIA, TECNOLOGIA, INTEGRA��O NACIONAL E MEIO AMBIENTE', true);
insert into departments values ('NUCII', 'CONORF', 'N�CLEO DE INFRA-ESTRUTURA, PLANEJAMENTO E DESENVOLVIMENTO URBANO', true);
insert into departments values ('NUCIII', 'CONORF', 'N�CLEO DE FAZENDA E DESENVOLVIMENTO, AGRICULTURA E DESENVOLVIMENTO AGR�RIO', true);
insert into departments values ('NUCIV', 'CONORF', 'N�CLEO DE JUSTI�A E DEFESA, PREVID�NCIA E ASSIST�NCIA SOCIAL', true);
insert into departments values ('NUCV', 'CONORF', 'N�CLEO DE PODERES DO ESTADO E REPRESENTA��O E SA�DE', true);
insert into departments values ('ADVOSF', 'OAS', 'ADVOCACIA DO SENADO FEDERAL', true);
insert into departments values ('NASSET', 'ADVOSF', 'N�CLEO DE ASSESSORAMENTO E ESTUDOS T�CNICOS', true);
insert into departments values ('NATA', 'ADVOSF', 'N�CLEO DE APOIO T�CNICO ADMINISTRATIVO', true);
insert into departments values ('SEADV', 'NATA', 'SERVI�O DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SEEPESQ', 'NATA', 'SERVI�O DE EXECU��O E PESQUISA', true);
insert into departments values ('EADVOS', 'NATA', 'ESCRIT�RIO SETORIAL DE GEST�O DA ADVOSF', true);
insert into departments values ('NPADM', 'ADVOSF', 'N�CLEO DE PROCESSOS ADMINISTRATIVOS', true);
insert into departments values ('NPCONT', 'ADVOSF', 'N�CLEO DE PROCESSOS DE CONTRATA��ES', true);
insert into departments values ('NPJUD', 'ADVOSF', 'N�CLEO DE PROCESSOS JUDICIAIS', true);
insert into departments values ('AUDIT', 'OAS', 'AUDITORIA DO SENADO FEDERAL', true);
insert into departments values ('GBAUDIT', 'AUDIT', 'GABINETE ADMINISTRATIVO DA AUDIT', true);
insert into departments values ('COAUDCF', 'AUDIT', 'COORDENA��O DE AUDITORIA CONT�BIL E FINANCEIRA', true);
insert into departments values ('SEAUDCO', 'COAUDCF', 'SERVI�O DE AUDITORIA CONT�BIL', true);
insert into departments values ('SEAUDCT', 'COAUDCF', 'SERVI�O DE AUDITORIA DE CONTAS', true);
insert into departments values ('COAUDCON', 'AUDIT', 'COORDENA��O DE AUDITORIA DE CONTRATA��ES', true);
insert into departments values ('SEAUDCOT', 'COAUDCON', 'SERVI�O DE AUDITORIA DE CONFORMIDADE DE CONTRATA��ES', true);
insert into departments values ('SEAUDOPE', 'COAUDCON', 'SERVI�O DE AUDITORIA OPERACIONAL DE CONTRATA��ES', true);
insert into departments values ('COAUDGEP', 'AUDIT', 'COORDENA��O DE AUDITORIA DE GEST�O DE PESSOAS', true);
insert into departments values ('SEAUDAC', 'COAUDGEP', 'SERVI�O DE AUDITORIA DE ADMISS�ES E CONCESS�ES', true);
insert into departments values ('SEAUDGEP', 'COAUDGEP', 'SERVI�O DE AUDITORIA DE GEST�O DE PESSOAS', true);
insert into departments values ('COAUDTI', 'AUDIT', 'COORDENA��O DE AUDITORIA DE TECNOLOGIA DA INFORMA��O', true);
insert into departments values ('SEAUDGTI', 'COAUDTI', 'SERVI�O DE AUDITORIA DE GEST�O DE TECNOLOGIA DA INFORMA��O', true);
insert into departments values ('SEAUDOTI', 'COAUDTI', 'SERVI�O DE AUDITORIA DE OPERA��ES DE TECNOLOGIA DA INFORMA��O', true);
insert into departments values ('ESAUDIT', 'AUDIT', 'ESCRIT�RIO SETORIAL DE GEST�O DA AUDIT', true);
insert into departments values ('SECOM', 'OAS', 'SECRETARIA DE COMUNICA��O SOCIAL', true);
insert into departments values ('GBECOM', 'SECOM', 'GABINETE ADMINISTRATIVO DA SECOM', true);
insert into departments values ('SEADCO', 'GBECOM', 'SERVI�O DE APOIO ADMINISTRATIVO DA SECOM', true);
insert into departments values ('ASIMPRE', 'SECOM', 'ASSESSORIA DE IMPRENSA (SECOM)', true);
insert into departments values ('ATCOM', 'SECOM', 'ASSESSORIA T�CNICA', true);
insert into departments values ('SAJS', 'SECOM', 'SECRETARIA AG�NCIA E JORNAL DO SENADO', true);
insert into departments values ('SEAAJS', 'SAJS', 'SERVI�O DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SEARJS', 'SAJS', 'SERVI�O DE ARTE', true);
insert into departments values ('COBERT', 'SAJS', 'COORDENA��O DE COBERTURA', true);
insert into departments values ('SEAUDIO', 'COBERT', 'SERVI�O DE AUDIOVISUAL', true);
insert into departments values ('SEFOTO', 'COBERT', 'SERVI�O DE FOTOGRAFIA', true);
insert into departments values ('SEREPT', 'COBERT', 'SERVI�O DE REPORTAGEM', true);
insert into departments values ('COEDAJS', 'SAJS', 'COORDENA��O DE EDI��O', true);
insert into departments values ('SEIMPRE', 'COEDAJS', 'SERVI�O DE IMPRESSOS', true);
insert into departments values ('SEPN', 'COEDAJS', 'SERVI�O DE PORTAL DE NOT�CIAS', true);
insert into departments values ('SERCOQ', 'COEDAJS', 'SERVI�O DE REVIS�O E CONTROLE DE QUALIDADE', true);
insert into departments values ('COJORN', 'SAJS', 'COORDENA��O JORNAL DO SENADO', true);
insert into departments values ('SEC', 'SECOM', 'SECRETARIA DE ENGENHARIA DE COMUNICA��O', true);
insert into departments values ('SAENGC', 'SEC', 'SERVI�O DE APOIO ADMINISTRATIVO (SEC)', true);
insert into departments values ('CODM', 'SEC', 'COORDENA��O DE DOCUMENTA��O MULTIM�DIA', true);
insert into departments values ('SEDICO', 'CODM', 'SERVI�O DE DIFUS�O DE CONTE�DO', true);
insert into departments values ('SEIMUL', 'CODM', 'SERVI�O DE INFRAESTRUTURA E MANUTEN��O MULTIM�DIA', true);
insert into departments values ('SESDIG', 'CODM', 'SERVI�O DE DESENVOLVIMENTO E INTEGRA��O DE SISTEMAS DIGITAIS', true);
insert into departments values ('SETDIG', 'CODM', 'SERVI�O DE SUPORTE T�CNICO E DIGITALIZA��O', true);
insert into departments values ('COENGTVR', 'SEC', 'COORDENA��O DE ENGENHARIA DE TV E R�DIO', true);
insert into departments values ('SECONTE', 'COENGTVR', 'SERVI�O DE CONTROLE DE EQUIPAMENTOS', true);
insert into departments values ('SETETV', 'COENGTVR', 'SERVI�O T�CNICO DE TV', true);
insert into departments values ('SETRAD', 'COENGTVR', 'SERVI�O T�CNICO DA R�DIO', true);
insert into departments values ('CORTV', 'SEC', 'COORDENA��O DE TRANSMISS�O DE TV E R�DIO', true);
insert into departments values ('SEAMEL', 'CORTV', 'SERVI�O DE ALMOXARIFADO DE MATERIAL ELETR�NICO', true);
insert into departments values ('SEATEL', 'CORTV', 'SERVI�O DE ATENDIMENTO ELETR�NICO', true);
insert into departments values ('SEMATV', 'CORTV', 'SERVI�O DE MANUTEN��O DA REDE DE TV E R�DIO', true);
insert into departments values ('SETRAR', 'CORTV', 'SERVI�O DE TRANSMISS�O DE R�DIO', true);
insert into departments values ('SETTV', 'CORTV', 'SERVI�O DE TRANSMISS�O DE TV', true);
insert into departments values ('COTI', 'SEC', 'COORDENA��O DE TECNOLOGIA DA INFORMA��O', true);
insert into departments values ('SRPPM', 'SECOM', 'SECRETARIA DE RELA��ES P�BLICAS, PUBLICIDADE E MARKETING', true);
insert into departments values ('SARPSF', 'SRPPM', 'SERVI�O DE APOIO ADMINISTRATIVO (SRPPM)', true);
insert into departments values ('COGENV', 'SRPPM', 'COORDENA��O DE GEST�O DE EVENTOS', true);
insert into departments values ('SELEG', 'COGENV', 'SERVI�O DE EVENTOS LEGISLATIVOS E PROTOCOLARES', true);
insert into departments values ('SEVAD', 'COGENV', 'SERVI�O DE EVENTOS ADMINISTRATIVOS', true);
insert into departments values ('COMAP', 'SRPPM', 'COORDENA��O DE PUBLICIDADE E MARKETING', true);
insert into departments values ('SEMARK', 'COMAP', 'SERVI�O DE MARKETING', true);
insert into departments values ('SEPUP', 'COMAP', 'SERVI�O DE PUBLICIDADE E PROPAGANDA', true);
insert into departments values ('COVISITA', 'SRPPM', 'COORDENA��O DE VISITA��O INSTITUCIONAL E DE RELACIONAMENTO COM A COMUNIDADE', true);
insert into departments values ('SECOI', 'COVISITA', 'SERVI�O DE COOPERA��O INSTITUCIONAL', true);
insert into departments values ('SEVISI', 'COVISITA', 'SERVI�O DE VISITA INSTITUCIONAL', true);
insert into departments values ('SRSF', 'SECOM', 'SECRETARIA R�DIO SENADO', true);
insert into departments values ('SARSF', 'SRSF', 'SERVI�O DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SEMADI', 'SRSF', 'SERVI�O DE PROGRAMA��O E DIVULGA��O', true);
insert into departments values ('SERAG', 'SRSF', 'SERVI�O R�DIO AG�NCIA', true);
insert into departments values ('CORED', 'SRSF', 'COORDENA��O DE REDA��O', true);
insert into departments values ('SEPORE', 'CORED', 'SERVI�O DE PROGRAMA��O REGIONAL', true);
insert into departments values ('SEPROD', 'CORED', 'SERVI�O DE PRODU��O', true);
insert into departments values ('SEREPO', 'CORED', 'SERVI�O DE REPORTAGEM', true);
insert into departments values ('SERLOC', 'CORED', 'SERVI�O DE LOCU��O', true);
insert into departments values ('SEVOZ', 'CORED', 'SERVI�O DE EDI��O DA VOZ DO BRASIL', true);
insert into departments values ('STVSEN', 'SECOM', 'SECRETARIA TV SENADO', true);
insert into departments values ('COADTV', 'STVSEN', 'COORDENA��O ADMINISTRATIVA', true);
insert into departments values ('SEACER', 'COADTV', 'SERVI�O DE ACERVO', true);
insert into departments values ('SEOPER', 'COADTV', 'SERVI�O DE OPERA��O', true);
insert into departments values ('CONTV', 'STVSEN', 'COORDENA��O DE CONTE�DO', true);
insert into departments values ('SEDCT', 'CONTV', 'SERVI�O DE DOCUMENT�RIOS', true);
insert into departments values ('SEPJOR', 'CONTV', 'SERVI�O DE PROGRAMAS JORNAL�STICOS', true);
insert into departments values ('SEPRES', 'CONTV', 'SERVI�O DE PROJETOS ESPECIAIS', true);
insert into departments values ('SERTV', 'CONTV', 'SERVI�O DE REPORTAGEM DA SECRETARIA TV SENADO', true);
insert into departments values ('COPRTV', 'STVSEN', 'COORDENA��O DE PROGRAMA��O', true);
insert into departments values ('SEINT', 'COPRTV', 'SERVI�O DE INTERNET', true);
insert into departments values ('SEITPG', 'COPRTV', 'SERVI�O DE INTERPROGRAMAS', true);
insert into departments values ('SERMPR', 'COPRTV', 'SERVI�O DE MULTIPROGRAMA��O', true);
insert into departments values ('SEVIIN', 'COPRTV', 'SERVI�O DE VIVO E �NTEGRAS', true);
insert into departments values ('DJORN', 'SECOM', 'DIRETORIA DE JORNALISMO', true);
insert into departments values ('NINTRA', 'DJORN', 'N�CLEO DE INTRANET', true);
insert into departments values ('NMIDIAS', 'DJORN', 'N�CLEO DE M�DIAS SOCIAIS', true);
insert into departments values ('NPAUTAS', 'DJORN', 'N�CLEO DE PAUTAS INTEGRADAS', true);
insert into departments values ('NCONT', 'SECOM', 'N�CLEO DE CONTRATA��ES E CONTRATOS', true);
insert into departments values ('ESECOM', 'NCONT', 'ESCRIT�RIO SETORIAL DE GEST�O (SECOM)', true);
insert into departments values ('OSU', 'SF', '�RG�OS SUPERVISIONADOS', true);
insert into departments values ('ILB', 'OSU', 'INSTITUTO LEGISLATIVO BRASILEIRO', true);
insert into departments values ('DEXILB', 'ILB', 'DIRETORIA EXECUTIVA DO ILB', true);
insert into departments values ('GBILB', 'DEXILB', 'GABINETE ADMINISTRATIVO DA DEXILB', true);
insert into departments values ('SEAT', 'DEXILB', 'SERVI�O DE APOIO T�CNICO', true);
insert into departments values ('COADFI', 'DEXILB', 'COORDENA��O ADMINISTRATIVA E FINANCEIRA', true);
insert into departments values ('SCCO', 'COADFI', 'SERVI�O DE CONTRATOS E CONV�NIOS', true);
insert into departments values ('SEACOA', 'COADFI', 'SERVI�O DE APOIO ADMINISTRATIVO DA COADFI', true);
insert into departments values ('SEPLAF', 'COADFI', 'SERVI�O DE PLANEJAMENTO E ACOMPANHAMENTO FINANCEIRO', true);
insert into departments values ('COESUP', 'DEXILB', 'COORDENA��O DE EDUCA��O SUPERIOR', true);
insert into departments values ('SEFOPEE', 'COESUP', 'SERVI�O DE FOMENTO � PESQUISA E EXTENS�O', true);
insert into departments values ('SEPOS', 'COESUP', 'SERVI�O DOS CURSOS DE P�S-GRADUA��O', true);
insert into departments values ('SESEA', 'COESUP', 'SERVI�O DE SECRETARIADO ACAD�MICO', true);
insert into departments values ('COPERI', 'DEXILB', 'COORDENA��O DE PLANEJAMENTO E RELA��ES INSTITUCIONAIS', true);
insert into departments values ('SACL', 'COPERI', 'SERVI�O DE ATENDIMENTO � COMUNIDADE DO LEGISLATIVO', true);
insert into departments values ('SFCO', 'COPERI', 'SERVI�O DE FORMA��O DA COMUNIDADE', true);
insert into departments values ('SIDV', 'COPERI', 'SERVI�O DE INFORMA��O E DIVULGA��O', true);
insert into departments values ('SPAC', 'COPERI', 'SERVI�O DE PLANEJAMENTO E ACOMPANHAMENTO DA COMUNIDADE', true);
insert into departments values ('SPPE', 'COPERI', 'SERVI�O DE PLANEJAMENTO E PROJETOS ESPECIAIS', true);
insert into departments values ('COTIN', 'DEXILB', 'COORDENA��O DE TECNOLOGIA DA INFORMA��O', true);
insert into departments values ('SEIT', 'COTIN', 'SERVI�O DE INFRAESTRUTURA TECNOL�GICA', true);
insert into departments values ('SPDT', 'COTIN', 'SERVI�O DE PESQUISA E DESENVOLVIMENTO TECNOL�GICO', true);
insert into departments values ('COTREN', 'DEXILB', 'COORDENA��O DE CAPACITA��O, TREINAMENTO E ENSINO', true);
insert into departments values ('SEED', 'COTREN', 'SERVI�O DE ENSINO � DIST�NCIA', true);
insert into departments values ('SETREINA', 'COTREN', 'SERVI�O DE TREINAMENTO', true);
insert into departments values ('EILB', 'DEXILB', 'ESCRIT�RIO SETORIAL DE GEST�O DO ILB', true);
insert into departments values ('COCIPE', 'ILB', 'COMIT� CIENT�FICO-PEDAG�GICO', true);
insert into departments values ('COMPER', 'SF', 'COMISS�ES PARLAMENTARES PERMANENTES', true);
insert into departments values ('CAE', 'COMPER', 'COMISS�O DE ASSUNTOS ECON�MICOS', true);
insert into departments values ('CAS', 'COMPER', 'COMISS�O DE ASSUNTOS SOCIAIS', true);
insert into departments values ('CCJ', 'COMPER', 'COMISS�O DE CONSTITUI��O, JUSTI�A E CIDADANIA', true);
insert into departments values ('CCT', 'COMPER', 'COMISS�O DE CI�NCIA, TECNOLOGIA, INOVA��O, COMUNICA��O E INFORM�TICA', true);
insert into departments values ('CDH', 'COMPER', 'COMISS�O DE DIREITOS HUMANOS E LEGISLA��O PARTICIPATIVA', true);
insert into departments values ('CDR', 'COMPER', 'COMISS�O DE DESENVOLVIMENTO REGIONAL E TURISMO', true);
insert into departments values ('CE', 'COMPER', 'COMISS�O DE EDUCA��O, CULTURA E ESPORTE', true);
insert into departments values ('CI', 'COMPER', 'COMISS�O DE SERVI�OS DE INFRAESTRUTURA', true);
insert into departments values ('CMA', 'COMPER', 'COMISS�O DE MEIO AMBIENTE', true);
insert into departments values ('CRA', 'COMPER', 'COMISS�O DE AGRICULTURA E REFORMA AGR�RIA', true);
insert into departments values ('CRE', 'COMPER', 'COMISS�O DE RELA��ES EXTERIORES', true);
insert into departments values ('CTFC', 'COMPER', 'COMISS�O DE TRANSPAR�NCIA, GOVERNAN�A, FISCALIZA��O E CONTROLE E DEFESA DO CONSUMIDOR', true);
insert into departments values ('PROPAR', 'SF', 'PROCURADORIA PARLAMENTAR', true);
insert into departments values ('CORREG', 'SF', 'CORREGEDORIA PARLAMENTAR', true);
insert into departments values ('CEDP', 'SF', 'CONSELHO DE �TICA E DECORO PARLAMENTAR', true);
insert into departments values ('CCINCL', 'SF', 'CONSELHO DA COMENDA DE INCENTIVO � CULTURA LU�S DA C�MARA CASCUDO', true);
insert into departments values ('CCOMESP', 'SF', 'CONSELHO DA COMENDA DO M�RITO ESPORTIVO', true);
insert into departments values ('CCOMFACF', 'SF', 'CONSELHO DA COMENDA DO M�RITO FUTEBOL�STICO ASSOCIA��O CHAPECOENSE DE FUTEBOL', true);
insert into departments values ('CCOMZA', 'SF', 'CONSELHO DA COMENDA ZILDA ARNS', true);
insert into departments values ('CCONIMS', 'SF', 'CONSELHO DA COMENDA NISE MAGALH�ES DA SILVEIRA', true);
insert into departments values ('CDBL', 'SF', 'CONSELHO DO DIPLOMA BERTHA LUTZ', true);
insert into departments values ('CDGN', 'SF', 'CONSELHO DA COMENDA DORINA DE GOUV�A NOWILL', true);
insert into departments values ('CDHC', 'SF', 'CONSELHO DA COMENDA DE DIREITOS HUMANOS DOM H�LDER C�MARA', true);
insert into departments values ('CEPSF', 'SF', 'CONSELHO DE ESTUDOS POL�TICOS DO SENADO FEDERAL', true);
insert into departments values ('CPREJE', 'SF', 'CONSELHO DO PR�MIO JOVEM EMPREENDEDOR', true);
insert into departments values ('CSAN', 'SF', 'CONSELHO DA COMENDA SENADOR ABDIAS NASCIMENTO', true);
insert into departments values ('DJEM', 'SF', 'CONSELHO DO DIPLOMA JOS� ERM�RIO DE MORAES', true);
insert into departments values ('IFI', 'SF', 'INSTITUI��O FISCAL INDEPENDENTE', true);
insert into departments values ('OUVIDSF', 'SF', 'OUVIDORIA DO SENADO FEDERAL', true);
insert into departments values ('CORCID', 'OUVIDSF', 'COORDENA��O DE RELACIONAMENTO COM O CIDAD�O', true);
insert into departments values ('SEALOS', 'CORCID', 'SERVI�O DE RELACIONAMENTO P�BLICO AL� SENADO', true);
insert into departments values ('SEAPCO', 'CORCID', 'SERVI�O DE APOIO ADMINISTRATIVO DA CORCID', true);
insert into departments values ('PJRM', 'SF', 'CONSELHO DO PR�MIO JORNALISTA ROBERTO MARINHO DE M�RITO JORNAL�STICO', true);
insert into departments values ('PJS', 'SF', 'CONSELHO DO PROJETO JOVEM SENADOR', true);
insert into departments values ('PMA', 'SF', 'CONSELHO DO PR�MIO M�RITO AMBIENTAL', true);
insert into departments values ('PROMUL', 'SF', 'PROCURADORIA ESPECIAL DA MULHER', true);
insert into departments values ('PSFHB', 'SF', 'CONSELHO DO PR�MIO SENADO FEDERAL DE HIST�RIA DO BRASIL', true);
insert into departments values ('RPBMER', 'SF', 'REPRESENTA��O BRASILEIRA NO PARLAMENTO DO MERCOSUL', true);
insert into departments values ('CCS', 'SF', 'CONSELHO DE COMUNICA��O SOCIAL', true);
insert into departments values ('COCN', 'SF', 'CONSELHO DA ORDEM DO CONGRESSO NACIONAL', true);
insert into departments values ('CMCF', 'COCN', 'COMISS�O MISTA PERMANENTE DE REGULAMENTA��O E CONSOLIDA��O DA LEGISLA��O FEDERAL', true);
insert into departments values ('CMCPLP', 'COCN', 'COMISS�O MISTA DO CONGRESSO NACIONAL DE ASSUNTOS RELACIONADOS � COMUNIDADE DOS PA�SES DE L�NGUA PORTUGUESA', true);
insert into departments values ('CMCVM', 'COCN', 'COMISS�O PERMANENTE MISTA DE COMBATE � VIOL�NCIA CONTRA A MULHER', true);
insert into departments values ('CMMC', 'COCN', 'COMISS�O MISTA PERMANENTE SOBRE MUDAN�AS CLIM�TICAS', true);
insert into departments values ('CMO', 'COCN', 'COMISS�O MISTA DE PLANOS, OR�AMENTOS P�BLICOS E FISCALIZA��O', true);
insert into departments values ('DMEDR', 'SF', 'CONSELHO DO DIPLOMA DO M�RITO EDUCATIVO DARCY RIBEIRO', true);
insert into departments values ('GLMAICN', 'SF', 'GABINETE DA LIDERAN�A DO BLOCO DA MAIORIA NO CONGRESSO NACIONAL', true);

insert into persons overriding system value values (0, 'anonimo@senado.leg.br', 'Anonymous', 'Anonymous', '0000', null, 'SEPLAG', null, 'E');
insert into persons values (default, 'hzlopes@senado.leg.br', 'Henrique', 'Zaidan Lopes', '2339', null, 'SEPLAG', null, 'E');
insert into persons values (default, 'pedrohs@senado.leg.br', 'Pedro Henrique', 'Serafim', '2339', null, 'SEPLAG', null, 'E');
insert into persons values (default, 'matheus.braga@senado.leg.br', 'Matheus', 'Oliveira Braga', '2339', null, 'SEPLAG', null, 'E');
insert into persons values (default, 'felipeb@senado.leg.br', 'Felipe', 'Brand�o Cavalcanti', '2048', null, 'SINFRA', null, 'E');
insert into persons values (default, 'laurojnr@senado.leg.br', 'Lauro', 'Alves de Oliveira J�nior', '3456', null, 'COEMANT', null, 'E');
insert into persons values (default, 'rpalet@senado.leg.br', 'Ricardo', 'Paoliello Palet', '1857', null, 'SEMAINST', null, 'E');
insert into persons values (default, 'igorlima@senado.leg.br', 'Igor', 'Grimaldi Lyra Lima', '3629', null, 'SEGEEN', null, 'E');
insert into persons values (default, 'lucianar@senado.leg.br', 'Luciana', 'dos Reis Martins', '1322', null, 'SEMEL', null, 'E');
insert into persons values (default, 'ozelim@senado.leg.br', 'Luan Carlos', 'de Sena Monteiro Ozelim', '3444', null, 'SEMAC', null, 'E');
insert into persons values (default, 'andrenb@senado.leg.br', 'Andr�', 'Nascimento Barbosa', '1322', null, 'SEMEL', null, 'E');
insert into persons values (default, 'jessica.silva@senado.leg.br', 'Jessica', 'Sousa Alves da Silva', '3408', null, 'SEMAC', null, 'E');
insert into persons values (default, 'leonardo.heringer@senado.leg.br', 'Leonardo', 'de Sousa Heringer', '3408', null, 'SEMAC', null, 'E');
insert into persons values (default, 'genivalrs@senado.leg.br', 'Genival', 'Ribeiro de Souza', '3408', null, 'SEMAC', null, 'E');
insert into persons values (default, 'franciscocm@senado.leg.br', 'Francisco', 'Clevanilson Marques e Silva', '3444', null, 'SEMAC', null, 'E');
insert into persons values (default, 'nycolas.nunes@senado.leg.br', 'Nycolas', 'Almeida Nunes', '3408', null, 'SEMAC', null, 'E');
insert into persons values (default, 'nelvio@senado.leg.br', 'N�lvio', 'dal Cortivo', '1415', null, 'SINFRA', null, 'E');
insert into persons values (default, 'danielh@senado.leg.br', 'Daniel Henrique', 'Salgado', '1307', null, 'SINFRA', null, 'E');
insert into persons values (default, 'odaniel@senado.leg.br', 'Daniel', 'Ara�jo Pinto Teixeira', '1415', null, 'EINFRA', null, 'E');
insert into persons values (default, 'sidney@senado.leg.br', 'Sidney', 'Carvalho', '1301', null, 'SEDACOPE', null, 'E');
insert into persons values (default, 'yuri.costa@senado.leg.br', 'Yuri', 'Rodrigues Costa', '3408', null, 'SEMAC', null, 'E');
insert into persons values (default, 'samela.rocha@senado.leg.br', 'S�mela', 'Silva Rocha', '3408', null, 'SEMAC', null, 'E');
insert into persons values (default, 'ivaldosr@senado.leg.br', 'Ivaldo', 'Souza Ribeiro', '1415', null, 'SEMEL', null, 'E');
insert into persons values (default, 'jaimemar@senado.leg.br', 'Jaime', 'Marques de Ara�jo', '1415', null, 'SEMEL', null, 'E');
insert into persons values (default, 'fsidnei@senado.leg.br', 'Francisco Sidnei', 'de Morais', '1415', null, 'SEMAINST', null, 'E');
insert into persons values (default, 'devieira@senado.leg.br', 'Denilton', 'Alves Vieira', '1415', null, 'SEMAINST', null, 'E');
insert into persons values (default, 'rfranco@senado.leg.br', 'Raimundo Nonato', 'de Sousa Franco', '1415', null, 'SEMAINST', null, 'E');
insert into persons values (default, 'andrefn@senado.leg.br', 'Andr� Felipe', 'Nascimento de Souza', '1415', null, 'SINFRA', null, 'E');

insert into private.accounts VALUES (1, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (2, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (3, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (4, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (5, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (6, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (7, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (8, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (9, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (10, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (11, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (12, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (13, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (14, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (15, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (16, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (17, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (18, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (19, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (20, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (21, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (22, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (23, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (24, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (25, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (26, crypt('123456', gen_salt('bf', 10)), now(), now(), true);
insert into private.accounts VALUES (27, crypt('123456', gen_salt('bf', 10)), now(), now(), true);


insert into orders values (default, 'PEN', 'BAI', 'ELE', null, null, 0, 'Insla��o de uma nova tomada para alimentar os novos computadores do gabinete.', 'SEPLAG', 'Henrique Zaidan', 'Henrique Zaidan', '3303-3189', 'Henrique@senado.gov.br', 'Instala��o de nova tomada', 'Sala do SEPLAG / SEMAC', '2019-10-14', '2019-09-09', null, default);
insert into orders values (default, 'EXE', 'BAI', 'HID', null, null, 50, 'Torneira est� vazando constantemente. Providenciar a troca da torneira', 'CONLEG', 'Maria do Carmo', 'Maria do Carmo', '3303-6597', 'Maria@senado.gov.br', 'Vazamento de torneira', 'Sala da secret�ria do Consultor-Legislativo', '2019-12-25', '2019-09-09', null, default);
insert into orders values (default, 'EXE', 'BAI', 'PIS', null, null, 90, 'Trocar o piso do apartamento funcional 307, SQS 309.', 'SGIDOC', 'Fulano de Tal', 'Fulano de Tal', '3303-4603', 'Fulano@senado.gov.br', 'Piso desajustado (risco de acidentes)', 'Apartamento 307, SQS 309', '2019-11-11', '2019-09-09', null, default);
insert into orders values (default, 'CON', 'NOR', 'VID', null, null, 100, 'Trocar todos os vidros rachados da sala da auditoria.', 'SECON', 'Ruy Barbosa', 'Ruy Barbosa', '3303-5694', 'Ruy@senado.gov.br', 'Problema na janela', 'SADCON (sala 11)', '2019-09-01', '2019-08-30', '2019-09-05', default);
insert into orders values (default, 'PEN', 'NOR', 'ELE', null, null, 0, 'Consertar ar-condicionado', 'DGER', 'Machado de Assis', 'Mario Vargas', '3303-4352', 'Mario@senado.gov.br', 'Ar-condicionado n�o est� funcionando', 'Sala 45 do Anexo I, Pavimento 9', '2019-10-20', null, null, default);
insert into orders values (default, 'CON', 'NOR', 'ELE', null, null, 100, 'Colocar canaletas nos fios de (05) Televis�es e no cabo da Net da Sala de reuni�es para melhorar a apar�ncia das salas.', 'DGER', 'Mario Vargas', 'Ruy Barbosa', '3303-2359', 'Ruy@senado.gov.br', 'Instalar canaletas para fios de televis�o (cabo NET)', 'Sala 27 da DGER', '2019-10-20', '2019-09-30', '2019-10-10', default);
insert into orders values (default, 'CON', 'ALT', 'ELE', null, null, 100, 'Solicitamos instalar uma tomada do circuito estabilizado para alimentar o computador da "Ilha 8", que fica ao lado o Est�dio B, para evitar perda de conte�do devido � instabilidades na rede da CEB.', 'CORTV', 'Jo�o Carlos', 'Marco Ant�nio', '3303-5500', 'Marco@senado.gov.br', 'Instalar tomada para computador da Ilha 8', 'Ilha 8 ao lado do est�dio', '2019-10-10', '2019-10-01', '2019-10-08', default);
insert into orders values (default, 'CON', 'URG', 'ELE', null, null, 100, 'Instala��o de calhas para acomodar fios perto das mesas da sala do N�cleo Pol�tico. Obs.: Esse pedido foi feito, atendido, por�m no lugar das calhas colocaram fitas adesivas. Por favor, solicito a instala��o de calhas.', 'SGM', 'Fernando Bandeira', 'Fl�via Mondin', '3303-5757', 'Fl�via@senado.gov.br', 'Instalar calhas para fios no N�cleo Pol�tico', 'Sala de N�cleo Pol�tico', '2019-10-25', '2019-10-15', '2019-10-30', default);
insert into orders values (default, 'EXE', 'ALT', 'ELE', null, null, 20, 'A sala do Servi�o de Gest�o de Est�gios (SGEST) possui uma �rea com eletrodom�sticos como microondas,frigobar, etc. Para essa sala, favor verificar: 1-Se tomadas j� s�o do novo padr�o; 2- Verificar o aterramento dos equipamento e das instala��es. Caso seja necess�rio, favor fazer as adequa��es necess�rias.', 'SGEST', 'Maria Jos�', 'Maria Jos�', '3303-7105', 'Maria@senado.gov.br', 'Refazer el�trica para a copa do SGEST', 'Sala do SGEST', '2019-10-20', '2019-10-10', null, default);
insert into orders values (default, 'EXE', 'NOR', 'GRL', null, null, 40, 'Reforma da Churrasqueira da Resid�ncia Oficial QL 12.', 'DGER', 'Machado de Assis', 'Mario Vargas', '3303-8276', 'Mario@senado.gov.br', 'Reforma da Churrasqueira da Resid�ncia Oficial', 'Resid�ncia Oficial QL 12', '2019-10-25', '2019-10-05', null, default);
insert into orders values (default, 'CON', 'URG', 'ELE', null, null, 100, 'Substitui��o de um disjuntor de 16A por um de 25A.', 'SINFRA', 'N�lvio Dal Cortivo', 'Daniel Salgado', '3303-4423', 'Daniel@senado.gov.br', 'Substituir disjuntor de 16A para 25A', 'Corredor da SINFRA', '2019-10-05', '2019-10-01', '2019-10-05', default);
insert into orders values (default, 'CON', 'NOR', 'ELE', 10, null, 100, 'Instala��o de fita de LED e de painel de LED 30x30 Sobrepor - Churrasqueira Resid�ncia Oficial QL 12. Os itens ser�o adquiridos pelo senador.', 'DGER', 'Machado de Assis', 'Mario Vargas', '3303-5529', 'Mario@senado.gov.br', 'Instalar painel de LED 30x30', 'Resid�ncia Oficial QL 12', '2019-10-20', '2019-10-01', '2019-10-25', default);
insert into orders values (default, 'CON', 'NOR', 'ELE', 10, null, 100, 'Instala��o de cabo plastichumbo - CONFORME PROJETO EM ANEXO - Churrasqueira Resid�ncia Oficial QL 12', 'DGER', 'Machado de Assis', 'Mario Vargas', '3303-7103', 'Mario@senado.gov.br', 'Instalar cabo plastichumbo', 'Resid�ncia Oficial QL 12', '2019-10-26', '2019-10-01', '2019-10-25', default);
insert into orders values (default, 'FIL', 'NOR', 'ELE', 10, null, 0, 'Fornecimento e instala��o de tampa para caixa el�trica 30x30cm - CONFORME PROJETO ANEXO - Churrasqueira Resid�ncia Oficial QL 12', 'DGER', 'Machado de Assis', 'Mario Vargas', '3303-7224', 'Mario@senado.gov.br', 'Instalar tampa para caixa el�trica 30x30', 'Resid�ncia Oficial QL 12', '2019-10-20', '2019-10-01', null, default);
insert into orders values (default, 'CON', 'NOR', 'ELE', null, null, 0, 'SOLICITO A INSTALA��O DE L�MPADAS , PARA ILUMINAR O PAINEL DA GALERIA DOS PRIMEIROS-SECRET�RIOS, MEDIDA 3MX97CM, CUJO LAN�AMENTO OFICIAL OCORRER� NESTA PRIMEIRA-SECRETARIA, EM 17 DE SETEMBRO 2019.', 'PRSECR', 'Andrea de Souza', 'Davison Bandeira', '3303-8049', 'Davison@senado.gov.br', 'Instalar l�mpadas para iluminar galeria dos primeiros secret�rios', 'Painel de Galeria dos Primeiros Secret�rios', '2019-10-15', '2019-10-01', '2019-10-20', default);
insert into orders values (default, 'CON', 'NOR', 'ELE', null, null, 100, 'Prolonga��o de DUTO - Eduardo Gomes 5 Andar', 'GSAANAST', 'Ana Carolina', 'Ana Paula', '3303-9011', 'Ana@senado.gov.br', 'Prolongar duto', 'Edurdo Gomes - 5� Andar', '2019-10-22', '2019-10-01', '2019-10-29', default);
insert into orders values (default, 'SUS', 'NOR', 'ARC', null, null, 20, 'Solicitamos o desvio do ar-condicionado para recep��o, visto que a mesma n�o possu� sa�da do ar.', 'COPROJ', 'Joelmo de Andrade', 'Moacir Correa', '3303-6074', 'Moacir@senado.gov.br', 'Desvio de ar-condicionad para recep��o', 'Sala do COPROJ', null, '2019-10-01', null, default);
insert into orders values (default, 'PEN', 'NOR', 'ARC', null, null, 0, 'Ar condicionado da recep��o n�o est� funcionando normalmente, n�o mant�m o ambiente resfrigerado.', 'SINFRA', 'Felipe Brand�o', 'Daniel Salgado', '3303-6275', 'Daniel@senado.gov.br', 'Verificar ar-condicionado. N�o est� funcionando', 'Recep��o da Sinfra', '2019-10-01', '2019-10-01', null, default);
insert into orders values (default, 'CAN', 'URG', 'ARC', null, null, 0, 'Durante manuten��o preventiva foram identificados danos aos colarinhos das m�quinas da biblioteca. Necess�ria a reconstitui��o.', 'COBIB', 'Patricia Coelho', 'Gerardo Cezar', '3303-9157', 'Gerardo@senado.gov.br', 'Reconstituir colarinhos das m�quinas da COBIB', 'Sala da COBIB', '2019-09-28', null, null, default);
insert into orders values (default, 'FIL', 'NOR', 'ARC', null, null, 0, 'Prezados, Necess�rio instalar novos tubos drenos no jardim da CM3', 'SINFRA', 'Paulo Zandonade', 'Paulo Zandonade', '3303-2002', 'Paulo@senado.gov.br', 'Instalar novos tubos de dreno', 'Jardim da CM3', '2019-10-10', null, null, default);
insert into orders values (default, 'CON', 'NOR', 'HID', null, null, 100, 'Verificar funcionamento - Vazamento - Condi��o das caixas.', 'SINFRA', 'Paulo Zandonade', 'Paulo Zandonade', '3303-7035', 'Paulo@senado.gov.br', 'Verificar condi��es das caixas', 'Pr�dio da SINFRA', '2019-10-25', '2019-10-01', '2019-10-30', default);
insert into orders values (default, 'FIL', 'URG', 'HID', null, null, 0, 'Mict�rio entupido, sem condi��es de uso! Desentupimento de mict�rio', 'DGER', 'Machado de Assis', 'M�rio Vargas', '3303-2139', 'M�rio@senado.gov.br', 'Desentupir mict�rio', 'Banheiro da DGER', '2019-10-01', '2019-10-01', null, default);
insert into orders values (default, 'NEG', 'NOR', 'HID', null, null, 0, 'Solicito a substitui��o do tanque de lavar roupas, pois o mesmo se encontra quebrado. Foto anexa.', 'COBIB', 'Patricia Coelho', 'Gerardo Cezar', '3303-9193', 'Gerardo@senado.gov.br', 'Substituir tanque de lavar roupas', 'Sala da COBIB', null, '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'NOR', 'HID', null, null, 0, 'SOLICITO REGULAR VAZ�O DE DESCARGA DO BANHEIRO FEMININO LOCALIZADO NO 2� ANDAR DO ILB/INTERLEGIS.', 'ILB', 'Carlos Eug�nio', 'Jos� Floriano', '3303-3316', 'Jos�@senado.gov.br', 'Regular vaz�o da descarga do banheiro feminino', 'Banheiro do ILB', '2019-10-06', '2019-10-01', null, default);
insert into orders values (default, 'EXE', 'NOR', 'SER', 10, null, 60, 'Fornecimento e instala��o de tamp�o de ferro para caixa de inspe��o de alvenaria - CONFORME PROJETO ANEXO - Churrasqueira Resid�ncia Oficial QL 12', 'DGER', 'Machado de Assis', 'M�rio Vargas', '3303-7811', 'M�rio@senado.gov.br', 'Fornecer e instalar tamp�o de ferro para caixa de inspe��o', 'Resid�ncia Oficial QL 12', '2019-10-05', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'ALT', 'ELE', null, null, 0, 'Foi substitu�do o quadro antigo por um novo quadro de comando das bombas de esgoto e para que o sistema funcione corretamente � necess�rio a instala��o de b�ias.', 'DGER', 'Machado de Assis', 'M�rio Vargas', '3303-9972', 'M�rio@senado.gov.br', 'Instalar boias para as bombas de esgoto do Anexo II', 'Jardim externo, Anexo II', '2019-10-22', '2019-10-01', null, default);
insert into orders values (default, 'CON', 'NOR', 'HID', null, null, 100, 'Remo��o do filtro de �gua. SERVI�O FORA DO ESCOPO DA OBRA REALIZADA PELA EMPRESA CONECTOR', 'SINFRA', 'Felipe Brand�o', 'Daniel Salgado', '3303-7440', 'Daniel@senado.gov.br', 'Remover filtro de �gua', 'Copa da SINFRA', '2019-10-23', '2019-10-01', '2019-10-06', default);
insert into orders values (default, 'PEN', 'NOR', 'INF', 10, null, 30, 'Recomposic��o de impermeabiliza��o CONFORME PROJETO ANEXO - Churrasqueira Resid�ncia Oficial QL 12', 'DGER', 'Machado de Assis', 'M�rio Vargas', '3303-3709', 'M�rio@senado.gov.br', 'Impermeabiliza��o da �rea da churrasqueira', 'Resid�ncia Oficial QL 12', '2019-11-12', '2019-10-01', null, default);
insert into orders values (default, 'CON', 'NOR', 'INF', null, null, 100, 'Impermeabiliza��o - Ap�s chuva forte, vazamento em varias salas com destaque para sala ocupada pelo Senador - GSRSANT', 'GSRSANT', 'Luciana Aparecida', 'Jos� Emidio', '3303-3842', 'Jos�@senado.gov.br', 'Impermeabiliza��o do gabinete', 'Gabinete do Sena. Rog�rio', '2019-10-15', '2019-10-01', '2019-10-20', default);
insert into orders values (default, 'CON', 'NOR', 'EST', null, null, 100, 'Conserto de rachaduras no Servi�o de Publica��o desta Secretaria. Solicito o conserto das rachaduras em quest�o. A chefe do Servi�o relata preocupa��o em rela��o � seguran�a da equipe. ', 'DGER', 'Machado de Assis', 'M�rio Vargas', '3303-9388', 'M�rio@senado.gov.br', 'Consertar rachadores no Servi�o de Publica��o da DGER', 'Servi�o de Publica��o', '2019-10-22', '2019-10-01', '2019-10-29', default);
insert into orders values (default, 'EXE', 'NOR', 'FOR', null, null, 70, 'Reparar forro PVC ou Metal - TROCA DE PLACAS DE METAL DO CORREDOR - GSEBRA', 'GSEBRA', 'Analice Maruschi', 'Angela Marques', '3303-4924', 'Angela@senado.gov.br', 'Reparar forro PVC ou metal no gabinete', 'Gabinete do Sena. Eduardo', '2019-10-20', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'NOR', 'FOR', null, null, 0, 'Retirar, revitalizar e recolocar as placas do forro met�lico - ANEXO PRINCIPAL, Pavimento 19', 'SINFRA', 'N�lvio Dal Cortivo', 'Felipe Brand�o', '3303-1939', 'Felipe@senado.gov.br', 'Retirar, revitalizar e recolocar as placas do forro met�lico', 'Pavimento 19, Anexo 1', '2019-10-20', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'ALT', 'FOR', null, null, 0, 'Refor�ar o gesso da lumin�ria que fica acima da cabe�a do chefe deste gabinete. - GSRPACHE', 'GSRPACHE', 'Carlos Orlandi', 'Aelton', '3303-5021', 'email@senado.leg.br', 'Refor�ar o gesso da lumin�ria que fica acima da cabe�a do chefe deste gabinete', 'Gabinete do Sena. Rodrigo', '2019-10-10', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'NOR', 'FOR', null, null, 0, 'Solicitamos com urg�ncia interven��o da SINFRA, uma vez que parte do teto em gesso da Copa caiu, quando os trabalhadores vieram retirar arm�rio velho e colocar arm�rio novo, A ocorr�ncia quase gerou acidente de trabalho, uma vez que os peda�os de gesso e de tijolos ca�ram quase por sobre dois trabalhadores da marcenaria. Solicito visita de engenheiros para avaliarem a quest�o e a interven��o apropriada.', 'DGER', 'Geraldo Eust�quio', 'Gis�lia Rosa', '3303-5680', 'Gis�lia@senado.gov.br', 'Recompor o teto de gesso na Copa da DGER', 'Copa da DGER', '2019-10-01', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'URG', 'VID', null, null, 0, 'Tampo de vidro para duas mesas de madeira para proteger e preservar a madeira.', 'ILB', 'Analice Maruschi', 'Angela Marques', '3303-4754', 'Angela@senado.gov.br', 'Fornecer tampo de vidro para mesas de madeira', 'Sala de reuni�o ILB', '2019-10-10', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'NOR', 'VID', null, null, 0, 'Solicito por favor instala��o de espelho no banheiro acess�vel localizado ao lado da recep��o. Obrigada', 'ILB', 'Analice Maruschi', 'Angela Marques', '3303-5261', 'Angela@senado.gov.br', 'Instalar espelho no banheiro', 'Banheiro ILB', '2019-10-20', '2019-10-01', null, default);
insert into orders values (default, 'EXE', 'NOR', 'VID', null, null, 80, 'Vidro Comum e Espelhos - Coloca��o de vidros em vitrines que foram quebrados - COBIB', 'COBIB', 'Patricia Coelho', 'Gerardo Cezar', '3303-4295', 'Gerardo@senado.gov.br', 'Instalar vidros comuns e espelhos', 'Entratada da COBIB', '2019-11-11', '2019-10-01', null, default);
insert into orders values (default, 'CON', 'NOR', 'VID', null, null, 100, 'Solicito espelho para recep��o, nas medidas (aproximadas) de 1,70m x 2m (a conferir no local).', 'COBIB', 'Patricia Coelho', 'Gerardo Cezar', '3303-1976', 'Gerardo@senado.gov.br', 'Instalar espelho para recep��o', 'Recep��o da COBIB', '2019-10-01', '2019-10-01', '2019-10-05', default);
insert into orders values (default, 'CON', 'NOR', 'VID', null, null, 100, 'Vidro Comum e Espelhos - Solicita��od e vidro para quadros do acervo do Senado Federal - GBILB', 'GBILB', 'Francisco Xavier', 'Cynthia Byar', '3303-5799', 'Cynthia@senado.gov.br', 'Instalar vidros para o acervo do Senado Federal', 'Gabinete do ILB', '2019-10-30', null, '2019-10-28', default);
insert into orders values (default, 'EXE', 'NOR', 'ARC', null, null, 60, 'Ar condicionado n�o est� funcionando na sala do SEMAC. Enviar t�cnico para verificar o problema.', 'SEMAC', 'Pedro Serafim', 'Henrique Zaidan', '3303-2406', 'Henrique@senado.gov.br', 'Ar-condicionado n�o est� funcionando no SEMAC', 'Sala do SEMAC', '2019-12-25', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'BAI', 'ARC', null, null, 0, 'Sala est� muito gelada. Fechar uma das sa�das de ar do ar-condicionado.', 'COEMANT', 'Lauro Alves', 'Pedro Serafim', '3303-6405', 'Pedro@senado.gov.br', 'Fechar sa�da de ar do ar-condicionado', 'Sala da COEMANT', '2019-10-01', '2019-10-01', null, default);
insert into orders values (default, 'PEN', 'NOR', 'ARC', null, null, 0, 'Barulho muito alto vindo do ar-condicionado. Verficar os motivos.', 'COEMANT', 'Lauro Alves', 'Pedro Serafim', '3303-3010', 'Pedro@senado.gov.br', 'Verificar barulho no ar-condicionado', 'Sala da COEMANT', '2019-10-07', '2019-10-01', null, default);
insert into orders values (default, 'CON', 'BAI', 'ARC', null, null, 100, 'Ar-condicionado n�o est� gelando. Verificar os motivos.', 'SEAU', 'D�bora Montserrat', 'Vivian', '3303-9352', 'email@senado.leg.br', 'Ar-condicionado n�o est� funcionando no SEAU', 'Sala do SEAU', '2019-09-15', '2019-10-01', '2019-09-19', default);
insert into orders values (default, 'EXE', 'NOR', 'MAR', null, null, 40, 'Confec��o de uma m�o francesa para fixar prateleira.', 'SEAU', 'D�bora Montserrat', 'Vivian', '3303-9564', 'email@senado.leg.br', 'Confec��o de m�o francesa para SEAU', 'Sala do SEAU', '2019-11-11', '2019-10-01', null, default);
insert into orders values (default, 'PEN', 'BAI', 'PIS', null, null, 20, 'Recuperar pixo vin�lico emborrachado. Piso est� soltando a borracha.', 'SINFRA', 'Felipe Brand�o', 'Felipe Brand�o', '3303-6589', 'Felipe@senado.gov.br', 'Reparo no piso que est� soltando na Sinfra', 'Gabinete da Sinfra', '2019-10-30', '2019-10-01', null, default);
insert into orders values (default, 'NEG', 'BAI', 'ELE', null, null, 0, 'Instala��o de uma nova tomada para o computador que ser� utilizado pelo estagi�rio do Seplag.', 'SEPLAG', 'Pedro Serafim', 'Henrique Zaidan', '3303-5655', 'Henrique@senado.gov.br', 'Instala��o de nova tomada para computador no SEPLAG', 'Sala do SEPLAG', null, '2019-10-01', null, default);
insert into orders values (default, 'CON', 'NOR', 'ELE', null, null, 100, 'Embutir novos quadros de energia el�trica no corredor da SINFRA.', 'SINFRA', 'Felipe Brand�o', 'Felipe Brand�o', '3303-9731', 'Felipe@senado.gov.br', 'Embutir novos quadros de energia el�trica no corredor da SINFRA.', 'Corredor da SINFRA', '2019-10-20', '2019-10-01', '2019-10-25', default);
insert into orders values (default, 'CON', 'NOR', 'ELE', null, null, 100, 'Trocar disjuntores do quadro de energia el�trica localizado no corredor da Sinfra.', 'SINFRA', 'Felipe Brand�o', 'Felipe Brand�o', '3303-2041', 'Felipe@senado.gov.br', 'Trocar disjuntores do quadro de energia el�trica localizado no corredor da Sinfra.', 'Corredor da SINFRA', '2019-10-15', '2019-10-01', '2019-10-20', default);
insert into orders values (default, 'CON', 'URG', 'ELE', null, null, 100, 'Trocar baterias do Nobreak da Sinfra', 'SINFRA', 'Felipe Brand�o', 'Felipe Brand�o', '3303-7159', 'Felipe@senado.gov.br', 'Trocar baterias do Nobreak da Sinfra', 'Copa da SINFRA', '2019-10-26', '2019-10-01', '2019-10-25', default);
insert into orders values (default, 'FIL', 'NOR', 'ELE', null, null, 0, 'Verificar problemas com o nobreak da Sinfra. Ele n�o foi acionado na �ltima falta de energia.', 'COEMANT', 'Lauro Alves', 'Pedro Serafim', '3303-1778', 'Pedro@senado.gov.br', 'Verificar problemas com o nobreak da Sinfra. Ele n�o foi acionado na �ltima falta de energia.', 'Copa da SINFRA', '2019-10-20', '2019-10-01', null, default);
insert into orders values (default, 'EXE', 'NOR', 'ELE', null, null, 20, 'Manuten��o preventiva nos nobreaks do Senado Federal.', 'SINFRA', 'Felipe Brand�o', 'Felipe Brand�o', '3303-6085', 'Felipe@senado.gov.br', 'Dar manuten��o preventiva nos nobreaks do Senado Federal.', 'Senado Federal', '2019-10-05', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'NOR', 'ELE', null, null, 0, 'Troca de l�mpadas queimadas na sala do COPRE', 'COEMANT', 'Lauro Alves', 'Pedro Serafim', '3303-9598', 'Pedro@senado.gov.br', 'Trocar l�mpadas queimadas na sala do COPRE', 'Sala da COPRE', '2019-10-10', '2019-10-01', null, default);
insert into orders values (default, 'SUS', 'BAI', 'REV', null, null, 0, 'Pintura da copa da Sinfra.', 'COEMANT', 'Lauro Alves', 'Pedro Serafim', '3303-4271', 'Pedro@senado.gov.br', 'Pintar da copa da Sinfra.', 'Copa da SINFRA', null, '2019-10-01', null, default);
insert into orders values (default, 'CON', 'NOR', 'ELE', null, null, 100, 'Substitui��o de reator na sala da COEMANT.', 'COEMANT', 'Ricardo Palet', 'Raimundo Correia', '3303-8797', 'Raimundo@senado.gov.br', 'Substituir reator na sala da COEMANT.', 'Sala da COEMANT', '2019-10-01', '2019-10-01', '2019-10-05', default);
insert into orders values (default, 'CON', 'BAI', 'ELE', null, null, 100, 'Troca de l�mpadas queimadas na sala do COPROJ', 'COPROJ', 'Joelmo de Andrade', 'Moacir Correa', '3303-3966', 'Moacir@senado.gov.br', 'Trocar l�mpadas queimadas na sala do COPROJ', 'Sala da COPROJ', '2019-10-26', '2019-10-01', '2019-10-25', default);
insert into orders values (default, 'CON', 'BAI', 'ELE', null, null, 100, 'Substitui��o de reator na sala do SEMAC.', 'COEMANT', 'Ricardo Palet', 'Raimundo Correia', '3303-2276', 'Raimundo@senado.gov.br', 'Substituir reator na sala do SEMAC.', 'Sala do SEMAC', '2019-10-15', '2019-10-01', '2019-10-20', default);
insert into orders values (default, 'EXE', 'NOR', 'ELE', null, null, 50, 'Trocar disjuntores do quadro de energia el�trica localizado no corredor da Sinfra.', 'COEMANT', 'Lauro Alves', 'Pedro Serafim', '3303-8913', 'Pedro@senado.gov.br', 'Trocar disjuntores do quadro de energia el�trica localizado no corredor da Sinfra.', 'Corredor da SINFRA', '2019-10-20', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'NOR', 'ELE', null, null, 0, 'Reajustar todos os cabos do quadro de energia el�trica.', 'COEMANT', 'Ricardo Palet', 'Raimundo Correia', '3303-8788', 'Raimundo@senado.gov.br', 'Reajustar todos os cabos do quadro de energia el�trica.', 'Corredor da SINFRA', '2019-10-20', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'BAI', 'ELE', null, null, 0, 'Troca de l�mpadas queimadas na Diretoria da Sinfra', 'COEMANT', 'Ricardo Palet', 'Raimundo Correia', '3303-8179', 'Raimundo@senado.gov.br', 'Trocar l�mpadas queimadas na Diretoria da Sinfra', 'Diretoria da SINFRA', '2019-10-10', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'URG', 'ELE', null, null, 0, 'Pintar a sala de reuni�es (mezanino) da Sinfra.', 'COEMANT', 'Lauro Alves', 'Pedro Serafim', '3303-1005', 'Pedro@senado.gov.br', 'Pintar a sala de reuni�es (mezanino) da Sinfra.', 'Sala de reuni�o da Sinfra', '2019-10-01', null, null, default);
insert into orders values (default, 'EXE', 'NOR', 'REV', null, null, 10, 'Prepara��o do ambiente de trabalho para os servidores da Infraero.', 'COEMANT', 'Lauro Alves', 'Pedro Serafim', '3303-8269', 'Pedro@senado.gov.br', 'Preparar o ambiente de trabalho para os servidores da Infraero.', 'Sala da COEMANT', '2019-10-20', '2019-10-01', null, default);
insert into orders values (default, 'CON', 'NOR', 'ELE', 61, null, 100, 'Fornecimento de cabos unipolares para a OS-0061-2019.', 'COEMANT', 'Ricardo Palet', 'Raimundo Correia', '3303-8819', 'Raimundo@senado.gov.br', 'Fornecer cabos unipolares para a OS-0061-2019.', 'Sala da COEMANT', '2019-10-22', '2019-10-01', '2019-10-29', default);
insert into orders values (default, 'CON', 'NOR', 'REV', 61, null, 100, 'Pintura da nova sala que ser� utilizada pelos servidores da Infraero.', 'SEMAC', 'Luan Ozelim', 'J�ssica Alves', '3303-4300', 'J�ssica@senado.gov.br', 'Pintar nova sala que ser� utilizada pelos servidores da Infraero.', 'Sala da COEMANT', '2019-10-20', '2019-10-01', '2019-10-25', default);
insert into orders values (default, 'EXE', 'NOR', 'ELE', 61, null, 30, 'Instala��o de eletrodutos para passagem dos cabos de rede.', 'COEMANT', 'Ricardo Palet', 'Raimundo Correia', '3303-7711', 'Raimundo@senado.gov.br', 'Instalar eletrodutos para passagem dos cabos de rede.', 'Sala da COEMANT', '2019-11-11', '2019-10-01', null, default);
insert into orders values (default, 'EXE', 'NOR', 'PIS', 61, null, 20, 'Troca do piso da sala que ser� utilizada pelos servidores da Infraero.', 'SEMAC', 'Luan Ozelim', 'J�ssica Alves', '3303-7982', 'J�ssica@senado.gov.br', 'Trocar piso da sala que ser� utilizada pelos servidores da Infraero.', 'Sala da COEMANT', '2019-10-05', '2019-10-01', null, default);
insert into orders values (default, 'EXE', 'NOR', 'VID', 61, null, 50, 'Coloca��o de pel�culas para as salas dos servidores da Infraero.', 'SEMAC', 'Luan Ozelim', 'J�ssica Alves', '3303-9280', 'J�ssica@senado.gov.br', 'Colocar pel�culas para as salas dos servidores da Infraero.', 'Sala da COEMANT', '2019-10-20', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'NOR', 'MAR', 61, null, 0, 'Confec��o de gaveteiros para as mesas dos servidores da Infraero.', 'SEMAC', 'Luan Ozelim', 'J�ssica Alves', '3303-9941', 'J�ssica@senado.gov.br', 'Confeccionar gaveteiros para as mesas dos servidores da Infraero.', 'Sala da COEMANT', '2019-10-10', '2019-10-01', null, default);
insert into orders values (default, 'EXE', 'NOR', 'GRL', null, null, 70, 'Reorganiza��o da infraestrutura da sala da COPROJ.', 'COPROJ', 'Joelmo de Andrade', 'Moacir Correa', '3303-6318', 'Moacir@senado.gov.br', 'Reorganizar infraestrutura da sala da COPROJ.', 'Sala da COPROJ', '2019-10-20', '2019-10-01', null, default);
insert into orders values (default, 'CON', 'NOR', 'ELE', 68, null, 100, 'Retirada de toda infraestrutura antiga da sala da COPROJ.', 'COPROJ', 'Joelmo de Andrade', 'Moacir Correa', '3303-8713', 'Moacir@senado.gov.br', 'Retirar toda infraestrutura antiga da sala da COPROJ.', 'Sala da COPROJ', '2019-10-25', '2019-10-01', '2019-10-30', default);
insert into orders values (default, 'EXE', 'NOR', 'ELE', 68, null, 50, 'Instala��o de novos eletrodutos na sala da COPROJ.', 'COPROJ', 'Joelmo de Andrade', 'Moacir Correa', '3303-6378', 'Moacir@senado.gov.br', 'Instalar novos eletrodutos na sala da COPROJ.', 'Sala da COPROJ', '2019-11-11', '2019-10-01', null, default);
insert into orders values (default, 'FIL', 'NOR', 'ELE', 68, null, 0, 'Passagem dos cabos de energia el�trica e instala��o das tomadas na sala da COPROJ.', 'COPROJ', 'Joelmo de Andrade', 'Moacir Correa', '3303-6387', 'Moacir@senado.gov.br', 'Passar cabos de energia el�trica e instala��o das tomadas na sala da COPROJ.', 'Sala da COPROJ', '2019-10-20', '2019-10-01', null, default);
insert into orders values (default, 'EXE', 'BAI', 'GRL', null, null, 60, 'Restaurar o visual da Diretoria da SINFRA.', 'SINFRA', 'N�lvio Dal Cortivo', 'Felipe Brand�o', '3303-5176', 'Felipe@senado.gov.br', 'Restaurar o visual da Diretoria da SINFRA.', 'Diretoria da SINFRA', '2019-10-01', null, null, default);
insert into orders values (default, 'CON', 'BAI', 'PIS', 72, null, 100, 'Trocar o piso que est� sendo utilizado na Diretoria da SINFRA.', 'SINFRA', 'N�lvio Dal Cortivo', 'Felipe Brand�o', '3303-9616', 'Felipe@senado.gov.br', 'Trocar o piso que est� sendo utilizado na Diretoria da SINFRA.', 'Diretoria da SINFRA', '2019-10-15', '2019-10-01', '2019-10-20', default);
insert into orders values (default, 'FIL', 'BAI', 'REV', 72, null, 0, 'Refazer a pintura da Diretoria da SINFRA.', 'SINFRA', 'N�lvio Dal Cortivo', 'Felipe Brand�o', '3303-1460', 'Felipe@senado.gov.br', 'Refazer a pintura da Diretoria da SINFRA.', 'Diretoria da SINFRA', '2019-10-01', '2019-10-01', null, default);
insert into orders values (default, 'CON', 'BAI', 'GRL', null, null, 100, 'Reforma geral de toda parte el�trica do Gabinete da Sinfra.', 'SINFRA', 'Daniel Ara�jo', 'Sidney Carvalho', '3303-1082', 'Sidney@senado.gov.br', 'Reforma geral de toda parte el�trica do Gabinete da Sinfra.', 'Gabinete da SINFRA', '2019-10-26', '2019-10-01', '2019-10-25', default);
insert into orders values (default, 'CON', 'BAI', 'ELE', 75, null, 100, 'Substitui��o dos eletrodutos no Gabinete da SINFRA.', 'SINFRA', 'Daniel Ara�jo', 'Sidney Carvalho', '3303-8524', 'Sidney@senado.gov.br', 'Substituir eletrodutos no Gabinete da SINFRA.', 'Gabinete da SINFRA', '2019-10-22', '2019-10-01', '2019-10-29', default);
insert into orders values (default, 'CON', 'BAI', 'ELE', 75, null, 100, 'Substitui��o dos cabos no Gabinete da SINFRA.', 'SINFRA', 'Daniel Ara�jo', 'Sidney Carvalho', '3303-6381', 'Sidney@senado.gov.br', 'Substituir cabos no Gabinete da SINFRA.', 'Gabinete da SINFRA', '2019-10-25', '2019-10-01', '2019-10-30', default);


insert into order_messages values (27, 10, 'Uma mensagem sobre esta O.S.', '2019-09-11', '2019-09-11');
insert into order_messages values (2, 7, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (48, 17, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (20, 7, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (48, 20, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (40, 3, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (31, 1, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (10, 3, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (64, 19, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (30, 3, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (33, 5, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (5, 10, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (18, 17, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (53, 17, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (20, 11, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (45, 15, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (69, 8, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (46, 12, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (29, 3, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (9, 7, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (32, 16, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (49, 18, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (44, 19, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (74, 20, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (30, 8, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (29, 19, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (76, 12, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (60, 20, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (49, 4, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (4, 11, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (66, 4, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (4, 15, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (47, 20, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (23, 5, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (47, 4, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (40, 16, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (4, 17, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (19, 9, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (31, 14, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (61, 8, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (74, 3, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (46, 13, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (35, 2, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (31, 17, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (37, 19, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (15, 3, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (7, 3, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (68, 5, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (33, 4, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (61, 11, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (20, 2, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (16, 12, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (44, 8, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (68, 20, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (29, 1, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (41, 10, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (2, 3, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (68, 7, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (6, 5, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (31, 13, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (32, 19, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (1, 10, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (44, 15, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (36, 10, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (72, 11, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (46, 17, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (3, 11, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (69, 13, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (34, 3, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (1, 3, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (52, 13, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (36, 11, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (1, 5, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (40, 10, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (25, 1, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (65, 10, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (33, 9, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (50, 14, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (6, 19, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (36, 11, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (46, 5, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (77, 18, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (10, 17, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (75, 15, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (2, 19, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (41, 14, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (29, 16, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (75, 7, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (67, 2, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (12, 3, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (75, 19, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (46, 2, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (27, 20, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (39, 2, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (48, 16, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (76, 5, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (9, 10, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (7, 19, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (2, 14, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (42, 5, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (76, 4, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (35, 17, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (17, 16, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (19, 16, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (75, 16, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (64, 6, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (18, 6, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (15, 14, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (27, 18, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (5, 10, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (65, 15, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (77, 12, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (21, 1, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (54, 20, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (2, 14, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (41, 16, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (14, 20, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (56, 4, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (35, 13, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (71, 16, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (8, 5, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (12, 7, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (3, 14, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (23, 5, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (44, 16, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (7, 12, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (24, 10, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (65, 8, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (50, 7, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (16, 9, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (50, 3, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (51, 19, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (7, 7, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (1, 4, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (74, 4, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (59, 6, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (7, 17, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (28, 4, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (27, 10, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (27, 3, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (26, 10, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (30, 1, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (60, 18, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (27, 7, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (7, 5, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (36, 17, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (47, 4, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (47, 16, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (51, 16, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (22, 19, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (62, 17, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (64, 13, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (59, 15, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (40, 18, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (42, 15, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (37, 2, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (51, 6, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (11, 5, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (48, 10, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (25, 7, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (60, 3, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (56, 1, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (31, 19, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (29, 8, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (3, 11, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (57, 5, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (72, 12, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (62, 4, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (67, 3, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (41, 14, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (5, 5, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (8, 9, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (56, 9, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (44, 16, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (2, 5, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (14, 4, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (47, 2, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (12, 10, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (33, 15, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (27, 11, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (6, 2, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (24, 7, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (45, 19, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (5, 14, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (49, 10, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (4, 6, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (59, 5, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (36, 13, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (16, 2, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (31, 4, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (23, 20, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (40, 1, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (49, 2, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (16, 3, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (66, 3, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (57, 2, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (5, 19, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (11, 4, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (47, 5, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (20, 3, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (17, 17, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (68, 1, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (22, 12, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (9, 8, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (44, 14, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (40, 7, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (53, 5, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (49, 17, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (60, 2, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (41, 9, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (75, 20, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (51, 1, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (14, 3, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (30, 19, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (28, 15, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (58, 16, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (50, 8, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (39, 1, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (53, 15, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (65, 2, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (21, 6, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (47, 18, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (41, 4, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (13, 20, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (64, 5, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (43, 12, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (19, 9, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (48, 14, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (6, 11, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (70, 13, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (30, 18, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (57, 9, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (34, 1, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (18, 15, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (72, 16, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (48, 9, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (4, 7, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (22, 4, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (45, 15, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (25, 13, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (5, 20, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (57, 14, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (29, 7, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (2, 8, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (15, 19, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (24, 18, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (31, 18, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (67, 11, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (62, 18, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (68, 17, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (59, 6, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (72, 11, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (48, 12, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (11, 8, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (55, 16, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (63, 3, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (73, 18, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (48, 6, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (72, 11, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (16, 5, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (25, 19, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (26, 9, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (49, 10, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (54, 3, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (57, 2, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (39, 12, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (34, 7, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (65, 12, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (7, 7, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (15, 16, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (38, 1, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (54, 15, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (32, 16, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (10, 13, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (65, 1, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (68, 20, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (59, 2, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (8, 3, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (20, 14, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (69, 17, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (45, 9, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (31, 15, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (23, 10, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (71, 4, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (71, 9, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (49, 16, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (18, 17, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (57, 12, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (36, 14, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (70, 5, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (32, 4, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (47, 17, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (74, 10, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (1, 15, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (63, 11, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (28, 3, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (23, 18, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (11, 16, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (55, 5, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (1, 6, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (74, 19, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (50, 4, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (37, 7, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (10, 11, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (56, 1, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (49, 5, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (28, 11, 'Uma observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (30, 19, 'Outra observa��o.', '2019-09-12', '2019-09-12');
insert into order_messages values (31, 4, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (24, 13, 'Uma mensagem sobre esta O.S.', '2019-09-12', '2019-09-12');
insert into order_messages values (23, 17, 'Outra mensagem.', '2019-09-12', '2019-09-12');
insert into order_messages values (54, 6, 'Uma observa��o.', '2019-09-12', '2019-09-12');


insert into order_assets values (1, 'ELET-CA-0002');
insert into order_assets values (2, 'EDPR-ACM-005');
insert into order_assets values (3, '309C-P03-303');
insert into order_assets values (4, 'BL16-TER-027');
insert into order_assets values (5, 'MECN-FC-0002');
insert into order_assets values (6, 'AX01-P09-017');
insert into order_assets values (7, 'ELET-CA-0007');
insert into order_assets values (8, 'AX01-P03-007');
insert into order_assets values (9, 'BL10-SEM-039');
insert into order_assets values (10, 'SHIS-000-000');
insert into order_assets values (11, 'ELET-QD-0002');
insert into order_assets values (12, 'SHIS-000-000');
insert into order_assets values (13, 'SHIS-000-000');
insert into order_assets values (14, 'SHIS-000-000');
insert into order_assets values (15, 'ELET-CI-0001');
insert into order_assets values (16, 'AX02-AA1-005');
insert into order_assets values (17, 'MECN-FC-0003');
insert into order_assets values (18, 'MECN-FC-0004');
insert into order_assets values (19, 'AX02-AFM-042');
insert into order_assets values (20, 'MECN-CA-0002');
insert into order_assets values (21, 'BL14-MEZ-096');
insert into order_assets values (22, 'BL10-P01-003');
insert into order_assets values (23, 'AX02-AFM-042');
insert into order_assets values (24, 'BL12-TER-001');
insert into order_assets values (25, 'SHIS-000-000');
insert into order_assets values (26, 'CIVL-BM-0001');
insert into order_assets values (27, 'BL14-MEZ-096');
insert into order_assets values (28, 'SHIS-000-000');
insert into order_assets values (29, 'AX02-AA1-021');
insert into order_assets values (30, 'BL10-P01-003');
insert into order_assets values (31, 'AX02-AAA-070');
insert into order_assets values (32, 'BL14-MEZ-096');
insert into order_assets values (33, 'AX01-P04-008');
insert into order_assets values (34, 'BL10-P01-003');
insert into order_assets values (35, 'BL12-TER-001');
insert into order_assets values (36, 'BL12-TER-001');
insert into order_assets values (37, 'AX02-AFM-042');
insert into order_assets values (38, 'AX02-AFM-042');
insert into order_assets values (39, 'BL12-TER-004');
insert into order_assets values (40, 'MECN-FC-0005');
insert into order_assets values (41, 'MECN-FC-0006');
insert into order_assets values (42, 'MECN-FC-0006');
insert into order_assets values (43, 'MECN-FC-0007');
insert into order_assets values (44, 'BL14-MEZ-046');
insert into order_assets values (45, 'BL14-MEZ-096');
insert into order_assets values (46, 'ELET-CA-0002');
insert into order_assets values (47, 'BL14-MEZ-096');
insert into order_assets values (48, 'ELET-QD-0002');
insert into order_assets values (49, 'ELET-NB-0001');
insert into order_assets values (50, 'ELET-NB-0001');
insert into order_assets values (51, 'ELET-NB-0001');
insert into order_assets values (51, 'ELET-NB-0002');
insert into order_assets values (51, 'ELET-NB-0003');
insert into order_assets values (51, 'ELET-NB-0004');
insert into order_assets values (52, 'ELET-CI-0005');
insert into order_assets values (53, 'BL14-MEZ-096');
insert into order_assets values (54, 'ELET-CI-0002');
insert into order_assets values (55, 'ELET-CI-0003');
insert into order_assets values (56, 'ELET-CI-0004');
insert into order_assets values (57, 'ELET-QD-0002');
insert into order_assets values (58, 'ELET-QD-0002');
insert into order_assets values (59, 'ELET-CI-0007');
insert into order_assets values (60, 'BL14-MEZ-096');
insert into order_assets values (61, 'BL14-MEZ-046');
insert into order_assets values (62, 'ELET-CA-0002');
insert into order_assets values (63, 'BL14-MEZ-046');
insert into order_assets values (64, 'ELET-CA-0002');
insert into order_assets values (65, 'BL14-MEZ-046');
insert into order_assets values (66, 'BL14-MEZ-046');
insert into order_assets values (67, 'BL14-MEZ-046');
insert into order_assets values (68, 'BL14-P01-044');
insert into order_assets values (69, 'ELET-CA-0003');
insert into order_assets values (69, 'ELET-CI-0003');
insert into order_assets values (70, 'ELET-CA-0003');
insert into order_assets values (70, 'ELET-CI-0003');
insert into order_assets values (71, 'ELET-CA-0003');
insert into order_assets values (72, 'BL14-MEZ-096');
insert into order_assets values (73, 'BL14-MEZ-096');
insert into order_assets values (74, 'BL14-MEZ-096');
insert into order_assets values (75, 'ELET-CI-0007');
insert into order_assets values (76, 'ELET-CI-0007');
insert into order_assets values (77, 'ELET-CI-0007');


insert into asset_departments values ('BL10-P01-003', 'DGER');
insert into asset_departments values ('AX01-P09-010', 'EDGER');
insert into asset_departments values ('AX01-P09-017', 'ATDGER');
insert into asset_departments values ('AX01-P03-007', 'SGM');
insert into asset_departments values ('EDPR-ACM-005', 'CONLEG');
insert into asset_departments values ('EDPR-P01-024', 'PRSECR');
insert into asset_departments values ('AX02-AA1-005', 'GSAANAST');
insert into asset_departments values ('AX02-AA1-021', 'GSRSANT');
insert into asset_departments values ('AX02-AAA-070', 'GSEBRA');
insert into asset_departments values ('AX01-P04-008', 'GSRPACHE');
insert into asset_departments values ('BL16-TER-023', 'SADCON');
insert into asset_departments values ('BL16-TER-027', 'SECON');
insert into asset_departments values ('AX02-AN1-070', 'CORTV');
insert into asset_departments values ('BL10-SEM-039', 'SGEST');
insert into asset_departments values ('BL12-TER-001', 'ILB');
insert into asset_departments values ('BL12-TER-004', 'GBILB');
insert into asset_departments values ('AX02-AFM-042', 'COBIB');
insert into asset_departments values ('BL14-MEZ-096', 'SINFRA');
insert into asset_departments values ('BL14-MEZ-043', 'COEMANT');
insert into asset_departments values ('BL14-MEZ-046', 'SEPLAG');
insert into asset_departments values ('BL14-P01-043', 'COPRE');
insert into asset_departments values ('BL14-P01-044', 'COPROJ');
insert into asset_departments values ('BL14-MEZ-046', 'SEAU');






-- alter sequences
-- alter sequence orders_order_id_seq restart with 100;
-- alter sequence persons_person_id_seq restart with 100;

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