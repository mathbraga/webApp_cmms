--------------------------------------------------------------------------------
/*

                          Generate new CMMS database script

  Order of commands:

    drop database
    create new database
    connect to the new database
    create extensions
    create additional schemas
    begin transaction
    create custom types
    create tables
    create views
    create policies (row-level security)
    create functions
    create triggers
    create roles (already created for the database cluster, not necessary in new databases)
    grant permissions
    create comments
    insert rows into tables
    alter sequences

*/
--------------------------------------------------------------------------------
-- drop database
drop database if exists cmms3;

-- create new database
create database cmms3 with owner postgres template template0 encoding 'WIN1252';

-- connect to the new database
\c cmms3

-- create extensions
create extension if not exists pgcrypto;

-- create additional schemas
create schema private;

-- begin transaction
begin transaction;

-- create custom types
create type asset_category_type as enum ('F', 'A');
create type person_category_type AS ENUM ('E', 'T');
create type order_status_type as enum ();
create type order_priority_type as enum ();
create type order_category_type as enum ();

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
  price real,
  warranty text
);

create table contracts (
  contract_id text not null primary key,
  sign_date date not null,
  end_date date,
  start_date date not null,
  description text not null,
  company text not null,
  url text not null
  -- parent_type text,
  -- parent_number integer,
  -- contract_type text not null, -- transform into enum
  -- contract_number integer not null,
  -- date_start date not null,
  -- date_end date not null,
  -- primary key (contract_type, contract_number),
  -- foreign key (parent_type, parent_number) references contracts (contract_type, contract_number)
);

-- create table ceb_meters  (
--   meter_id integer not null primary key,
--   meter_name text not null,
--   description text not null,
--   modtar_text text not null,
--   contract text not null references contracts (contract_id),
--   classe text not null,
--   subclasse text not null,
--   grupo text not null,
--   subgrupo text not null,
--   fases text not null,
--   dcf integer not null,
--   dcp integer not null
-- );

-- create table ceb_meter_assets (
--   meter_id integer not null references ceb_meters (meter_id),
--   asset_id text not null references assets (asset_id),
--   primary key (meter_id, asset_id)
-- );

-- create table ceb_bills (
--   meter_id integer not null references ceb_meters (meter_id),
--   yyyymm integer not null,
--   modtar integer not null,
--   datav integer not null,
--   kwh integer not null,
--   confat integer not null,
--   icms real not null,
--   cip real not null,
--   trib real not null,
--   jma real not null,
--   desconto real not null,
--   basec real not null,
--   vliq real not null,
--   vbru real not null,
--   kwhp integer not null,
--   kwhf integer not null,
--   dmp integer not null,
--   dmf integer not null,
--   dfp integer not null,
--   dff integer not null,
--   uferp integer not null,
--   uferf integer not null,
--   verexp real not null,
--   verexf real not null,
--   vdfp real not null,
--   vdff real not null,
--   vudp real not null,
--   vudf real not null,
--   dcp integer not null,
--   dcf integer not null,
--   primary key (meter_id, yyyymm)    
-- );

-- create table caesb_meters (
--   meter_id integer not null primary key,
--   meter_name text not null,
--   description text not null,
--   contract text not null references contracts (contract_id),
--   hidrom text not null,
--   cat integer not null
-- );
    
-- create table caesb_meter_assets (
--   meter_id integer not null references caesb_meters (meter_id),
--   asset_id text not null references assets (asset_id),
--   primary key (meter_id, asset_id)
-- );

-- create table caesb_bills (
--   meter_id integer not null references caesb_meters (meter_id),
--   yyyymm integer not null,
--   lat integer not null,
--   dlat integer not null,
--   lan integer not null,
--   dlan integer not null,
--   dif integer not null,
--   consm integer not null,
--   consf integer not null,
--   vagu real not null,
--   vesg real not null,
--   adic real not null,
--   subtotal real not null,
--   cofins real not null,
--   irpj real not null,
--   csll real not null,
--   pasep real not null,
--   primary key (meter_id, yyyymm)    
-- );

create table departments (
  department_id text not null primary key,
  parent text not null references departments (department_id),
  name text not null,
  is_active boolean not null
);

create table persons (
  person_id serial primary key,
  email text not null unique check (email ~* '^.+@.+\..+$'),
  name text not null,
  surname text not null,
  phone text not null,
  department text references departments (department_id),
  contract text references contracts (contract_id),
  category person_category_type
);

create table private.accounts (
  person_id integer not null references persons (person_id),
  password_hash text not null,
  created_at timestamp not null,
  updated_at timestamp not null,
  is_active boolean not null default true
);

create table orders (
  order_id serial primary key,    
  status order_status_type not null,
  priority order_priority_type not null,
  category order_category_type not null,
  parent integer references orders (order_id),
  contract text references contracts (contract_id),
  completed integer check (completed >= 0 and completed <= 100),
  request_text text not null,
  request_department text references departments (department_id),
  request_person text not null,
  request_contact_name text not null,
  request_contact_phone text not null,
  request_contact_email text not null,
  request_title text not null,
  request_local text,
  date_limit timestamp,
  date_start timestamp,
  created_at timestamp not null default now()
);

create table order_messages (
  order_id integer not null references orders (order_id),
  person_id integer not null references persons (person_id),
  message text not null,
  created_at timestamp not null,
  updated_at timestamp not null
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
  person_id integer not null,
  stamp timestamp not null,
  operation text not null,
  tablename text not null,
  old_row json,
  new_row json
);

-- create table specs (
--   spec_id text,
--   spec_name text,
--   group text,
--   subgroup text,
--   details text,
--   materials text,
--   services text,
--   activities text,
--   observations text,
--   criteria text,
--   graphics text, -- actually, those are photos ==> should be out of the db
--   tables text,
--   lifespan text,
--   commercial_reference text,
--   external_reference text,
--   is_subcont boolean,
--   documental_reference text,
--   catmat_catser text
-- );

-- create table items (
--   contract_type text not null,
--   contract_number integer not null,
--   item_id text,
--   standard_id text references standards (standard_id),
--   description text,
--   available real not null,
--   provisioned real not null,
--   consumed real not null,
--   quantity_type text not null, -- transformar em enum (integer or real)
--   unit text,
--   primary key (contract_type, contract_number, item_id),
--   foreign key (contract_type, contract_number) references contracts (contract_type, contract_number)
-- );

-- create table order_items (
--   order_id integer references orders (order_id),
--   contract_type text not null,
--   contract_number integer not null,
--   item_id text not null,
--   quantity real,
--   foreign key (contract_type, contract_number, item_id) references items (contract_type, contract_number, item_id)
-- );

-- create views
create view facilities as
  select
    asset_id,
    parent,
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

-- create policies (row-level security)
alter table tablename enable row level security;
create policy unauth_policy on rlstest for select to unauth using (true);
create policy auth_policy on rlstest for all to auth using (true) with check (true);
create policy graphiql on rlstest for all to postgres using (true) with check (true);
------- instructions:
-- 0) set all access privileges (grant or revoke commands)
-- 1) enable / disable rls for the table (can be used if a policy exists or not --> does not delete existing policies)
-- 2) create / drop policy (using --> select, update, delete ;  with check --> insert, update)
-- 3) if "for all" ==> 
-- 4) default policy is deny.


-- create functions

-- create triggers

-- create roles (already created for the database cluster, not necessary in new databases)
-- create role unauth;
-- create role auth;

-- grant permissions
grant select on all tables in schema public to unauth;
grant select, insert, update, delete on all tables in schema public to auth;
-----------------------
-- grant usage on all sequences in schema public to unauth;
-- grant usage on all sequences in schema public to auth;
-- alter default privileges in schema public grant all on tables to unauth;
-- alter default privileges in schema public grant all on tables to auth;
--------------------


-- create comments
comment on type order_status_type is E'
  Significados dos possíveis valores do enum order_status_type:\n
  CAN: Cancelada;\n 
  NEG: Negada;\n
  PEN: Pendente;\n
  SUS: Suspensa;\n
  FIL: Fila de espera;\n
  EXE: Execução;\n
  CON: Concluída.
';

comment on type order_category_type is E'
  Significados dos possíveis valores do enum order_category_type:\n
  EST: Avaliação estrutural;\n
  FOR: Reparo em forro;\n
  INF: Infiltração;\n
  ELE: Instalações elétricas;\n
  HID: Instalações hidrossanitárias;\n
  MAR: Marcenaria;\n
  PIS: Reparo em piso;\n
  REV: Revestimento;\n
  VED: Vedação espacial;\n
  VID: Vidraçaria / Esquadria;\n
  SER: Serralheria.
';

comment on type order_priority_type is E'
  Significados dos possíveis valores do enum order_priority_type:\n
  BAI: Baixa;\n
  NOR: Normal;\n
  ALT: Alta;\n
  URG: Urgente.
';

-- insert rows into tables

-- alter sequences
alter sequence orders_order_id_seq restart with 100;
alter sequence persons_person_id_seq restart with 100;