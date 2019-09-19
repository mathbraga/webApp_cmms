--------------------------------------------------------------------------------
/*

                          GENERATE NEW CMMS DATABASE SCRIPT
  
  This file should be executed from psql interactive terminal.
    
                  From the shell terminal, execute:

                    $ cd /path/to/project/folder
                    $ psql old_db
                  
                  and then, from psql interactive terminal:

                    old_db=# \i script.sql

  Order of commands:

    drop database
    create new database
    connect to the new database
    create extensions
    create additional schemas
    begin transaction
    create roles
    alter default privileges
    create custom types
    create tables
      assets
      contracts
      ceb_meters
      ceb_meter_assets
      ceb_bills
      caesb_meters
      caesb_meter_assets
      caesb_bills
      departments
      persons
      private.accounts
      orders
      order_messages
      order_assets
      asset_departments
      private.logs
      specs
      items
      order_items
    create views
    create functions
    create comments
    insert rows into tables
    alter sequences
    create triggers
    create policies

*/
--------------------------------------------------------------------------------
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

-- begin transaction
begin transaction;

-- create roles (already created for the database cluster, not necessary in new databases)
-- create role unauth;
-- create role auth;

-- alter default privileges
alter default privileges in schema public grant select on tables to unauth;
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
  'EST',
  'FOR',
  'INF',
  'ELE',
  'HID',
  'MAR',
  'PIS',
  'REV',
  'VED',
  'VID',
  'SER'
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
--   datav date not null,
--   kwh integer not null,
--   confat integer not null,
--   icms money not null,
--   cip money not null,
--   trib money not null,
--   jma money not null,
--   desconto money not null,
--   basec money not null,
--   vliq money not null,
--   vbru money not null,
--   kwhp integer not null,
--   kwhf integer not null,
--   dmp integer not null,
--   dmf integer not null,
--   dfp integer not null,
--   dff integer not null,
--   uferp integer not null,
--   uferf integer not null,
--   verexp money not null,
--   verexf money not null,
--   vdfp money not null,
--   vdff money not null,
--   vudp money not null,
--   vudf money not null,
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
--   vagu money not null,
--   vesg money not null,
--   adic money not null,
--   subtotal money not null,
--   cofins money not null,
--   irpj money not null,
--   csll money not null,
--   pasep money not null,
--   primary key (meter_id, yyyymm)    
-- );

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
  created_at timestamp not null,
  updated_at timestamp not null,
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
--   provisioned real not null, -- alternative column name: blocked?
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
language plpgsql
strict
security definer
as $$
declare
  account private.accounts;
begin

  select a.* into account
    from persons as p
    join private.accounts as a using(person_id)
    where p.email = 'hzlopes@senado.leg.br';
 
  if (
    account.password_hash = crypt(input_password, account.password_hash)
    and account.is_active
  ) then
    return account.person_id;
  else
    return null;
  end if;
  
end; $$;

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
    row_to_json(old, false),
    row_to_json(new, false)
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
  dept text;
begin

insert into appliances values (appliance_attributes.*)
  returning asset_id into new_appliance_id;

if departments_array is not null then
  foreach dept in array departments_array::text[] loop
    insert into assets_departments (
      asset_id,
      department_id
    ) values (
      new_appliance_id,
      dept
    );
  end loop;
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
  dept text;
begin

insert into facilities values (facility_attributes.*)
  returning asset_id into new_facility_id;

if departments_array is not null then
  foreach dept in array departments_array::text[] loop
    insert into assets_departments (
      asset_id,
      department_id
    ) values ( 
      new_facility_id,
      dept
    );
  end loop;
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
  assigned_asset text;
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
  ans_factor,
  sigad,
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
  order_attributes.ans_factor,
  order_attributes.sigad,
  order_attributes.date_limit,
  order_attributes.date_start,
  default,
  order_attributes.contract
) returning order_id into new_order_id;

foreach assigned_asset in array assets_array loop
  insert into orders_assets (
    order_id,
    asset_id
  ) values (
    new_order_id,
    assigned_asset
  );
end loop;

return new_order_id;

end; $$;

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
insert into assets values ('CASF-000-000', 'CASF-000-000', 'CASF-000-000', 'Complexo Arquitetônico - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-000-000', 'CASF-000-000', 'CASF-000-000', 'Edifício Principal - Todos', 'Descrição do ativo', 'F', -15,79925, -47,864063, 14942,27, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-SS1-000', 'EDPR-000-000', 'EDPR-000-000', 'Edifício Principal - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-SS1-051', 'EDPR-SS1-000', 'EDPR-SS1-000', 'Edifício Principal - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-SS1-052', 'EDPR-SS1-000', 'EDPR-SS1-000', 'Edifício Principal - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-SS1-062', 'EDPR-SS1-000', 'EDPR-SS1-000', 'Edifício Principal - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-SS1-063', 'EDPR-SS1-000', 'EDPR-SS1-000', 'Edifício Principal - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-000', 'EDPR-000-000', 'EDPR-000-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-002', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-031', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-032', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-033', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-034', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-035', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-036', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-037', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-045', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-047', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-051', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-052', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-054', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-055', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-056', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-057', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-061', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-062', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-063', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-064', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-065', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-070', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-071', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-072', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-073', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-074', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-075', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-083', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-085', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-087', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-088', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-091', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-093', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-TER-095', 'EDPR-TER-000', 'EDPR-TER-000', 'Edifício Principal - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-000', 'EDPR-000-000', 'EDPR-000-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-001', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-002', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-003', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-004', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-005', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-006', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-007', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-011', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-012', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-014', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-015', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-017', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-021', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-023', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-024', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-025', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-026', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-027', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-028', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-029', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-040', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ADM-050', 'EDPR-ADM-000', 'EDPR-ADM-000', 'Edifício Principal - Ala Dinarte Mariz', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-000', 'EDPR-000-000', 'EDPR-000-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-001', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-006', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-007', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-008', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-009', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-010', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-011', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-012', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-021', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-022', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-023', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-024', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-025', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-026', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-027', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-028', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-029', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-031', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-032', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-033', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-034', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-035', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-036', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-041', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-042', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-043', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-044', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-045', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-046', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-047', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-048', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-049', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-050', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-052', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-054', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-056', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-057', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-058', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-059', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-065', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-066', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-067', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-068', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-069', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-072', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-076', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-078', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-082', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-084', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P01-086', 'EDPR-P01-000', 'EDPR-P01-000', 'Edifício Principal - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-000', 'EDPR-000-000', 'EDPR-000-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-002', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-003', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-004', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-005', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-013', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-014', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-015', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-023', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-024', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-025', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-033', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-034', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-ACM-035', 'EDPR-ACM-000', 'EDPR-ACM-000', 'Edifício Principal - Ala Antonio Carlos Magalhães', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-000', 'EDPR-000-000', 'EDPR-000-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-050', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-051', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-052', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-054', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-055', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-056', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-057', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-058', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-059', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-065', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-067', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-068', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-P02-069', 'EDPR-P02-000', 'EDPR-P02-000', 'Edifício Principal - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-000', 'EDPR-000-000', 'EDPR-000-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-001', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-002', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-004', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-011', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-012', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-021', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-022', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-023', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-024', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-031', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-032', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-041', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-042', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('EDPR-COB-044', 'EDPR-COB-000', 'EDPR-COB-000', 'Edifício Principal - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-000-000', 'CASF-000-000', 'CASF-000-000', 'Anexo 1 - Todos', 'Descrição do ativo', 'F', -15,799637, -47,863349, 14891,06, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS2-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS2-015', 'AX01-SS2-000', 'AX01-SS2-000', 'Anexo 1 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS2-016', 'AX01-SS2-000', 'AX01-SS2-000', 'Anexo 1 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS2-017', 'AX01-SS2-000', 'AX01-SS2-000', 'Anexo 1 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-002', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-003', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-004', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-005', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-006', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-007', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-008', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-009', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-010', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-012', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-013', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-014', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-015', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-016', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-017', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-018', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-019', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-030', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-045', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-062', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-063', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-064', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-065', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-SS1-067', 'AX01-SS1-000', 'AX01-SS1-000', 'Anexo 1 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-002', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-003', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-004', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-005', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-006', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-007', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-008', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-009', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-010', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-012', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-013', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-014', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-015', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-016', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-017', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-018', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-019', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-020', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-030', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-036', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-038', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-042', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-045', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-052', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-055', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-062', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-065', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-067', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-072', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-082', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P01-088', 'AX01-P01-000', 'AX01-P01-000', 'Anexo 1 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-002', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-003', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-004', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-005', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-006', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-007', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-008', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-009', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-010', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-012', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-013', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-014', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-015', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-016', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-017', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-018', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-019', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-020', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P02-030', 'AX01-P02-000', 'AX01-P02-000', 'Anexo 1 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-002', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-003', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-004', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-005', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-006', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-007', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-008', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-009', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-010', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-012', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-013', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-014', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-015', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-016', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-017', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-018', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-019', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-020', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P03-030', 'AX01-P03-000', 'AX01-P03-000', 'Anexo 1 - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-002', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-003', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-004', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-005', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-006', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-007', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-008', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-009', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-010', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-012', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-013', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-014', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-015', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-016', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-017', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-018', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-019', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-020', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P04-030', 'AX01-P04-000', 'AX01-P04-000', 'Anexo 1 - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-002', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-003', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-004', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-005', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-006', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-007', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-008', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-009', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-010', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-012', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-013', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-014', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-015', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-016', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-017', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-018', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-019', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-020', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P05-030', 'AX01-P05-000', 'AX01-P05-000', 'Anexo 1 - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-002', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-003', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-004', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-005', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-006', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-007', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-008', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-009', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-010', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-012', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-013', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-014', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-015', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-016', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-017', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-018', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-019', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-020', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P06-030', 'AX01-P06-000', 'AX01-P06-000', 'Anexo 1 - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-002', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-003', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-004', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-005', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-006', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-007', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-008', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-009', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-010', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-012', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-013', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-014', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-015', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-016', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-017', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-018', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-019', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-020', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P07-030', 'AX01-P07-000', 'AX01-P07-000', 'Anexo 1 - 7º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-002', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-003', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-004', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-005', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-006', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-007', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-008', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-009', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-010', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-012', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-013', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-014', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-015', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-016', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-017', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-018', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-019', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-020', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P08-030', 'AX01-P08-000', 'AX01-P08-000', 'Anexo 1 - 8º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-002', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-003', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-004', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-005', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-006', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-007', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-008', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-009', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-010', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-012', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-013', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-014', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-015', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-016', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-017', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-018', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-019', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-020', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P09-030', 'AX01-P09-000', 'AX01-P09-000', 'Anexo 1 - 9º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-002', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-003', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-004', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-005', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-006', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-007', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-008', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-009', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-010', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-012', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-013', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-014', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-015', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-016', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-017', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-018', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-019', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-020', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P10-030', 'AX01-P10-000', 'AX01-P10-000', 'Anexo 1 - 10º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-002', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-003', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-004', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-005', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-006', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-007', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-008', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-009', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-010', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-012', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-013', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-014', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-015', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-016', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-017', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-018', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-019', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-020', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P11-030', 'AX01-P11-000', 'AX01-P11-000', 'Anexo 1 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-002', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-003', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-004', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-005', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-006', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-007', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-008', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-009', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-010', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-012', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-013', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-014', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-015', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-016', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-017', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-018', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-019', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-020', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P12-030', 'AX01-P12-000', 'AX01-P12-000', 'Anexo 1 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-002', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-003', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-004', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-005', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-006', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-007', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-008', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-009', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-010', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-012', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-013', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-014', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-015', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-016', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-017', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-018', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-019', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-020', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P13-030', 'AX01-P13-000', 'AX01-P13-000', 'Anexo 1 - 13º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-002', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-003', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-004', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-005', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-006', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-007', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-008', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-009', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-010', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-012', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-013', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-014', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-015', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-016', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-017', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-018', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-019', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-020', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-030', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P14-036', 'AX01-P14-000', 'AX01-P14-000', 'Anexo 1 - 14º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-002', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-003', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-004', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-005', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-006', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-007', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-008', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-009', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-010', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-012', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-013', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-014', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-015', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-016', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-017', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-018', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-019', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-020', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-030', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P15-036', 'AX01-P15-000', 'AX01-P15-000', 'Anexo 1 - 15º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-002', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-003', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-004', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-005', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-006', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-007', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-008', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-009', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-010', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-012', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-013', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-014', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-015', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-016', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-017', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-018', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-019', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-020', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-030', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P16-036', 'AX01-P16-000', 'AX01-P16-000', 'Anexo 1 - 16º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-002', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-003', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-004', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-005', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-006', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-007', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-008', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-009', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-010', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-012', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-013', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-014', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-015', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-016', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-017', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-018', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-019', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-020', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P17-030', 'AX01-P17-000', 'AX01-P17-000', 'Anexo 1 - 17º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-002', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-003', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-004', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-005', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-006', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-007', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-008', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-009', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-010', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-012', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-013', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-014', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-015', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-016', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-017', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-018', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-019', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-020', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P18-030', 'AX01-P18-000', 'AX01-P18-000', 'Anexo 1 - 18º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-002', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-003', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-004', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-005', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-006', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-007', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-008', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-009', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-010', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-012', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-013', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-014', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-015', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-016', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-017', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-018', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-019', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-020', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P19-030', 'AX01-P19-000', 'AX01-P19-000', 'Anexo 1 - 19º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-002', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-003', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-004', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-005', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-006', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-007', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-008', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-009', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-010', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-012', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-013', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-014', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-015', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-016', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-017', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-018', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-019', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-020', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P20-030', 'AX01-P20-000', 'AX01-P20-000', 'Anexo 1 - 20º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-002', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-003', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-004', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-005', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-006', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-007', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-008', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-009', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-010', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-012', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-013', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-014', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-015', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-016', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-017', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-018', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-019', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-020', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P21-030', 'AX01-P21-000', 'AX01-P21-000', 'Anexo 1 - 21º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-002', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-003', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-004', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-005', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-006', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-007', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-008', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-009', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-010', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-012', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-013', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-014', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-015', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-016', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-017', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-018', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-019', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-020', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P22-030', 'AX01-P22-000', 'AX01-P22-000', 'Anexo 1 - 22º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-002', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-003', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-004', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-005', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-006', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-007', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-008', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-009', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-010', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-012', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-013', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-014', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-015', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-016', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-017', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-018', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-019', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-020', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P23-030', 'AX01-P23-000', 'AX01-P23-000', 'Anexo 1 - 23º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-002', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-003', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-004', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-005', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-006', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-007', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-008', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-009', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-010', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-012', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-013', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-014', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-015', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-016', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-017', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-018', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-019', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-020', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P24-030', 'AX01-P24-000', 'AX01-P24-000', 'Anexo 1 - 24º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-002', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-003', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-004', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-005', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-006', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-007', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-008', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-009', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-010', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-012', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-013', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-014', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-015', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-016', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-017', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-018', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-019', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-020', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P25-030', 'AX01-P25-000', 'AX01-P25-000', 'Anexo 1 - 25º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-002', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-003', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-004', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-005', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-006', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-007', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-008', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-009', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-010', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-012', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-013', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-014', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-015', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-016', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-017', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-018', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-019', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-020', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P26-030', 'AX01-P26-000', 'AX01-P26-000', 'Anexo 1 - 26º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-002', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-003', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-004', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-005', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-006', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-007', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-008', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-009', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-010', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-012', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-013', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-014', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-015', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-016', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-017', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-018', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-019', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-020', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P27-030', 'AX01-P27-000', 'AX01-P27-000', 'Anexo 1 - 27º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-002', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-003', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-004', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-005', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-006', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-007', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-008', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-009', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-010', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-013', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-014', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-015', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-016', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-017', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-018', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-019', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-P28-020', 'AX01-P28-000', 'AX01-P28-000', 'Anexo 1 - 28º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-000', 'AX01-000-000', 'AX01-000-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-002', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-003', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-004', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-005', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-006', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-007', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-008', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-009', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-010', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-014', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-015', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-016', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-017', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-018', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-019', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-020', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX01-COB-036', 'AX01-COB-000', 'AX01-COB-000', 'Anexo 1 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-000-000', 'CASF-000-000', 'CASF-000-000', 'Anexo 2 - Todos', 'Descrição do ativo', 'F', -15,798156, -47,864237, 43788,02, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-051', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-052', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-060', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-076', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-085', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-086', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS2-087', 'AX02-SS2-000', 'AX02-SS2-000', 'Anexo 2 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-001', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-002', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-003', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-004', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-005', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-006', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-007', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-008', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-009', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-011', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-012', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-013', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-014', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-015', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-018', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-019', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-021', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-022', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-023', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-024', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-025', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-026', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-027', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-028', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-038', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-039', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-041', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-042', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-043', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-044', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-045', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-046', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-047', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-048', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-049', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-050', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-051', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-052', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-053', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-058', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-059', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-060', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-064', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-065', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-066', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-067', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-068', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-069', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-071', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-072', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-073', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-074', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-075', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-076', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-077', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-078', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-079', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-081', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-082', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-083', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-084', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-086', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-087', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-088', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-089', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-091', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-092', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-093', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-094', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-095', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-096', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-097', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-098', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-SS1-099', 'AX02-SS1-000', 'AX02-SS1-000', 'Anexo 2 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-011', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-012', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-014', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-016', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-018', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-020', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-022', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-028', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-030', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-031', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-032', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-034', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-036', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-038', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-040', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-041', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-042', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-044', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-046', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-048', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-054', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-058', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-060', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-062', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-064', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-065', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-066', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-068', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-076', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-078', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-079', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-081', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-082', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-083', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-084', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-085', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-086', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-087', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-088', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-089', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-091', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-093', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-095', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-096', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-098', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-TER-099', 'AX02-TER-000', 'AX02-TER-000', 'Anexo 2 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-001', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-002', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-003', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-004', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-005', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-006', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-007', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-008', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-009', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-010', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-011', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-012', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-013', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-031', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-032', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-033', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-034', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-035', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-036', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-037', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-038', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-039', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-040', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-041', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-042', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-043', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-061', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-062', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-063', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-064', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-065', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-066', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-067', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-068', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-070', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-071', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-072', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-094', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-097', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-098', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAA-099', 'AX02-AAA-000', 'AX02-AAA-000', 'Anexo 2 - Ala Afonso Arinos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-001', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-002', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-003', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-004', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-005', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-006', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-007', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-008', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-009', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-010', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-011', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-012', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-013', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-014', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-015', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-031', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-032', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-033', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-034', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-035', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-036', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-037', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-038', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-039', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-040', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-041', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-042', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-043', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-044', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-045', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-061', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-062', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-063', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-064', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-065', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-066', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-067', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-068', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-069', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-070', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-071', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-072', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-073', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-074', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-075', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-084', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-087', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-088', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-089', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-097', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AFM-099', 'AX02-AFM-000', 'AX02-AFM-000', 'Anexo 2 - Ala Filinto Müller', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-002', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-004', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-006', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-008', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-010', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-032', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-034', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-036', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-038', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-040', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-064', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-066', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-068', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-070', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-088', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-090', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-098', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ANT-099', 'AX02-ANT-000', 'AX02-ANT-000', 'Anexo 2 - Ala Nilo Coelho Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-003', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-005', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-007', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-009', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-011', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-013', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-015', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-017', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-019', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-021', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-033', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-035', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-037', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-039', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-041', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-043', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-045', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-047', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-049', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-051', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-063', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-065', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-067', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-069', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-071', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-073', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-075', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-080', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-081', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-090', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-091', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-092', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-097', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-098', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AAT-099', 'AX02-AAT-000', 'AX02-AAT-000', 'Anexo 2 - Ala Alexandre Costa Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-007', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-008', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-009', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-020', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-030', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-040', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-060', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-066', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-070', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-071', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-072', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-073', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-074', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-075', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P01-076', 'AX02-P01-000', 'AX02-P01-000', 'Anexo 2 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-001', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-002', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-003', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-004', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-021', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-022', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-023', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-024', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-041', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-042', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-043', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-044', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-061', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-063', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-087', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-088', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ARC-089', 'AX02-ARC-000', 'AX02-ARC-000', 'Anexo 2 - Ala Ruy Carneiro', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-030', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-049', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-050', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-051', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-052', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-053', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-054', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-055', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-056', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-057', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-058', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-059', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-060', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-069', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-070', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-071', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-072', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-073', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-074', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-075', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-076', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-077', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-078', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-079', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-080', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-090', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-094', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATN-098', 'AX02-ATN-000', 'AX02-ATN-000', 'Anexo 2 - Ala Tancredo Neves', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-001', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-002', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-003', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-004', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-005', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-006', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-007', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-008', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-009', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-010', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-011', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-012', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-013', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-014', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-015', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-016', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-017', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-018', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-019', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-020', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-021', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-022', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-023', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-024', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-025', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-031', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-032', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-033', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-034', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-035', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-036', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-037', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-038', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-039', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-040', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-041', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-042', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-043', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-044', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-045', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-046', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-047', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-048', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-049', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-050', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-051', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-052', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-053', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-054', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-055', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-061', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-062', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-063', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-064', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-065', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-066', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-067', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-068', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-069', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-070', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-071', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-072', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-073', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-074', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-075', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-076', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-077', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-078', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-079', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-080', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-081', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-082', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-085', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-088', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-089', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-090', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-091', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-092', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-093', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-094', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-095', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-096', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-097', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ATV-098', 'AX02-ATV-000', 'AX02-ATV-000', 'Anexo 2 - Ala Teotônio Vilela', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-004', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-006', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-008', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-010', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-032', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-036', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-040', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-066', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-070', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-088', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AN1-090', 'AX02-AN1-000', 'AX02-AN1-000', 'Anexo 2 - Ala Nilo Coelho 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-001', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-003', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-005', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-007', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-009', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-011', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-013', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-015', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-017', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-019', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-021', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-031', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-032', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-035', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-041', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-047', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-051', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-065', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-071', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-077', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-081', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-088', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-090', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-091', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-AA1-092', 'AX02-AA1-000', 'AX02-AA1-000', 'Anexo 2 - Ala Alexandre Costa 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-070', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-076', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-080', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-086', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-090', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-P02-096', 'AX02-P02-000', 'AX02-P02-000', 'Anexo 2 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-001', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-002', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-003', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-004', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-012', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-013', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-021', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-022', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-032', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-033', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-042', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-044', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-050', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-051', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-052', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-053', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-054', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-055', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-056', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-057', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-058', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-059', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-060', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-061', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-062', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-ALI-063', 'AX02-ALI-000', 'AX02-ALI-000', 'Anexo 2 - Ala das Lideranças', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-000', 'AX02-000-000', 'AX02-000-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-001', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-002', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-003', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-004', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-005', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-006', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-007', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-008', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-009', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-010', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-011', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-012', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-017', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-021', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-022', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-023', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-024', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-025', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-026', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-027', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-028', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-029', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-030', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-031', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-032', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-037', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-041', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-042', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-043', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-044', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-045', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-046', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-047', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-048', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-049', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-050', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-051', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-052', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-061', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-062', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-063', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-064', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-065', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-066', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-067', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-068', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-069', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-070', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-071', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-072', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-073', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-074', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-075', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-077', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-081', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-083', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-085', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-087', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-089', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-091', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-093', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-095', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-097', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AX02-COB-099', 'AX02-COB-000', 'AX02-COB-000', 'Anexo 2 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 01 - Todos', 'Descrição do ativo', 'F', -15,797074, -47,86433, 5896,55, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala A', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-001', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-002', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-003', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-004', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-005', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-006', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-007', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-008', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALA-009', 'BL01-ALA-000', 'BL01-ALA-000', 'Bloco 01 - Ala A', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-010', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-011', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-012', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-013', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-014', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-015', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-016', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-017', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-018', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-019', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-020', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALB-021', 'BL01-ALB-000', 'BL01-ALB-000', 'Bloco 01 - Ala B', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala C', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-022', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-023', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-024', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-025', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-026', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-027', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-028', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-031', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALC-032', 'BL01-ALC-000', 'BL01-ALC-000', 'Bloco 01 - Ala C', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala D', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-033', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-035', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-036', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-037', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-038', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-039', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-040', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-041', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALD-042', 'BL01-ALD-000', 'BL01-ALD-000', 'Bloco 01 - Ala D', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-043', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-044', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-045', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-046', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-047', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-051', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-052', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-055', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-056', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-057', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-058', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-059', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-060', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALE-061', 'BL01-ALE-000', 'BL01-ALE-000', 'Bloco 01 - Ala E', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALF-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala F', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALF-071', 'BL01-ALF-000', 'BL01-ALF-000', 'Bloco 01 - Ala F', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALF-072', 'BL01-ALF-000', 'BL01-ALF-000', 'Bloco 01 - Ala F', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALF-073', 'BL01-ALF-000', 'BL01-ALF-000', 'Bloco 01 - Ala F', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALF-074', 'BL01-ALF-000', 'BL01-ALF-000', 'Bloco 01 - Ala F', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALG-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Ala G', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALG-081', 'BL01-ALG-000', 'BL01-ALG-000', 'Bloco 01 - Ala G', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALG-082', 'BL01-ALG-000', 'BL01-ALG-000', 'Bloco 01 - Ala G', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALG-083', 'BL01-ALG-000', 'BL01-ALG-000', 'Bloco 01 - Ala G', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-ALG-084', 'BL01-ALG-000', 'BL01-ALG-000', 'Bloco 01 - Ala G', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-000', 'BL01-000-000', 'BL01-000-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-001', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-002', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-011', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-012', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-013', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-014', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-015', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-016', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-017', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-018', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-019', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-020', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-021', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-022', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-023', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-031', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-032', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-041', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-042', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-043', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-044', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-045', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-046', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-047', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-048', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-049', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-050', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-051', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-052', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-053', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-061', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-062', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL01-TER-063', 'BL01-TER-000', 'BL01-TER-000', 'Bloco 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 02 - Todos', 'Descrição do ativo', 'F', -15,796191, -47,864551, 4448,31, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-000', 'BL02-000-000', 'BL02-000-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-001', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-002', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-003', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-004', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-005', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-006', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-007', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-008', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-011', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-012', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-013', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-014', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-015', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-016', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-017', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-018', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-024', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-SS1-027', 'BL02-SS1-000', 'BL02-SS1-000', 'Bloco 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-000', 'BL02-000-000', 'BL02-000-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-001', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-002', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-003', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-004', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-005', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-006', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-007', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-012', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-013', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-014', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-015', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-016', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-017', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-033', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-034', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-035', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-036', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-037', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-041', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-042', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-043', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-044', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-051', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-052', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-053', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-TER-054', 'BL02-TER-000', 'BL02-TER-000', 'Bloco 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-000', 'BL02-000-000', 'BL02-000-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-001', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-002', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-003', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-004', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-005', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-006', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-007', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-011', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-012', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-013', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-014', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-015', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-016', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P01-017', 'BL02-P01-000', 'BL02-P01-000', 'Bloco 02 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-000', 'BL02-000-000', 'BL02-000-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-001', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-002', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-003', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-004', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-005', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-006', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-007', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-011', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-012', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-013', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-014', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-015', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-016', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-P02-017', 'BL02-P02-000', 'BL02-P02-000', 'Bloco 02 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-000', 'BL02-000-000', 'BL02-000-000', 'Bloco 02 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-002', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-004', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-006', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-012', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-014', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-016', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-017', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-033', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-034', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL02-COB-036', 'BL02-COB-000', 'BL02-COB-000', 'Bloco 02 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 03 - Todos', 'Descrição do ativo', 'F', 0, 0, 160,73, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-000', 'BL03-000-000', 'BL03-000-000', 'Bloco 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-001', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-002', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-003', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-004', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-011', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-TER-014', 'BL03-TER-000', 'BL03-TER-000', 'Bloco 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-COB-000', 'BL03-000-000', 'BL03-000-000', 'Bloco 03 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-COB-001', 'BL03-COB-000', 'BL03-COB-000', 'Bloco 03 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-COB-002', 'BL03-COB-000', 'BL03-COB-000', 'Bloco 03 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-COB-004', 'BL03-COB-000', 'BL03-COB-000', 'Bloco 03 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL03-COB-012', 'BL03-COB-000', 'BL03-COB-000', 'Bloco 03 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 04 - Todos', 'Descrição do ativo', 'F', 0, 0, 1465,52, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-000', 'BL04-000-000', 'BL04-000-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-008', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-009', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-016', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-018', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-022', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-023', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-024', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-025', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-026', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-027', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-028', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-SEM-036', 'BL04-SEM-000', 'BL04-SEM-000', 'Bloco 04 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-000', 'BL04-000-000', 'BL04-000-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-001', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-002', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-006', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-012', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-013', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-016', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-021', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-022', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-023', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-024', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-025', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-026', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-027', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P01-030', 'BL04-P01-000', 'BL04-P01-000', 'Bloco 04 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-P02-000', 'BL04-000-000', 'BL04-000-000', 'Bloco 04 - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-000', 'BL04-000-000', 'BL04-000-000', 'Bloco 04 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-012', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-014', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-016', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-018', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-022', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-024', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-026', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL04-COB-028', 'BL04-COB-000', 'BL04-COB-000', 'Bloco 04 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 05 - Todos', 'Descrição do ativo', 'F', 0, 0, 777,29, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-000', 'BL05-000-000', 'BL05-000-000', 'Bloco 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-001', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-002', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-003', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-004', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-005', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-021', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-022', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-023', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-024', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-TER-025', 'BL05-TER-000', 'BL05-TER-000', 'Bloco 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-P01-000', 'BL05-000-000', 'BL05-000-000', 'Bloco 05 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-P01-003', 'BL05-P01-000', 'BL05-P01-000', 'Bloco 05 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-P01-004', 'BL05-P01-000', 'BL05-P01-000', 'Bloco 05 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-P01-005', 'BL05-P01-000', 'BL05-P01-000', 'Bloco 05 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-COB-000', 'BL05-000-000', 'BL05-000-000', 'Bloco 05 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-COB-001', 'BL05-COB-000', 'BL05-COB-000', 'Bloco 05 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-COB-002', 'BL05-COB-000', 'BL05-COB-000', 'Bloco 05 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-COB-003', 'BL05-COB-000', 'BL05-COB-000', 'Bloco 05 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL05-COB-004', 'BL05-COB-000', 'BL05-COB-000', 'Bloco 05 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 06 - Todos', 'Descrição do ativo', 'F', 0, 0, 3357,96, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-000', 'BL06-000-000', 'BL06-000-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-002', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-003', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-004', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-005', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-006', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-007', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-008', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-009', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-010', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-011', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-SS1-012', 'BL06-SS1-000', 'BL06-SS1-000', 'Bloco 06 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-000', 'BL06-000-000', 'BL06-000-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-001', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-002', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-003', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-004', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-005', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-006', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-007', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-008', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-009', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-010', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-011', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-012', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-013', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-014', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-015', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-024', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-025', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-026', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-027', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-028', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-029', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-030', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-033', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-037', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-TER-040', 'BL06-TER-000', 'BL06-TER-000', 'Bloco 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-000', 'BL06-000-000', 'BL06-000-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-001', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-002', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-003', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-004', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-011', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-012', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-013', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-014', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-021', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-022', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-023', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-P01-024', 'BL06-P01-000', 'BL06-P01-000', 'Bloco 06 - Primeiro Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL06-COB-000', 'BL06-000-000', 'BL06-000-000', 'Bloco 06 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 07 - Todos', 'Descrição do ativo', 'F', 0, 0, 3114,8, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-000', 'BL07-000-000', 'BL07-000-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-003', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-004', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-005', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-006', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-007', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-008', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-009', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-010', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-011', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-012', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-013', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-014', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-015', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-016', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-017', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-018', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-027', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-028', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-030', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-032', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-034', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-SEM-038', 'BL07-SEM-000', 'BL07-SEM-000', 'Bloco 07 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-000', 'BL07-000-000', 'BL07-000-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-001', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-002', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-003', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-004', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-005', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-006', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-007', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-008', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-009', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-010', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-011', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-012', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-013', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-014', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-015', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-016', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-017', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-018', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-27', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-034', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-P01-035', 'BL07-P01-000', 'BL07-P01-000', 'Bloco 07 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-000', 'BL07-000-000', 'BL07-000-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-001', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-002', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-003', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-004', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-005', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-006', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-007', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-008', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-009', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-010', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-011', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-012', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-013', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-014', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-015', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-016', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-017', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL07-COB-018', 'BL07-COB-000', 'BL07-COB-000', 'Bloco 07 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 08 - Todos', 'Descrição do ativo', 'F', 0, 0, 3357,96, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-000', 'BL08-000-000', 'BL08-000-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-001', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-002', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-003', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-004', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-005', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-006', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-007', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-008', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-009', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-010', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-011', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-012', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-013', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-014', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-015', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-020', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-021', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-022', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-023', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-024', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-033', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-SEM-035', 'BL08-SEM-000', 'BL08-SEM-000', 'Bloco 08 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-000', 'BL08-000-000', 'BL08-000-000', 'Bloco 08 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-009', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-010', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-011', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-012', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-013', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-014', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-021', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-022', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-MEZ-034', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Bloco 08 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-P01-000', 'BL08-000-000', 'BL08-000-000', 'Bloco 08 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-000', 'BL08-000-000', 'BL08-000-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-001', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-002', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-003', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-004', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-011', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-012', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-013', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-014', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-021', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-022', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-023', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL08-COB-024', 'BL08-COB-000', 'BL08-COB-000', 'Bloco 08 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 09 - Todos', 'Descrição do ativo', 'F', 0, 0, 2935,87, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-000', 'BL09-000-000', 'BL09-000-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-001', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-002', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-003', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-004', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-005', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-006', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-007', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-008', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-009', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-010', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-011', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-012', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-013', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-014', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-020', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-021', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-022', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-031', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-033', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-035', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-037', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-039', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-041', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-043', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-047', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-055', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-057', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-059', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-060', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-061', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-063', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-065', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-067', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-069', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-071', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-073', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-075', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-077', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-079', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-SEM-081', 'BL09-SEM-000', 'BL09-SEM-000', 'Bloco 09 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-MEZ-000', 'BL09-000-000', 'BL09-000-000', 'Bloco 09 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-MEZ-013', 'BL09-MEZ-000', 'BL09-MEZ-000', 'Bloco 09 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-MEZ-014', 'BL09-MEZ-000', 'BL09-MEZ-000', 'Bloco 09 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-MEZ-021', 'BL09-MEZ-000', 'BL09-MEZ-000', 'Bloco 09 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-MEZ-022', 'BL09-MEZ-000', 'BL09-MEZ-000', 'Bloco 09 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-P01-000', 'BL09-000-000', 'BL09-000-000', 'Bloco 09 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-000', 'BL09-000-000', 'BL09-000-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-001', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-002', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-003', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-004', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-005', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-011', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-012', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-013', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-014', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-015', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-021', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-022', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-023', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-024', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL09-COB-025', 'BL09-COB-000', 'BL09-COB-000', 'Bloco 09 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 10 - Todos', 'Descrição do ativo', 'F', 0, 0, 3981,59, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-000', 'BL10-000-000', 'BL10-000-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-007', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-008', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-009', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-010', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-011', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-012', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-013', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-014', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-015', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-016', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-017', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-018', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-019', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-020', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-021', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-022', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-023', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-024', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-025', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-026', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-027', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-037', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-038', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-039', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-040', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-041', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-042', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-043', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-044', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-045', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-046', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-047', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-048', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-049', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-050', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-051', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-052', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-053', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-054', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-055', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-056', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-060', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-061', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-062', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-077', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-078', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-080', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-081', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-087', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-088', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-089', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-090', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-091', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-092', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-093', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-094', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-095', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-096', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-097', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-098', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-SEM-099', 'BL10-SEM-000', 'BL10-SEM-000', 'Bloco 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-000', 'BL10-000-000', 'BL10-000-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-001', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-002', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-003', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-004', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-005', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-006', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-007', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-008', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-009', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-010', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-011', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-012', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-013', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-014', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-015', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-016', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-017', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-018', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-019', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-020', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-021', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-022', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-023', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-024', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-025', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-026', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-027', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-031', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-032', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-033', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-034', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-035', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-036', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-037', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-038', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-039', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-040', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-041', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-042', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-043', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-044', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-045', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-046', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-047', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-048', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-049', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-050', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-051', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-052', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-053', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-054', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-055', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-056', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-064', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-065', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-072', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-073', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-074', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-076', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-077', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-079', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-083', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-P01-085', 'BL10-P01-000', 'BL10-P01-000', 'Bloco 10 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-000', 'BL10-000-000', 'BL10-000-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-001', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-002', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-003', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-004', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-005', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-006', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-007', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-008', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-009', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-010', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-011', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-012', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-013', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-014', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-015', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-016', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-017', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-018', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-019', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-020', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-021', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-022', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-023', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-024', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-025', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-026', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-027', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-090', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-093', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL10-COB-095', 'BL10-COB-000', 'BL10-COB-000', 'Bloco 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 11 - Todos', 'Descrição do ativo', 'F', 0, 0, 991,03, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-000', 'BL11-000-000', 'BL11-000-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-001', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-002', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-003', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-004', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-005', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-006', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-007', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-008', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-009', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-021', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-022', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-023', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-024', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-025', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-026', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-027', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-028', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-029', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-TER-036', 'BL11-TER-000', 'BL11-TER-000', 'Bloco 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-000', 'BL11-000-000', 'BL11-000-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-001', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-002', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-003', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-004', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-005', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-006', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-007', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-008', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-009', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-021', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-022', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-023', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-024', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-025', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-026', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-027', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-028', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-029', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL11-COB-036', 'BL11-COB-000', 'BL11-COB-000', 'Bloco 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 12 - Todos', 'Descrição do ativo', 'F', 0, 0, 997,93, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-000', 'BL12-000-000', 'BL12-000-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-001', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-002', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-003', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-004', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-005', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-006', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-007', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-008', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-009', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-010', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-020', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-021', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-022', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-023', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-024', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-025', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-026', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-027', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-028', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-029', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-TER-036', 'BL12-TER-000', 'BL12-TER-000', 'Bloco 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-000', 'BL12-000-000', 'BL12-000-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-001', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-002', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-003', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-004', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-005', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-006', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-007', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-008', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-009', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-021', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-022', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-023', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-024', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-025', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-026', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-027', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-028', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-029', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL12-COB-036', 'BL12-COB-000', 'BL12-COB-000', 'Bloco 12 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 13 - Todos', 'Descrição do ativo', 'F', 0, 0, 1575,77, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-000', 'BL13-000-000', 'BL13-000-000', 'Bloco 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-001', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-002', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-003', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-005', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-006', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-007', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-SS1-009', 'BL13-SS1-000', 'BL13-SS1-000', 'Bloco 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-000', 'BL13-000-000', 'BL13-000-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-001', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-002', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-003', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-004', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-005', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-006', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-007', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-009', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-022', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-026', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-030', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-032', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-034', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-036', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-038', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-TER-040', 'BL13-TER-000', 'BL13-TER-000', 'Bloco 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-000', 'BL13-000-000', 'BL13-000-000', 'Bloco 13 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-002', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-003', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-004', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-005', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-006', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-007', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-008', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-P01-009', 'BL13-P01-000', 'BL13-P01-000', 'Bloco 13 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-000', 'BL13-000-000', 'BL13-000-000', 'Bloco 13 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-001', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-002', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-003', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-004', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-005', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-007', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL13-COB-009', 'BL13-COB-000', 'BL13-COB-000', 'Bloco 13 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 14 - Todos', 'Descrição do ativo', 'F', 0, 0, 10719,12, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-000', 'BL14-000-000', 'BL14-000-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-027', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-028', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-029', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-030', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-031', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-032', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-033', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-034', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-035', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-036', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-037', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-038', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-039', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-040', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-041', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-042', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-043', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-044', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-045', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-046', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-047', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-078', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-079', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-080', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-081', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-088', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-092', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-093', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-096', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-SEM-097', 'BL14-SEM-000', 'BL14-SEM-000', 'Bloco 14 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-000', 'BL14-000-000', 'BL14-000-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-001', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-002', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-003', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-004', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-005', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-006', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-007', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-008', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-009', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-010', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-011', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-012', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-013', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-014', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-015', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-016', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-017', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-018', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-019', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-020', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-021', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-022', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-023', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-024', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-025', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-026', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-027', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-028', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-029', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-030', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-031', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-032', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-033', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-034', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-035', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-036', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-037', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-038', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-039', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-040', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-041', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-042', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-043', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-044', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-045', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-046', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-047', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-048', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-049', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-050', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-051', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-056', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-058', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-059', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-064', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-065', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-068', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-072', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-073', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-076', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-080', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-084', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-088', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-090', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-092', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-096', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-097', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-098', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-P01-099', 'BL14-P01-000', 'BL14-P01-000', 'Bloco 14 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-000', 'BL14-000-000', 'BL14-000-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-014', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-030', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-035', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-036', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-037', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-038', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-039', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-040', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-041', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-042', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-043', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-046', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-047', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-049', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-050', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-057', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-058', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-060', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-063', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-065', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-068', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-071', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-072', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-073', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-074', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-075', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-076', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-077', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-078', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-079', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-080', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-081', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-082', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-083', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-084', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-087', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-090', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-094', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-MEZ-096', 'BL14-MEZ-000', 'BL14-MEZ-000', 'Bloco 14 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-000', 'BL14-000-000', 'BL14-000-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-001', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-002', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-003', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-004', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-005', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-006', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-007', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-008', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-009', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-010', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-011', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-012', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-013', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-014', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-015', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-016', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-017', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-018', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-019', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-020', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-021', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-022', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-023', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-024', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-025', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-026', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-027', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-028', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-029', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-030', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-031', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-032', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-033', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-034', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-035', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-036', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-037', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-038', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-039', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-040', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-041', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-042', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-043', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-044', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-045', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-046', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-047', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-048', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-049', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-051', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL14-COB-052', 'BL14-COB-000', 'BL14-COB-000', 'Bloco 14 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 15 - Todos', 'Descrição do ativo', 'F', 0, 0, 1357,01, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-000', 'BL15-000-000', 'BL15-000-000', 'Bloco 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-002', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-011', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-012', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-013', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-021', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-022', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-023', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-031', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-032', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-TER-033', 'BL15-TER-000', 'BL15-TER-000', 'Bloco 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-MEZ-000', 'BL15-000-000', 'BL15-000-000', 'Bloco 15 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-MEZ-011', 'BL15-MEZ-000', 'BL15-MEZ-000', 'Bloco 15 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-MEZ-012', 'BL15-MEZ-000', 'BL15-MEZ-000', 'Bloco 15 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-MEZ-021', 'BL15-MEZ-000', 'BL15-MEZ-000', 'Bloco 15 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-MEZ-023', 'BL15-MEZ-000', 'BL15-MEZ-000', 'Bloco 15 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-000', 'BL15-000-000', 'BL15-000-000', 'Bloco 15 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-001', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-002', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-003', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-031', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-032', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL15-COB-033', 'BL15-COB-000', 'BL15-COB-000', 'Bloco 15 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 16 - Todos', 'Descrição do ativo', 'F', 0, 0, 7198,68, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-000', 'BL16-000-000', 'BL16-000-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-001', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-002', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-003', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-004', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-005', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-006', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-007', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-008', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-009', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-021', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-022', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-023', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-024', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-025', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-026', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-027', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-028', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-034', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-041', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-042', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-045', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-048', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-052', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-062', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-070', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-071', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-072', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-075', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-076', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-080', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-TER-081', 'BL16-TER-000', 'BL16-TER-000', 'Bloco 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-000', 'BL16-000-000', 'BL16-000-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-001', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-002', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-003', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-004', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-007', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-008', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-009', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-021', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-022', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-023', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-025', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-026', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-027', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-028', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-031', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-034', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-041', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-042', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-045', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-047', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-MEZ-048', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Bloco 16 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL16-COB-000', 'BL16-000-000', 'BL16-000-000', 'Bloco 16 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 17 - Todos', 'Descrição do ativo', 'F', 0, 0, 2920,93, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-000', 'BL17-000-000', 'BL17-000-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-001', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-002', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-003', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-004', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-005', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-006', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-007', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-008', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-009', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-010', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-013', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-014', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-015', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-016', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-017', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-018', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-019', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-020', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-021', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-022', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-023', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-024', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-025', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-026', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-027', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-028', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-029', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-030', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-031', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-032', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-033', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-034', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-035', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-042', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-044', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-046', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-048', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-050', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-052', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-054', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-056', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-058', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-060', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-062', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-064', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-066', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-068', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-070', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-072', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-074', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-076', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALS-078', 'BL17-ALS-000', 'BL17-ALS-000', 'Bloco 17 - Ala Superior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-000', 'BL17-000-000', 'BL17-000-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-001', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-002', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-003', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-004', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-005', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-006', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-007', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-008', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-009', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-010', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-011', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-012', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-013', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-014', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-015', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-016', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-017', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-018', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-019', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-020', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-021', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-022', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-023', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-024', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-025', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-026', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-027', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-028', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-029', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-030', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-031', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-032', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-033', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-034', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-035', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-037', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-038', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-039', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-040', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-043', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-044', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-048', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-052', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-054', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-056', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-058', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-060', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-062', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-064', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-066', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-068', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-070', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-072', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-074', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-076', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-078', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-080', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-082', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-ALI-084', 'BL17-ALI-000', 'BL17-ALI-000', 'Bloco 17 - Ala Inferior', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-000', 'BL17-000-000', 'BL17-000-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-011', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-013', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-015', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-017', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-019', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-021', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-023', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-025', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-027', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-031', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-033', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-035', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-037', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-039', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-041', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-043', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-045', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-047', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-071', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-077', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-081', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-082', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-083', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-084', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-085', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-086', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-089', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-091', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-093', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-094', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-095', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-096', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL17-COB-097', 'BL17-COB-000', 'BL17-COB-000', 'Bloco 17 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 18 - Todos', 'Descrição do ativo', 'F', 0, 0, 842,08, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-000', 'BL18-000-000', 'BL18-000-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-001', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-002', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-003', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-004', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-005', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-006', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-007', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-008', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-009', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-012', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-013', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-014', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-015', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-017', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-021', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-022', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-023', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-025', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-026', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-027', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-028', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-029', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-031', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-032', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-033', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-034', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-041', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-042', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-043', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-TER-044', 'BL18-TER-000', 'BL18-TER-000', 'Bloco 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-000', 'BL18-000-000', 'BL18-000-000', 'Bloco 18 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-001', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-003', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-007', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-009', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-013', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-017', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-021', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-023', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-027', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL18-COB-029', 'BL18-COB-000', 'BL18-COB-000', 'Bloco 18 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 19 - Todos', 'Descrição do ativo', 'F', 0, 0, 3713,23, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-000', 'BL19-000-000', 'BL19-000-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-001', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-002', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-003', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-004', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-005', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-006', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-007', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-008', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-009', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-010', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-011', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-012', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-013', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-014', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-015', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-016', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-017', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-018', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-019', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-026', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-039', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-040', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-041', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-042', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-043', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-044', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-045', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-046', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-047', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-048', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-049', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-060', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-062', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-064', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-TER-070', 'BL19-TER-000', 'BL19-TER-000', 'Bloco 19 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-MEZ-000', 'BL19-000-000', 'BL19-000-000', 'Bloco 19 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-MEZ-009', 'BL19-MEZ-000', 'BL19-MEZ-000', 'Bloco 19 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-000', 'BL19-000-000', 'BL19-000-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-002', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-004', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-006', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-008', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-009', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-011', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-013', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-015', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-017', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-019', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-040', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-042', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-044', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-046', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-048', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL19-COB-049', 'BL19-COB-000', 'BL19-COB-000', 'Bloco 19 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 20 - Todos', 'Descrição do ativo', 'F', 0, 0, 274,2, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-000', 'BL20-000-000', 'BL20-000-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-001', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-004', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-008', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-011', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-012', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-014', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-015', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-016', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-018', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-021', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-022', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-TER-028', 'BL20-TER-000', 'BL20-TER-000', 'Bloco 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-MEZ-000', 'BL20-000-000', 'BL20-000-000', 'Bloco 20 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-MEZ-016', 'BL20-MEZ-000', 'BL20-MEZ-000', 'Bloco 20 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL20-COB-000', 'BL20-000-000', 'BL20-000-000', 'Bloco 20 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-000-000', 'CASF-000-000', 'CASF-000-000', 'Bloco 21 - Todos', 'Descrição do ativo', 'F', 0, 0, 447,28, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-000', 'BL21-000-000', 'BL21-000-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-001', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-002', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-003', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-012', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-014', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-016', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-021', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-023', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-025', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-027', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-TER-029', 'BL21-TER-000', 'BL21-TER-000', 'Bloco 21 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-MEZ-000', 'BL21-000-000', 'BL21-000-000', 'Bloco 21 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-MEZ-001', 'BL21-MEZ-000', 'BL21-MEZ-000', 'Bloco 21 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-COB-000', 'BL21-000-000', 'BL21-000-000', 'Bloco 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-COB-001', 'BL21-COB-000', 'BL21-COB-000', 'Bloco 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-COB-003', 'BL21-COB-000', 'BL21-COB-000', 'Bloco 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-COB-012', 'BL21-COB-000', 'BL21-COB-000', 'Bloco 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('BL21-COB-014', 'BL21-COB-000', 'BL21-COB-000', 'Bloco 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-000-000', 'CASF-000-000', 'CASF-000-000', 'SHIS QL12 CJ11 Casa 01 - Todos', 'Descrição do ativo', 'F', -15,829342, -47,861281, 979,67, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-000', 'SHIS-000-000', 'SHIS-000-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-001', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-002', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-003', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-004', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-005', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-006', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-007', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-008', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-009', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-010', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-012', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-013', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-014', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-015', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-018', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-019', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-020', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-024', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-026', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-030', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-032', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-038', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-040', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-041', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-042', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-043', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-044', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-045', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-046', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-050', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-052', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-060', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-064', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-066', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-068', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-069', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-070', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-074', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-090', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-092', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-TER-094', 'SHIS-TER-000', 'SHIS-TER-000', 'SHIS QL12 CJ11 Casa 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-000', 'SHIS-000-000', 'SHIS-000-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-003', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-004', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-005', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-006', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-007', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-008', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-010', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-012', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-013', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-019', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-020', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-024', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-030', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('SHIS-COB-038', 'SHIS-COB-000', 'SHIS-COB-000', 'SHIS QL12 CJ11 Casa 01 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-000-000', 'CASF-000-000', 'CASF-000-000', 'SQS 309 BL C - Todos', 'Descrição do ativo', 'F', -15,816814, -47,909043, 8260,33, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-001', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-002', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-003', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-004', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-005', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-006', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-007', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-008', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-009', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-010', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-011', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-012', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-023', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-024', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-029', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-SS1-030', '309C-SS1-000', '309C-SS1-000', 'SQS 309 BL C - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-001', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-002', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-003', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-004', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-005', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-006', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-007', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-008', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-009', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-010', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-011', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-012', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-021', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-022', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-023', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-024', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-025', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-026', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-027', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-028', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-029', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-060', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-062', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-064', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-066', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-068', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-070', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-072', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-074', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-076', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-080', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-082', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-084', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-086', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-TER-088', '309C-TER-000', '309C-TER-000', 'SQS 309 BL C - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-001', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-003', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-101', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-102', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-103', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-104', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-111', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-112', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-113', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-114', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-121', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-122', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-123', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P01-124', '309C-P01-000', '309C-P01-000', 'SQS 309 BL C - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-001', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-003', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-201', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-202', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-203', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-204', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-211', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-212', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-213', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-214', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-221', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-222', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-223', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P02-224', '309C-P02-000', '309C-P02-000', 'SQS 309 BL C - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-001', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-003', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-301', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-302', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-303', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-304', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-311', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-312', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-313', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-314', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-321', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-322', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-323', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P03-324', '309C-P03-000', '309C-P03-000', 'SQS 309 BL C - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-001', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-003', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-401', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-402', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-403', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-404', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-411', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-412', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-413', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-414', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-421', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-422', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-423', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P04-424', '309C-P04-000', '309C-P04-000', 'SQS 309 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-001', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-003', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-501', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-502', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-503', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-504', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-511', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-512', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-513', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-514', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-521', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-522', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-523', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P05-524', '309C-P05-000', '309C-P05-000', 'SQS 309 BL C - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-001', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-003', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-601', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-602', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-603', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-604', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-611', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-612', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-613', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-614', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-621', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-622', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-623', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-P06-624', '309C-P06-000', '309C-P06-000', 'SQS 309 BL C - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-000', '309C-000-000', '309C-000-000', 'SQS 309 BL C - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-001', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-003', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-011', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-012', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-013', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-014', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-021', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-022', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-023', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309C-COB-024', '309C-COB-000', '309C-COB-000', 'SQS 309 BL C - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-000-000', 'CASF-000-000', 'CASF-000-000', 'SQS 309 BL D - Todos', 'Descrição do ativo', 'F', -15,816553, -47,907293, 8282,38, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-001', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-002', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-003', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-004', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-005', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-006', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-007', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-008', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-009', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-010', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-011', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-012', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-023', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-024', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-029', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-030', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-031', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-SS1-032', '309D-SS1-000', '309D-SS1-000', 'SQS 309 BL D - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-001', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-002', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-003', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-004', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-005', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-006', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-007', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-008', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-009', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-010', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-011', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-012', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-023', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-024', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-025', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-026', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-027', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-028', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-029', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-030', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-050', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-060', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-062', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-064', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-066', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-068', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-070', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-072', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-074', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-076', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-078', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-080', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-082', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-084', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-086', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-088', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-092', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-094', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-096', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-TER-098', '309D-TER-000', '309D-TER-000', 'SQS 309 BL D - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-001', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-003', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-101', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-102', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-103', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-104', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-111', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-112', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-113', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-114', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-121', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-122', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-123', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P01-124', '309D-P01-000', '309D-P01-000', 'SQS 309 BL D - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-001', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-003', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-201', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-202', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-203', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-204', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-211', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-212', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-213', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-214', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-221', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-222', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-223', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P02-224', '309D-P02-000', '309D-P02-000', 'SQS 309 BL D - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-001', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-003', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-301', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-302', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-303', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-304', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-311', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-312', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-313', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-314', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-321', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-322', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-323', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P03-324', '309D-P03-000', '309D-P03-000', 'SQS 309 BL D - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-001', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-003', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-401', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-402', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-403', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-404', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-411', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-412', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-413', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-414', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-421', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-422', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-423', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P04-424', '309D-P04-000', '309D-P04-000', 'SQS 309 BL D - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-001', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-003', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-501', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-502', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-503', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-504', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-511', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-512', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-513', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-514', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-521', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-522', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-523', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P05-524', '309D-P05-000', '309D-P05-000', 'SQS 309 BL D - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-001', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-003', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-601', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-602', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-603', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-604', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-611', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-612', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-613', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-614', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-621', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-622', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-623', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-P06-624', '309D-P06-000', '309D-P06-000', 'SQS 309 BL D - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-000', '309D-000-000', '309D-000-000', 'SQS 309 BL D - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-001', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-003', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-011', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-012', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-013', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-014', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-021', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-022', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-023', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309D-COB-024', '309D-COB-000', '309D-COB-000', 'SQS 309 BL D - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-000-000', 'CASF-000-000', 'CASF-000-000', 'SQS 309 BL G - Todos', 'Descrição do ativo', 'F', 0, 0, 8260,33, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-001', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-002', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-003', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-004', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-005', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-006', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-007', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-008', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-009', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-010', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-011', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-012', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-023', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-024', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-029', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-SS1-030', '309G-SS1-000', '309G-SS1-000', 'SQS 309 BL G - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-001', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-002', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-003', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-004', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-005', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-006', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-007', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-008', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-009', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-010', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-011', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-012', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-023', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-024', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-025', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-026', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-027', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-028', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-029', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-031', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-050', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-052', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-054', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-056', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-060', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-062', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-064', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-066', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-068', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-070', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-072', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-074', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-076', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-078', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-082', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-084', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-086', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-TER-088', '309G-TER-000', '309G-TER-000', 'SQS 309 BL G - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-001', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-003', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-101', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-102', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-103', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-104', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-111', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-112', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-113', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-114', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-121', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-122', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-123', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P01-124', '309G-P01-000', '309G-P01-000', 'SQS 309 BL G - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-001', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-003', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-201', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-202', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-203', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-204', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-211', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-212', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-213', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-214', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-221', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-222', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-223', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P02-224', '309G-P02-000', '309G-P02-000', 'SQS 309 BL G - 2º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-001', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-003', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-301', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-302', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-303', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-304', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-311', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-312', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-313', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-314', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-321', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-322', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-323', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P03-324', '309G-P03-000', '309G-P03-000', 'SQS 309 BL G - 3º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-001', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-003', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-401', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-402', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-403', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-404', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-411', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-412', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-413', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-414', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-421', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-422', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-423', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P04-424', '309G-P04-000', '309G-P04-000', 'SQS 309 BL G - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-001', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-003', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-501', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-502', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-503', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-504', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-511', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-512', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-513', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-514', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-521', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-522', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-523', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P05-524', '309G-P05-000', '309G-P05-000', 'SQS 309 BL G - 5º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-001', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-003', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-601', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-602', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-603', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-604', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-611', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-612', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-613', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-614', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-621', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-622', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-623', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-P06-624', '309G-P06-000', '309G-P06-000', 'SQS 309 BL G - 6º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-000', '309G-000-000', '309G-000-000', 'SQS 309 BL G - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-001', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-003', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-011', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-012', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-013', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-014', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-021', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-022', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-023', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('309G-COB-024', '309G-COB-000', '309G-COB-000', 'SQS 309 BL G - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('316C-000-000', 'CASF-000-000', 'CASF-000-000', 'SQS 316 BL C - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('316C-P04-000', '316C-000-000', '316C-000-000', 'SQS 316 BL C - 4º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 01 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-000', 'AT01-000-000', 'AT01-000-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-001', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-002', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-003', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-004', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-005', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-006', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-007', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-008', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-009', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-010', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-011', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-012', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-013', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-014', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-021', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-022', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-023', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-024', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-031', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-041', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-042', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-043', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT01-SS2-050', 'AT01-SS2-000', 'AT01-SS2-000', 'Área técnica 01 - 2º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT02-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 02 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT02-SS1-000', 'AT02-000-000', 'AT02-000-000', 'Área técnica 02 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT02-TER-000', 'AT02-000-000', 'AT02-000-000', 'Área técnica 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT02-TER-001', 'AT02-TER-000', 'AT02-TER-000', 'Área técnica 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT03-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 03 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT03-SS1-000', 'AT03-000-000', 'AT03-000-000', 'Área técnica 03 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT03-TER-000', 'AT03-000-000', 'AT03-000-000', 'Área técnica 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT03-TER-001', 'AT03-TER-000', 'AT03-TER-000', 'Área técnica 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 10 - Todos', 'Descrição do ativo', 'F', 0, 0, 1325,42, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-000', 'AT10-000-000', 'AT10-000-000', 'Área técnica 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-002', 'AT10-SEM-000', 'AT10-SEM-000', 'Área técnica 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-003', 'AT10-SEM-000', 'AT10-SEM-000', 'Área técnica 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-004', 'AT10-SEM-000', 'AT10-SEM-000', 'Área técnica 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-005', 'AT10-SEM-000', 'AT10-SEM-000', 'Área técnica 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-SEM-007', 'AT10-SEM-000', 'AT10-SEM-000', 'Área técnica 10 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-000', 'AT10-000-000', 'AT10-000-000', 'Área técnica 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-001', 'AT10-COB-000', 'AT10-COB-000', 'Área técnica 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-002', 'AT10-COB-000', 'AT10-COB-000', 'Área técnica 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-003', 'AT10-COB-000', 'AT10-COB-000', 'Área técnica 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-004', 'AT10-COB-000', 'AT10-COB-000', 'Área técnica 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT10-COB-006', 'AT10-COB-000', 'AT10-COB-000', 'Área técnica 10 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT11-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 11 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT11-TER-000', 'AT11-000-000', 'AT11-000-000', 'Área técnica 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT11-TER-001', 'AT11-TER-000', 'AT11-TER-000', 'Área técnica 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT11-COB-000', 'AT11-000-000', 'AT11-000-000', 'Área técnica 11 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT12-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 12 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT12-SS1-000', 'AT12-000-000', 'AT12-000-000', 'Área técnica 12 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT12-TER-000', 'AT12-000-000', 'AT12-000-000', 'Área técnica 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT12-TER-001', 'AT12-TER-000', 'AT12-TER-000', 'Área técnica 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT12-TER-002', 'AT12-TER-000', 'AT12-TER-000', 'Área técnica 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 13 - Todos', 'Descrição do ativo', 'F', 0, 0, 623,29, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-000', 'AT13-000-000', 'AT13-000-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-001', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-005', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-008', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-011', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-013', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-014', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-015', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-016', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-017', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-018', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-020', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-021', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-022', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-025', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-029', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-033', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-035', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-037', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-038', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-041', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-043', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-SS1-045', 'AT13-SS1-000', 'AT13-SS1-000', 'Área técnica 13 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-000', 'AT13-000-000', 'AT13-000-000', 'Área técnica 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-008', 'AT13-TER-000', 'AT13-TER-000', 'Área técnica 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-020', 'AT13-TER-000', 'AT13-TER-000', 'Área técnica 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-029', 'AT13-TER-000', 'AT13-TER-000', 'Área técnica 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-033', 'AT13-TER-000', 'AT13-TER-000', 'Área técnica 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT13-TER-037', 'AT13-TER-000', 'AT13-TER-000', 'Área técnica 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 14 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-000', 'AT14-000-000', 'AT14-000-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-001', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-002', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-003', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-004', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-005', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-006', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-007', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-008', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-009', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-010', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-011', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-012', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-SS1-013', 'AT14-SS1-000', 'AT14-SS1-000', 'Área técnica 14 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-000', 'AT14-000-000', 'AT14-000-000', 'Área técnica 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-001', 'AT14-TER-000', 'AT14-TER-000', 'Área técnica 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-003', 'AT14-TER-000', 'AT14-TER-000', 'Área técnica 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-005', 'AT14-TER-000', 'AT14-TER-000', 'Área técnica 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-007', 'AT14-TER-000', 'AT14-TER-000', 'Área técnica 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-009', 'AT14-TER-000', 'AT14-TER-000', 'Área técnica 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-011', 'AT14-TER-000', 'AT14-TER-000', 'Área técnica 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT14-TER-013', 'AT14-TER-000', 'AT14-TER-000', 'Área técnica 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 20 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-SS1-000', 'AT20-000-000', 'AT20-000-000', 'Área técnica 20 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-SS1-001', 'AT20-SS1-000', 'AT20-SS1-000', 'Área técnica 20 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-SS1-002', 'AT20-SS1-000', 'AT20-SS1-000', 'Área técnica 20 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-SS1-003', 'AT20-SS1-000', 'AT20-SS1-000', 'Área técnica 20 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-SS1-004', 'AT20-SS1-000', 'AT20-SS1-000', 'Área técnica 20 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-TER-000', 'AT20-000-000', 'AT20-000-000', 'Área técnica 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-TER-001', 'AT20-TER-000', 'AT20-TER-000', 'Área técnica 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT20-TER-002', 'AT20-TER-000', 'AT20-TER-000', 'Área técnica 20 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 21 - Todos', 'Descrição do ativo', 'F', 0, 0, 1855,91, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-000', 'AT21-000-000', 'AT21-000-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-001', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-002', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-003', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-004', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-005', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-006', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-010', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-011', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-012', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-013', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-014', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-015', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-016', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-023', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-024', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-025', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-026', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-033', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-034', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-035', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-036', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-SEM-040', 'AT21-SEM-000', 'AT21-SEM-000', 'Área técnica 21 - Pavimento Semienterrado', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-000', 'AT21-000-000', 'AT21-000-000', 'Área técnica 21 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-011', 'AT21-MEZ-000', 'AT21-MEZ-000', 'Área técnica 21 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-012', 'AT21-MEZ-000', 'AT21-MEZ-000', 'Área técnica 21 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-013', 'AT21-MEZ-000', 'AT21-MEZ-000', 'Área técnica 21 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-014', 'AT21-MEZ-000', 'AT21-MEZ-000', 'Área técnica 21 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-015', 'AT21-MEZ-000', 'AT21-MEZ-000', 'Área técnica 21 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-023', 'AT21-MEZ-000', 'AT21-MEZ-000', 'Área técnica 21 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-MEZ-035', 'AT21-MEZ-000', 'AT21-MEZ-000', 'Área técnica 21 - Mezanino', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-000', 'AT21-000-000', 'AT21-000-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-001', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-002', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-003', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-004', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-005', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-006', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-011', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-012', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-013', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-014', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-015', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-016', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-033', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-034', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-035', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT21-COB-036', 'AT21-COB-000', 'AT21-COB-000', 'Área técnica 21 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT22-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 22 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT22-TER-000', 'AT22-000-000', 'AT22-000-000', 'Área técnica 22 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT22-TER-001', 'AT22-TER-000', 'AT22-TER-000', 'Área técnica 22 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT22-COB-000', 'AT22-000-000', 'AT22-000-000', 'Área técnica 22 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT23-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 23 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT23-TER-000', 'AT23-000-000', 'AT23-000-000', 'Área técnica 23 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT23-TER-001', 'AT23-TER-000', 'AT23-TER-000', 'Área técnica 23 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT23-COB-000', 'AT23-000-000', 'AT23-000-000', 'Área técnica 23 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT23-COB-001', 'AT23-COB-000', 'AT23-COB-000', 'Área técnica 23 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 24 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-SS1-000', 'AT24-000-000', 'AT24-000-000', 'Área técnica 24 - 1º Subsolo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-TER-000', 'AT24-000-000', 'AT24-000-000', 'Área técnica 24 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-TER-001', 'AT24-TER-000', 'AT24-TER-000', 'Área técnica 24 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-TER-002', 'AT24-TER-000', 'AT24-TER-000', 'Área técnica 24 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-TER-011', 'AT24-TER-000', 'AT24-TER-000', 'Área técnica 24 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT24-TER-012', 'AT24-TER-000', 'AT24-TER-000', 'Área técnica 24 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT30-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 30 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT30-TER-000', 'AT30-000-000', 'AT30-000-000', 'Área técnica 30 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT30-TER-001', 'AT30-TER-000', 'AT30-TER-000', 'Área técnica 30 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT30-TER-002', 'AT30-TER-000', 'AT30-TER-000', 'Área técnica 30 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 31 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-000', 'AT31-000-000', 'AT31-000-000', 'Área técnica 31 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-001', 'AT31-TER-000', 'AT31-TER-000', 'Área técnica 31 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-002', 'AT31-TER-000', 'AT31-TER-000', 'Área técnica 31 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-003', 'AT31-TER-000', 'AT31-TER-000', 'Área técnica 31 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-004', 'AT31-TER-000', 'AT31-TER-000', 'Área técnica 31 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-005', 'AT31-TER-000', 'AT31-TER-000', 'Área técnica 31 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-006', 'AT31-TER-000', 'AT31-TER-000', 'Área técnica 31 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-TER-007', 'AT31-TER-000', 'AT31-TER-000', 'Área técnica 31 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-000', 'AT31-000-000', 'AT31-000-000', 'Área técnica 31 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-001', 'AT31-COB-000', 'AT31-COB-000', 'Área técnica 31 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-002', 'AT31-COB-000', 'AT31-COB-000', 'Área técnica 31 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-003', 'AT31-COB-000', 'AT31-COB-000', 'Área técnica 31 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-004', 'AT31-COB-000', 'AT31-COB-000', 'Área técnica 31 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-012', 'AT31-COB-000', 'AT31-COB-000', 'Área técnica 31 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT31-COB-013', 'AT31-COB-000', 'AT31-COB-000', 'Área técnica 31 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT32-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 32 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT32-TER-000', 'AT32-000-000', 'AT32-000-000', 'Área técnica 32 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT32-TER-001', 'AT32-TER-000', 'AT32-TER-000', 'Área técnica 32 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT32-TER-002', 'AT32-TER-000', 'AT32-TER-000', 'Área técnica 32 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 33 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-TER-000', 'AT33-000-000', 'AT33-000-000', 'Área técnica 33 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-TER-001', 'AT33-TER-000', 'AT33-TER-000', 'Área técnica 33 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-TER-002', 'AT33-TER-000', 'AT33-TER-000', 'Área técnica 33 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-TER-003', 'AT33-TER-000', 'AT33-TER-000', 'Área técnica 33 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-TER-004', 'AT33-TER-000', 'AT33-TER-000', 'Área técnica 33 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT33-COB-000', 'AT33-000-000', 'AT33-000-000', 'Área técnica 33 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT40-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 40 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT40-TER-000', 'AT40-000-000', 'AT40-000-000', 'Área técnica 40 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT40-TER-001', 'AT40-TER-000', 'AT40-TER-000', 'Área técnica 40 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT40-TER-002', 'AT40-TER-000', 'AT40-TER-000', 'Área técnica 40 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT40-COB-000', 'AT40-000-000', 'AT40-000-000', 'Área técnica 40 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT41-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 41 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT41-TER-000', 'AT41-000-000', 'AT41-000-000', 'Área técnica 41 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT41-TER-001', 'AT41-TER-000', 'AT41-TER-000', 'Área técnica 41 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT41-COB-000', 'AT41-000-000', 'AT41-000-000', 'Área técnica 41 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 42 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-TER-000', 'AT42-000-000', 'AT42-000-000', 'Área técnica 42 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-TER-001', 'AT42-TER-000', 'AT42-TER-000', 'Área técnica 42 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-TER-002', 'AT42-TER-000', 'AT42-TER-000', 'Área técnica 42 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-TER-003', 'AT42-TER-000', 'AT42-TER-000', 'Área técnica 42 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-COB-000', 'AT42-000-000', 'AT42-000-000', 'Área técnica 42 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-COB-001', 'AT42-COB-000', 'AT42-COB-000', 'Área técnica 42 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-COB-002', 'AT42-COB-000', 'AT42-COB-000', 'Área técnica 42 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT42-COB-003', 'AT42-COB-000', 'AT42-COB-000', 'Área técnica 42 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT43-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 43 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT43-TER-000', 'AT43-000-000', 'AT43-000-000', 'Área técnica 43 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT43-TER-001', 'AT43-TER-000', 'AT43-TER-000', 'Área técnica 43 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT43-TER-002', 'AT43-TER-000', 'AT43-TER-000', 'Área técnica 43 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 44 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-TER-000', 'AT44-000-000', 'AT44-000-000', 'Área técnica 44 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-COB-000', 'AT44-000-000', 'AT44-000-000', 'Área técnica 44 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-COB-001', 'AT44-COB-000', 'AT44-COB-000', 'Área técnica 44 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-COB-003', 'AT44-COB-000', 'AT44-COB-000', 'Área técnica 44 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-COB-005', 'AT44-COB-000', 'AT44-COB-000', 'Área técnica 44 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT44-COB-006', 'AT44-COB-000', 'AT44-COB-000', 'Área técnica 44 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 50 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-000', 'AT50-000-000', 'AT50-000-000', 'Área técnica 50 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-002', 'AT50-TER-000', 'AT50-TER-000', 'Área técnica 50 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-008', 'AT50-TER-000', 'AT50-TER-000', 'Área técnica 50 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-015', 'AT50-TER-000', 'AT50-TER-000', 'Área técnica 50 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-022', 'AT50-TER-000', 'AT50-TER-000', 'Área técnica 50 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-025', 'AT50-TER-000', 'AT50-TER-000', 'Área técnica 50 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-028', 'AT50-TER-000', 'AT50-TER-000', 'Área técnica 50 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-035', 'AT50-TER-000', 'AT50-TER-000', 'Área técnica 50 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-TER-045', 'AT50-TER-000', 'AT50-TER-000', 'Área técnica 50 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-COB-000', 'AT50-000-000', 'AT50-000-000', 'Área técnica 50 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-COB-015', 'AT50-COB-000', 'AT50-COB-000', 'Área técnica 50 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-COB-025', 'AT50-COB-000', 'AT50-COB-000', 'Área técnica 50 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-COB-035', 'AT50-COB-000', 'AT50-COB-000', 'Área técnica 50 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT50-COB-045', 'AT50-COB-000', 'AT50-COB-000', 'Área técnica 50 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT51-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 51 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT51-TER-000', 'AT51-000-000', 'AT51-000-000', 'Área técnica 51 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT51-TER-001', 'AT51-TER-000', 'AT51-TER-000', 'Área técnica 51 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT51-COB-000', 'AT51-000-000', 'AT51-000-000', 'Área técnica 51 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 52 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-TER-000', 'AT52-000-000', 'AT52-000-000', 'Área técnica 52 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-TER-002', 'AT52-TER-000', 'AT52-TER-000', 'Área técnica 52 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-TER-004', 'AT52-TER-000', 'AT52-TER-000', 'Área técnica 52 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-COB-000', 'AT52-000-000', 'AT52-000-000', 'Área técnica 52 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT52-COB-004', 'AT52-COB-000', 'AT52-COB-000', 'Área técnica 52 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 53 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-000', 'AT53-000-000', 'AT53-000-000', 'Área técnica 53 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-001', 'AT53-TER-000', 'AT53-TER-000', 'Área técnica 53 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-002', 'AT53-TER-000', 'AT53-TER-000', 'Área técnica 53 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-004', 'AT53-TER-000', 'AT53-TER-000', 'Área técnica 53 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-012', 'AT53-TER-000', 'AT53-TER-000', 'Área técnica 53 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-013', 'AT53-TER-000', 'AT53-TER-000', 'Área técnica 53 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-014', 'AT53-TER-000', 'AT53-TER-000', 'Área técnica 53 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-015', 'AT53-TER-000', 'AT53-TER-000', 'Área técnica 53 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-TER-016', 'AT53-TER-000', 'AT53-TER-000', 'Área técnica 53 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-COB-000', 'AT53-000-000', 'AT53-000-000', 'Área técnica 53 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-COB-001', 'AT53-COB-000', 'AT53-COB-000', 'Área técnica 53 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-COB-014', 'AT53-COB-000', 'AT53-COB-000', 'Área técnica 53 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT53-COB-016', 'AT53-COB-000', 'AT53-COB-000', 'Área técnica 53 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 60 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-000', 'AT60-000-000', 'AT60-000-000', 'Área técnica 60 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-002', 'AT60-TER-000', 'AT60-TER-000', 'Área técnica 60 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-003', 'AT60-TER-000', 'AT60-TER-000', 'Área técnica 60 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-005', 'AT60-TER-000', 'AT60-TER-000', 'Área técnica 60 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-011', 'AT60-TER-000', 'AT60-TER-000', 'Área técnica 60 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-013', 'AT60-TER-000', 'AT60-TER-000', 'Área técnica 60 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-015', 'AT60-TER-000', 'AT60-TER-000', 'Área técnica 60 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-022', 'AT60-TER-000', 'AT60-TER-000', 'Área técnica 60 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-023', 'AT60-TER-000', 'AT60-TER-000', 'Área técnica 60 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-TER-025', 'AT60-TER-000', 'AT60-TER-000', 'Área técnica 60 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-000', 'AT60-000-000', 'AT60-000-000', 'Área técnica 60 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-001', 'AT60-COB-000', 'AT60-COB-000', 'Área técnica 60 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-003', 'AT60-COB-000', 'AT60-COB-000', 'Área técnica 60 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-005', 'AT60-COB-000', 'AT60-COB-000', 'Área técnica 60 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-013', 'AT60-COB-000', 'AT60-COB-000', 'Área técnica 60 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-015', 'AT60-COB-000', 'AT60-COB-000', 'Área técnica 60 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-023', 'AT60-COB-000', 'AT60-COB-000', 'Área técnica 60 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT60-COB-025', 'AT60-COB-000', 'AT60-COB-000', 'Área técnica 60 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT61-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 61 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT61-P01-000', 'AT61-000-000', 'AT61-000-000', 'Área técnica 61 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT61-P01-001', 'AT61-P01-000', 'AT61-P01-000', 'Área técnica 61 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT61-P01-002', 'AT61-P01-000', 'AT61-P01-000', 'Área técnica 61 - 1º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT62-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 62 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT62-TER-000', 'AT62-000-000', 'AT62-000-000', 'Área técnica 62 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT62-TER-002', 'AT62-TER-000', 'AT62-TER-000', 'Área técnica 62 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT62-TER-003', 'AT62-TER-000', 'AT62-TER-000', 'Área técnica 62 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT62-TER-004', 'AT62-TER-000', 'AT62-TER-000', 'Área técnica 62 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 63 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-000', 'AT63-000-000', 'AT63-000-000', 'Área técnica 63 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-001', 'AT63-TER-000', 'AT63-TER-000', 'Área técnica 63 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-002', 'AT63-TER-000', 'AT63-TER-000', 'Área técnica 63 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-003', 'AT63-TER-000', 'AT63-TER-000', 'Área técnica 63 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-004', 'AT63-TER-000', 'AT63-TER-000', 'Área técnica 63 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT63-TER-005', 'AT63-TER-000', 'AT63-TER-000', 'Área técnica 63 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT64-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 64 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT64-TER-000', 'AT64-000-000', 'AT64-000-000', 'Área técnica 64 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT64-TER-001', 'AT64-TER-000', 'AT64-TER-000', 'Área técnica 64 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 65 - Todos', 'Descrição do ativo', 'F', 0, 0, 199,06, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-000', 'AT65-000-000', 'AT65-000-000', 'Área técnica 65 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-008', 'AT65-P11-000', 'AT65-P11-000', 'Área técnica 65 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-009', 'AT65-P11-000', 'AT65-P11-000', 'Área técnica 65 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-010', 'AT65-P11-000', 'AT65-P11-000', 'Área técnica 65 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-011', 'AT65-P11-000', 'AT65-P11-000', 'Área técnica 65 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-018', 'AT65-P11-000', 'AT65-P11-000', 'Área técnica 65 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-019', 'AT65-P11-000', 'AT65-P11-000', 'Área técnica 65 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-020', 'AT65-P11-000', 'AT65-P11-000', 'Área técnica 65 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-021', 'AT65-P11-000', 'AT65-P11-000', 'Área técnica 65 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P11-030', 'AT65-P11-000', 'AT65-P11-000', 'Área técnica 65 - 11º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-000', 'AT65-000-000', 'AT65-000-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-001', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-002', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-003', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-004', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-005', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-006', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-007', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-008', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-009', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-010', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-011', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-012', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-013', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-014', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-015', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-016', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-017', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-018', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-019', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-020', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-021', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-022', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-026', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-027', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-028', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-030', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT65-P12-031', 'AT65-P12-000', 'AT65-P12-000', 'Área técnica 65 - 12º Pavimento', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT66-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 66 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT67-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 67 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT67-TER-000', 'AT67-000-000', 'AT67-000-000', 'Área técnica 67 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT67-TER-001', 'AT67-TER-000', 'AT67-TER-000', 'Área técnica 67 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT67-COB-000', 'AT67-000-000', 'AT67-000-000', 'Área técnica 67 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT67-COB-001', 'AT67-COB-000', 'AT67-COB-000', 'Área técnica 67 - Cobertura', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT70-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 70 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT71-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 71 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT72-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 72 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT73-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 73 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT74-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 74 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT75-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 75 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT76-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 76 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT77-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 77 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT78-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 78 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT79-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 79 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT80-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 80 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT81-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 81 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT82-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 82 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT83-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 83 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('AT84-000-000', 'CASF-000-000', 'CASF-000-000', 'Área técnica 84 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES01-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 01 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES01-TER-000', 'ES01-000-000', 'ES01-000-000', 'Estacionamento 01 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES01-TER-001', 'ES01-TER-000', 'ES01-TER-000', 'Estacionamento 01 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES01-TER-002', 'ES01-TER-000', 'ES01-TER-000', 'Estacionamento 01 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES01-TER-003', 'ES01-TER-000', 'ES01-TER-000', 'Estacionamento 01 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 02 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-000', 'ES02-000-000', 'ES02-000-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-001', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-003', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-005', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-007', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-011', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-013', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-014', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-016', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-017', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-018', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-019', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-020', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-025', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES02-TER-027', 'ES02-TER-000', 'ES02-TER-000', 'Estacionamento 02 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 03 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-TER-000', 'ES03-000-000', 'ES03-000-000', 'Estacionamento 03 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-TER-001', 'ES03-TER-000', 'ES03-TER-000', 'Estacionamento 03 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-TER-002', 'ES03-TER-000', 'ES03-TER-000', 'Estacionamento 03 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-TER-003', 'ES03-TER-000', 'ES03-TER-000', 'Estacionamento 03 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES03-TER-004', 'ES03-TER-000', 'ES03-TER-000', 'Estacionamento 03 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 04 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-000', 'ES04-000-000', 'ES04-000-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-007', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-008', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-009', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-010', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-011', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-012', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-021', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-022', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-023', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-024', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-025', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-026', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-027', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-028', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-029', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-030', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-031', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-032', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-041', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-043', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-045', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-051', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-052', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-053', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-054', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-055', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-061', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-062', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-063', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-064', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-065', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-091', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-092', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-093', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-094', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-095', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-096', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-097', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-098', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES04-TER-099', 'ES04-TER-000', 'ES04-TER-000', 'Estacionamento 04 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 05 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-000', 'ES05-000-000', 'ES05-000-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-001', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-005', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-009', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-011', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-015', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-019', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-021', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-029', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-031', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-033', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-035', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-037', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-039', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-041', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-049', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-051', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-055', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-059', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-061', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-062', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-063', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-064', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-065', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-066', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-067', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-068', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-069', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-070', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-071', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-072', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-073', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-074', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-083', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES05-TER-089', 'ES05-TER-000', 'ES05-TER-000', 'Estacionamento 05 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 06 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-000', 'ES06-000-000', 'ES06-000-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-001', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-003', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-005', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-011', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-013', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-015', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-017', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-019', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-021', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-023', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-031', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-033', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-035', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-041', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-043', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-045', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-047', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-049', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-051', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-053', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-055', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-057', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-059', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-061', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES06-TER-071', 'ES06-TER-000', 'ES06-TER-000', 'Estacionamento 06 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 07 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-000', 'ES07-000-000', 'ES07-000-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-001', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-005', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-007', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-009', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-011', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-012', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-013', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-014', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-015', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-016', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-017', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-019', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-020', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-021', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-023', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-024', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-025', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-026', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-027', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-031', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-032', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-033', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-034', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-035', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-036', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-037', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-039', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-040', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-041', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-043', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-044', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-045', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-046', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-047', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-051', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-052', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-053', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-054', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-055', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-056', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-057', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-059', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-060', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-061', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-063', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-064', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-065', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-066', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-067', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-071', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-072', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-073', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-074', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-075', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-076', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-077', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-079', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-080', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-081', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-083', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-084', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-087', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES07-TER-090', 'ES07-TER-000', 'ES07-TER-000', 'Estacionamento 07 - Pavimento Térreo ', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 08 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-000', 'ES08-000-000', 'ES08-000-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-001', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-003', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-005', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-011', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-013', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-015', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-025', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-027', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-035', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-037', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-039', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-045', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-047', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES08-TER-049', 'ES08-TER-000', 'ES08-TER-000', 'Estacionamento 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 09 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-000', 'ES09-000-000', 'ES09-000-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-001', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-003', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-005', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-011', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-013', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-015', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-021', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-023', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-025', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-031', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-033', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES09-TER-035', 'ES09-TER-000', 'ES09-TER-000', 'Estacionamento 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 10 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-000', 'ES10-000-000', 'ES10-000-000', 'Estacionamento 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-001', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-003', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-005', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-011', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-013', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-021', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-023', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES10-TER-025', 'ES10-TER-000', 'ES10-TER-000', 'Estacionamento 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 11 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-000', 'ES11-000-000', 'ES11-000-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-007', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-008', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-009', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-010', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-011', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-012', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-013', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-014', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-015', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-016', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-017', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-018', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-019', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-020', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-021', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-022', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-023', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-031', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-032', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-033', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-034', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-035', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-036', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-037', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-038', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-039', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-040', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-041', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-042', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-043', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-044', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-045', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-046', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-047', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-048', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-049', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-050', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-051', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-052', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-053', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-061', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-062', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-063', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-064', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-065', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-066', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-067', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-068', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-069', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-070', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-071', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-072', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-073', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-074', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-075', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-076', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-077', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-078', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-079', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-080', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-081', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-082', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES11-TER-083', 'ES11-TER-000', 'ES11-TER-000', 'Estacionamento 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-000-000', 'CASF-000-000', 'CASF-000-000', 'Estacionamento 12 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-000', 'ES12-000-000', 'ES12-000-000', 'Estacionamento 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-001', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-011', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-012', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-013', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-014', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-021', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-022', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-023', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ES12-TER-024', 'ES12-TER-000', 'ES12-TER-000', 'Estacionamento 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 01 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-000', 'JA01-000-000', 'JA01-000-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-001', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-005', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-007', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-011', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-025', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-027', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-031', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-045', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-047', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-051', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-065', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA01-TER-067', 'JA01-TER-000', 'JA01-TER-000', 'Jardim 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 02 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-000', 'JA02-000-000', 'JA02-000-000', 'Jardim 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-001', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-011', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-021', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-031', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-041', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-051', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-061', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-071', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-081', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA02-TER-091', 'JA02-TER-000', 'JA02-TER-000', 'Jardim 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 03 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-000', 'JA03-000-000', 'JA03-000-000', 'Jardim 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-001', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-003', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-005', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-007', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-009', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-011', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-025', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-039', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA03-TER-041', 'JA03-TER-000', 'JA03-TER-000', 'Jardim 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 04 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-000', 'JA04-000-000', 'JA04-000-000', 'Jardim 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-001', 'JA04-TER-000', 'JA04-TER-000', 'Jardim 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-003', 'JA04-TER-000', 'JA04-TER-000', 'Jardim 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-005', 'JA04-TER-000', 'JA04-TER-000', 'Jardim 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-007', 'JA04-TER-000', 'JA04-TER-000', 'Jardim 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA04-TER-009', 'JA04-TER-000', 'JA04-TER-000', 'Jardim 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 05 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-000', 'JA05-000-000', 'JA05-000-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-003', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-013', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-015', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-021', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-023', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-025', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-031', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-035', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-041', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-043', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA05-TER-045', 'JA05-TER-000', 'JA05-TER-000', 'Jardim 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 06 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-TER-000', 'JA06-000-000', 'JA06-000-000', 'Jardim 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-TER-001', 'JA06-TER-000', 'JA06-TER-000', 'Jardim 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-TER-003', 'JA06-TER-000', 'JA06-TER-000', 'Jardim 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-TER-005', 'JA06-TER-000', 'JA06-TER-000', 'Jardim 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA06-TER-007', 'JA06-TER-000', 'JA06-TER-000', 'Jardim 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 07 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-000', 'JA07-000-000', 'JA07-000-000', 'Jardim 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-001', 'JA07-TER-000', 'JA07-TER-000', 'Jardim 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-003', 'JA07-TER-000', 'JA07-TER-000', 'Jardim 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-005', 'JA07-TER-000', 'JA07-TER-000', 'Jardim 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-007', 'JA07-TER-000', 'JA07-TER-000', 'Jardim 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA07-TER-009', 'JA07-TER-000', 'JA07-TER-000', 'Jardim 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 08 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-000', 'JA08-000-000', 'JA08-000-000', 'Jardim 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-001', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-003', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-005', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-007', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-009', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-011', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA08-TER-013', 'JA08-TER-000', 'JA08-TER-000', 'Jardim 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 09 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-000', 'JA09-000-000', 'JA09-000-000', 'Jardim 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-001', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-011', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-015', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-021', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-023', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA09-TER-025', 'JA09-TER-000', 'JA09-TER-000', 'Jardim 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 10 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-000', 'JA10-000-000', 'JA10-000-000', 'Jardim 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-001', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-003', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-005', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-007', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-009', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-011', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-013', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-015', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-017', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA10-TER-019', 'JA10-TER-000', 'JA10-TER-000', 'Jardim 10 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 11 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-000', 'JA11-000-000', 'JA11-000-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-001', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-003', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-005', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-007', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-009', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-011', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-021', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-023', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-025', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-027', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-029', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA11-TER-031', 'JA11-TER-000', 'JA11-TER-000', 'Jardim 11 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 12 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-000', 'JA12-000-000', 'JA12-000-000', 'Jardim 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-001', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-003', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-005', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-007', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-009', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-011', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA12-TER-013', 'JA12-TER-000', 'JA12-TER-000', 'Jardim 12 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 13 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-000', 'JA13-000-000', 'JA13-000-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-001', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-003', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-009', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-011', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-013', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-015', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-017', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-019', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-023', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-025', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA13-TER-027', 'JA13-TER-000', 'JA13-TER-000', 'Jardim 13 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 14 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-000', 'JA14-000-000', 'JA14-000-000', 'Jardim 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-001', 'JA14-TER-000', 'JA14-TER-000', 'Jardim 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-003', 'JA14-TER-000', 'JA14-TER-000', 'Jardim 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-005', 'JA14-TER-000', 'JA14-TER-000', 'Jardim 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-007', 'JA14-TER-000', 'JA14-TER-000', 'Jardim 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA14-TER-009', 'JA14-TER-000', 'JA14-TER-000', 'Jardim 14 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 15 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-000', 'JA15-000-000', 'JA15-000-000', 'Jardim 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-001', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-003', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-005', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-015', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-021', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA15-TER-025', 'JA15-TER-000', 'JA15-TER-000', 'Jardim 15 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 16 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-TER-000', 'JA16-000-000', 'JA16-000-000', 'Jardim 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-TER-001', 'JA16-TER-000', 'JA16-TER-000', 'Jardim 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-TER-011', 'JA16-TER-000', 'JA16-TER-000', 'Jardim 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-TER-021', 'JA16-TER-000', 'JA16-TER-000', 'Jardim 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA16-TER-031', 'JA16-TER-000', 'JA16-TER-000', 'Jardim 16 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 17 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-TER-000', 'JA17-000-000', 'JA17-000-000', 'Jardim 17 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-TER-001', 'JA17-TER-000', 'JA17-TER-000', 'Jardim 17 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-TER-011', 'JA17-TER-000', 'JA17-TER-000', 'Jardim 17 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-TER-021', 'JA17-TER-000', 'JA17-TER-000', 'Jardim 17 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA17-TER-031', 'JA17-TER-000', 'JA17-TER-000', 'Jardim 17 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-000-000', 'CASF-000-000', 'CASF-000-000', 'Jardim 18 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-000', 'JA18-000-000', 'JA18-000-000', 'Jardim 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-001', 'JA18-TER-000', 'JA18-TER-000', 'Jardim 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-007', 'JA18-TER-000', 'JA18-TER-000', 'Jardim 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-017', 'JA18-TER-000', 'JA18-TER-000', 'Jardim 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-027', 'JA18-TER-000', 'JA18-TER-000', 'Jardim 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('JA18-TER-037', 'JA18-TER-000', 'JA18-TER-000', 'Jardim 18 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 01 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-000', 'VI01-000-000', 'VI01-000-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-001', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-002', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-003', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-004', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-005', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-013', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-014', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-015', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-016', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-017', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-018', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-019', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-020', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI01-TER-021', 'VI01-TER-000', 'VI01-TER-000', 'Via interna 01 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 02 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-000', 'VI02-000-000', 'VI02-000-000', 'Via interna 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-001', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-003', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-005', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-007', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-009', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI02-TER-011', 'VI02-TER-000', 'VI02-TER-000', 'Via interna 02 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 03 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-000', 'VI03-000-000', 'VI03-000-000', 'Via interna 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-001', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-003', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-005', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-007', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-009', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-011', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-013', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI03-TER-031', 'VI03-TER-000', 'VI03-TER-000', 'Via interna 03 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 04 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-000', 'VI04-000-000', 'VI04-000-000', 'Via interna 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-001', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-003', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-005', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-007', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-009', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-011', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-013', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-015', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-017', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI04-TER-019', 'VI04-TER-000', 'VI04-TER-000', 'Via interna 04 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 05 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-000', 'VI05-000-000', 'VI05-000-000', 'Via interna 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-001', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-003', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-005', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-007', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-009', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI05-TER-011', 'VI05-TER-000', 'VI05-TER-000', 'Via interna 05 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 06 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-000', 'VI06-000-000', 'VI06-000-000', 'Via interna 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-001', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-003', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-005', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-007', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-009', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI06-TER-011', 'VI06-TER-000', 'VI06-TER-000', 'Via interna 06 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 07 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-000', 'VI07-000-000', 'VI07-000-000', 'Via interna 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-001', 'VI07-TER-000', 'VI07-TER-000', 'Via interna 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-003', 'VI07-TER-000', 'VI07-TER-000', 'Via interna 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-005', 'VI07-TER-000', 'VI07-TER-000', 'Via interna 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-007', 'VI07-TER-000', 'VI07-TER-000', 'Via interna 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI07-TER-011', 'VI07-TER-000', 'VI07-TER-000', 'Via interna 07 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 08 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-000', 'VI08-000-000', 'VI08-000-000', 'Via interna 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-001', 'VI08-TER-000', 'VI08-TER-000', 'Via interna 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-003', 'VI08-TER-000', 'VI08-TER-000', 'Via interna 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-005', 'VI08-TER-000', 'VI08-TER-000', 'Via interna 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-007', 'VI08-TER-000', 'VI08-TER-000', 'Via interna 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI08-TER-009', 'VI08-TER-000', 'VI08-TER-000', 'Via interna 08 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-000-000', 'CASF-000-000', 'CASF-000-000', 'Via interna 09 - Todos', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-000', 'VI09-000-000', 'VI09-000-000', 'Via interna 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-006', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-016', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-021', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-022', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-023', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-024', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-025', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-026', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('VI09-TER-031', 'VI09-TER-000', 'VI09-TER-000', 'Via interna 09 - Pavimento Térreo', 'Descrição do ativo', 'F', 0, 0, 0, 'Fabricante', '0', '0', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00308', 'BL02-P01-007', 'BL02-P01-007', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '3F - 380V', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03029', 'AX02-ATV-015', 'AX02-ATV-015', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventokit 280 40W 220V 280m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03028', 'AX02-ATV-015', 'AX02-ATV-015', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventokit 280 40W 220V 280m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02934', 'BL02-P01-011', 'BL02-P01-011', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1219B00452439', 'Springer Carrier Modelo 42BBA030A510HDC 30.000BTU/h 2,5TR', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02933', 'BL02-P01-011', 'BL02-P01-011', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1219B00452435', 'Springer Carrier Modelo 42BBA030A510HDC 30.000BTU/h 2,5TR', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02932', 'BL02-P01-011', 'BL02-P01-011', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1219B00452438', 'Springer Carrier Modelo 42BBA030A510HDC 30.000BTU/h 2,5TR', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48015', 'AX02-ATN-057', 'AX02-ATN-057', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '803AZSP2C342', 'LG USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02931', 'BL02-P01-011', 'BL02-P01-011', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1219B00452440', 'Springer Carrier Modelo 42BBA030A510HDC 30.000BTU/h 2,5TR', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02930', 'BL02-TER-012', 'BL02-TER-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1219B00452417', 'Springer Carrier Modelo 42BBA030A510HDC 30.000BTU/h 2,5TR', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02929', 'BL02-TER-012', 'BL02-TER-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1219B00452436', 'Springer Carrier Modelo 42BBA030A510HDC 30.000BTU/h 2,5TR', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02928', 'BL02-TER-012', 'BL02-TER-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1219B00452442', 'Springer Carrier Modelo 42BBA030A510HDC 30.000BTU/h 2,5TR', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03027', 'AX02-AFM-001', 'AX02-AFM-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', ' Ventisol EXB 150-2 22W 220V 186m3/h 1350rpm', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03026', 'AX02-AFM-001', 'AX02-AFM-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventisol EXB 150-2 22W 220V 186m3/h 1350rpm', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03025', 'AX02-AFM-001', 'AX02-AFM-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventisol EXB 150-2 22W 220V 186m3/h 1350rpm', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03024', 'AX02-AFM-001', 'AX02-AFM-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventisol EXB 150-2 22W 220V 186m3/h 1350rpm', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48014', 'AX02-AAT-009', 'AX02-AAT-009', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2608Y42266', 'CARRIER 426WC0080BP03FHC', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03023', 'AX02-AAA-004', 'AX02-AAA-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', ' MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03022', 'AX02-AAA-004', 'AX02-AAA-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03021', 'AX02-ATN-060', 'AX02-ATN-060', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03020', 'AX02-ATN-060', 'AX02-ATN-060', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03019', 'AX02-ATN-060', 'AX02-ATN-060', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03018', 'AX02-ATN-060', 'AX02-ATN-060', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03017', 'AX02-ATN-060', 'AX02-ATN-060', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03016', 'AX02-ATN-060', 'AX02-ATN-060', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48013', 'BL11-TER-036', 'BL11-TER-036', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '62227-20422507-00031', 'Minisplit Trane 2MCX0524C10R0AL / 2TTK0524C1000AL 24000Btu/h R22 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03015', 'AX02-ANT-008', 'AX02-ANT-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', ' MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03014', 'AX02-ANT-008', 'AX02-ANT-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', ' MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03013', 'AX02-ANT-008', 'AX02-ANT-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', ' MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48012', 'AX02-TER-000', 'AX02-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4317B11988675', 'Hi-Wall Springer Midea Inverter 42MBCA24M5/38MBCA24M5 24000Btu/h R-410A 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48011', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '803AZAL6H664', ' LG Libero Inverter USNQ242CSG3/USUQ242CSG3 22.000Btu/h 220Vac', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48010', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '804AZZX21597', 'LG Libero Inverter USNQ242CSG3/USUQ242CSG3 22.000Btu/h 220Vac', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48009', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', ' 1519B15197988', 'Electrolux 42MBCB12M5 12000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48008', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', ' 1519B15197982', 'Electrolux 42MBCB12M5 12000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48007', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4818B00435181/4918B14761596', 'Springer Carrier 42BQA024510HC/38KCK024515MC 24000Btu/h R410A 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48006', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4818B00435180/4918B14761594', 'Springer Carrier 42BQA024510HC/38KCK024515MC 24000Btu/h R410A 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48005', 'AX02-ATV-004', 'AX02-ATV-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4818B00435176/4918B14761593', 'Springer Carrier 42BQA024510HC/38KCK024515MC 24000Btu/h R410A 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48004', 'AX02-ATN-060', 'AX02-ATN-060', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '72100080/83600280', 'Electrolux BI22F/BE22F 22000Btu/h R410A 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48003', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '71900145/83600274', 'Electrolux BI22F/BE22F 22000Btu/h R410A 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48002', 'AX02-ATN-060', 'AX02-ATN-060', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '71900138/83600273', 'Electrolux BI22F/BE22F 22000Btu/h R410A 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02936', 'BL10-P01-000', 'BL10-P01-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'CARRIER 42LVQC22C5', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03012', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03011', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', ' MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03010', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03009', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02935', '309G-P06-602', '309G-P06-602', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C101008091007B03800157', 'HITACHI RPK015B', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03032', 'AX02-SS1-001', 'AX02-SS1-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'CONSUL', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02934', 'BL02-TER-000', 'BL02-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'CARRIER 38MCA007515MC ', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22301', 'EDPR-ADM-002', 'EDPR-ADM-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'HP271500103', 'Fancolete Carrier 40HP18 18.000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03008', 'BL16-TER-028', 'BL16-TER-028', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Sicflux Mega 34 Bivolt', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03007', 'BL16-TER-028', 'BL16-TER-028', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Sicflux Mega 34 Bivolt', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03006', 'AX02-AAT-003', 'AX02-AAT-003', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'VENTILEX - BS-40-01', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03030', 'AX02-SS1-000', 'AX02-SS1-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'CONSUL', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02933', 'BL18-TER-017', 'BL18-TER-017', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'SPRINGER UR8CI72INCJH', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02932', 'BL14-P01-000', 'BL14-P01-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'SPRING ', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03005', 'EDPR-P01-045', 'EDPR-P01-045', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Centrífugo Inline 315mm 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03004', 'AX02-ATN-049', 'AX02-ATN-049', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03003', 'AX02-ATN-049', 'AX02-ATN-049', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventisol EXB 150-2  22W  220V  186m3/h  1350rpm', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03002', 'AX02-ATN-049', 'AX02-ATN-049', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03001', 'AX02-ATN-049', 'AX02-ATN-049', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02900', 'BL01-ALF-071', 'BL01-ALF-071', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4118B00428979', 'CARRIER / 42BBA030A510HDC / 30.000Btus', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02899', 'BL01-ALF-071', 'BL01-ALF-071', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4118B00428974', 'CARRIER / 42BBA030A510HDC / 30.000Btus', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02898', 'BL01-ALF-071', 'BL01-ALF-071', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4118B00428971', 'CARRIER / 42BBA030A510HDC / 30.000Btus', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02919', 'AX02-ATN-050', 'AX02-ATN-050', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'TCY1609 046429', 'HITACHI / TCYE30A3M / 33.600BTUs', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02918', 'AX02-ATN-050', 'AX02-ATN-050', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2816B00332876', 'CARRIER / 42BBA030A510HDC / 30.000Btus', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02868', 'AX02-TER-044', 'AX02-TER-044', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'J106087-62', 'CARRIER 42PC810E 1/6cv', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-03000', 'BL08-SEM-000', 'BL08-SEM-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventisol EXB 150-2  22W  220V  186m3/h  1350rpm', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02999', 'BL08-SEM-000', 'BL08-SEM-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventisol EXB 150-2  22W  220V  186m3/h  1350rpm', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48001', 'SHIS-TER-000', 'SHIS-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1102699666', 'HITACHI RPK18AS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-48000', 'SHIS-TER-000', 'SHIS-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1102699543', 'HITACHI RPK18AS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47998', 'SHIS-TER-000', 'SHIS-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '352239', 'SPRINGER 42RWCA022515LS ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47997', 'SHIS-TER-000', 'SHIS-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPC0609421064', 'HITACHI PISO TETO RPCO15D3P', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47995', 'SHIS-TER-000', 'SHIS-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'D20185845103C26110001', 'CASSETE 2MCO548CUOROAL', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47994', 'SHIS-TER-000', 'SHIS-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'NF3255451', 'CONSUL CBF22CBBNA', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47992', 'SHIS-TER-000', 'SHIS-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4317D11988615', 'MIDEA 42NBCA24N5', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47991', 'SHIS-TER-000', 'SHIS-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1508B10172', 'CARRIER 42XQB060515LC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47990', 'SHIS-TER-000', 'SHIS-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZKA3X901', 'LG USNQ 122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47989', '309D-TER-000', '309D-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK110370400', 'HITACHI  RPK12A', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02998', 'AX02-TER-012', 'AX02-TER-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03029', 'AX02-SS1-067', 'AX02-SS1-067', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Springer 7.500 Btu/h Frio 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03028', 'AX02-SS1-067', 'AX02-SS1-067', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Consul Air Master 7.500 Btu/h Frio 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03027', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0919B15063085', 'Springer Midea Mecânico ZCI185BB 18.000 Btu/h Frio 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03026', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0819B15057982', 'Springer Midea QCI105BB 10.000 Btu/h Frio 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03025', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0819B15057981', 'Springer Midea QCI105BB 10.000 Btu/h Frio 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03024', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0819B15057979', 'Springer Midea QCI105BB 10.000 Btu/h Frio 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00307', 'AX02-AA1-015', 'AX02-AA1-015', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '3F - 380V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47988', 'BL10-P01-031', 'BL10-P01-031', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'MB5683837', 'Hi Wall Inverter Bem Estar CBM22CBBNA 22.000 Btu/h Frio R-410A 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47987', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '90600515', 'Electrolux QI12F 12000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47986', 'AX02-TER-020', 'AX02-TER-020', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '90600417', 'Electrolux QI12F 12000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47985', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '90300397', 'Electrolux QI12F 12000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22300', 'AX02-ATN-050', 'AX02-ATN-050', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'TCY1609 046429', 'Hitachi - TCYE30A3M - 33.600 Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47984', 'BL07-P01-010', 'BL07-P01-010', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '85000121', 'Electrolux BI22R 22000Btu/h R410A 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02997', 'EDPR-ADM-004', 'EDPR-ADM-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02996', 'EDPR-ADM-004', 'EDPR-ADM-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02995', 'EDPR-P01-021', 'EDPR-P01-021', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02994', 'EDPR-P01-021', 'EDPR-P01-021', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02993', 'AX02-ARC-002', 'AX02-ARC-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventokit 280 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02992', 'AX02-ARC-002', 'AX02-ARC-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventokit 280 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02991', 'AX02-ARC-002', 'AX02-ARC-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventokit 280 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47983', 'AX02-SS2-052', 'AX02-SS2-052', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'P2FRA00042', 'ELGIN SCFI-12000-2 12000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02990', 'AX02-ARC-004', 'AX02-ARC-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventisol EXB 150-2  22W  220V  186m3/h  1350rpm', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47982', 'BL02-SS1-018', 'BL02-SS1-018', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2718B13549444', 'Springer - 42XQO36S5 / 38CCO036515MS - 36.000 Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47981', 'BL02-SS1-018', 'BL02-SS1-018', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2718B13549358', 'Springer - 42XQO36S5 / 38CCO036515MS - 36.000 Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-VET-02850', 'AT10-SEM-000', 'AT10-SEM-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'EBERLE - B80A4/ESP', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02989', 'AX02-AFM-004', 'AX02-AFM-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'WEG - 63 0395', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25198', '309C-P06-602', '309C-P06-602', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '712AZYE8X034', 'LG USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25197', '309C-P06-602', '309C-P06-602', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '712AZDB8X548', 'LG USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25196', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3911B75027/2511B95570', 'Springer Carrier Maxiflex 42RWCA022515LS/38KCB022515MS 22000Btu/h R-22 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03023', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2111B39878', 'Springer Carrier ZCA305RB 30.000Btu/h R-22 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03022', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Springer Carrier ZCA305RB 30.000Btu/h R-22 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25195', '309G-P04-402', '309G-P04-402', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3,08000500043774E+21', 'BOSH ACSTCON18FMIN', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25194', '309G-P04-402', '309G-P04-402', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '43302936', 'ELECTROLUX SI12F', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25193', '309G-P04-402', '309G-P04-402', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '43303272', 'ELECTROLUX SI12F', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02927', 'EDPR-ACM-005', 'EDPR-ACM-005', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0819B00448417', 'CARRIER / 42BBA030A510HDC / 30.000Btus', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25192', '309G-P04-402', '309G-P04-402', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '43302821', 'ELECTROLUX SI12F', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25191', '309G-P04-402', '309G-P04-402', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3106B27714', 'CARRIER PISO TETO 42XQA024515KC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25190', '309G-P04-402', '309G-P04-402', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3106B27708', 'CARRIER PISO TETO 42XQA024515KC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25189', '309G-P03-303', '309G-P03-303', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '501AZUJHL990', 'LG USNQ122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25188', '309G-P03-303', '309G-P03-303', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZYE3U090', 'LG USNQ122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25187', '309G-P03-303', '309G-P03-303', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZER3U100', 'LG USNQ122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25185', '309G-P03-303', '309G-P03-303', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '410AZBZHV837', 'LG USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25184', '309G-P03-303', '309G-P03-303', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '410AZFRHV828', 'LG USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25177', '309C-P06-603', '309C-P06-603', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '501AZQVHM308', 'LG USNQ 242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25176', '309C-P06-603', '309C-P06-603', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZKA3X877', 'LG USNQ 122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25175', '309C-P06-603', '309C-P06-603', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZNG3U099', 'LG USNQ 122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25173', '309C-P06-603', '309C-P06-603', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '410AZDZHV813', 'LG USNQ 242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25171', '309G-P06-604', '309G-P06-604', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5034AZPU3U088', 'LG USNQ122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25170', '309G-P06-604', '309G-P06-604', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5034AZTH3Y017', 'LG USNQ122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25169', '309G-P06-604', '309G-P06-604', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5034AZQV3U068', 'LG USNQ122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25168', '309G-P06-604', '309G-P06-604', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5034AZVN52399', 'LG USNQ 242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25167', '309G-P06-604', '309G-P06-604', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5034AZQV52356', 'LG USNQ 242CSg3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25166', '309D-P06-604', '309D-P06-604', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503ANK52343', 'LG USNQ 122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25165', '309D-P06-604', '309D-P06-604', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZFM3Y027', 'LG USNQ 122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25164', '309D-P06-604', '309D-P06-604', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZCQ3U091', 'LG USNQ 122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25163', '309D-P06-604', '309D-P06-604', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZPU064', 'LG USNQ 122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25162', '309D-P06-604', '309D-P06-604', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2504B13446', 'CARRIER PISO TETO K42LA5LC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25161', '309D-P06-604', '309D-P06-604', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1404B19691', 'CARRIER K42LA5LC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25111', '309C-P02-204', '309C-P02-204', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '47443813060800100', 'HITACHI RKP015B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25110', '309C-P02-204', '309C-P02-204', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'K121-01000808010030192', 'KONECO KOS12fC3WX', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25109', '309C-P02-204', '309C-P02-204', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'K121-01', 'KONECO KOS12fC3WX', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25105', '309D-P05-504', '309D-P05-504', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'G50503311100161', 'ELGIN SUFIA 12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25104', '309D-P05-504', '309D-P05-504', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'G50503311100144', 'ELGIN SUFIA 12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25103', '309D-P05-504', '309D-P05-504', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'G50503311100220', 'ELGIN SUFIA 12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25100', 'SHIS-TER-000', 'SHIS-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'D201859581014215110001', '2NWCO548C10ROAL ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25087', '309C-P01-101', '309C-P01-101', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1103708332', 'HITACHI RPK12A', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25082', '309G-P04-403', '309G-P04-403', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '334', 'ELGIN SSFIA12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25081', '309G-P04-403', '309G-P04-403', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C101006450507B03150398', 'HITACHI RKP010C ', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22299', 'AX02-ARC-004', 'AX02-ARC-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Hitachi - TCYE30A3M - 33.600 Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02985', 'AX02-ATV-020', 'AX02-ATV-020', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02984', 'AX02-ATV-020', 'AX02-ATV-020', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25036', '309D-P04-401', '309D-P04-401', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZPU52400', 'LG USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25035', '309D-P04-401', '309D-P04-401', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZ3U094', 'LG USNQ122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25034', '309D-P04-401', '309D-P04-401', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZTH3U001', 'LG USNQ122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25033', '309D-P04-401', '309D-P04-401', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZNK3U007', 'LG USNQ122H5G3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25032', '309D-P04-401', '309D-P04-401', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503AZHY52353', 'LG USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25031', '309D-P04-401', '309D-P04-401', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'R503AZSP52406', 'LG USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25030', '309G-P05-504', '309G-P05-504', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1103708294', 'HITACHI RPK12A', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25029', '309G-P05-504', '309G-P05-504', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'JAAOGBB8077698001760', 'KANECO KOS18FC3HX', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25028', '309G-P05-504', '309G-P05-504', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'G50503311100207', 'ELGIN - SUFIA 12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25027', '309G-P05-504', '309G-P05-504', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'G50503311100185', 'ELGIN - SUFIA 12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25026', '309G-P05-504', '309G-P05-504', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'E006899', 'FUJITSU ASB12A1', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25025', '309G-P05-504', '309G-P05-504', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3606B12992', 'CARRIER 42XQA024515KC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25024', '309G-P05-504', '309G-P05-504', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4205B409065', 'CARRIER 42XQA024515KC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25023', '309D-P01-104', '309D-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1401799801', 'HITACHI RCAI 22B ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25022', '309D-P01-104', '309D-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4115B17906095', 'CARRIER 42FUCA12C5 ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25021', '309D-P01-104', '309D-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4115B17905993', 'CARRIER 42FUCA12C5 ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25020', '309D-P01-104', '309D-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4115B17906400', 'CARRIER 42FUCA12C5 ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25019', '309D-P01-104', '309D-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1401799802', 'HITACHI RACIV22B ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25018', '309D-P01-104', '309D-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1401799800', 'HITACHI RACIV22B ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25012', '309G-P01-104', '309G-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C101008091007B038000230', 'HITACHI RPK15B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25011', '309G-P02-201', '309G-P02-201', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C101008090907B03B01557', 'HITACHI RKP010B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25010', '309G-P02-201', '309G-P02-201', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C10100809090TB03800559', 'HITACHI RKP01013', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25009', '309G-P02-201', '309G-P02-201', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C101008090907B03800062', 'HITACHI RKP010B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25008', '309G-P02-201', '309G-P02-201', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C101000930707927150082', 'HITACHI RKP020B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25007', '309G-P02-201', '309G-P02-201', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C101000930707927150139', 'HITACHI RKP020B', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02983', 'EDPR-ACM-004', 'EDPR-ACM-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25006', '309G-P01-104', '309G-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3605Y42357', 'CARRIER 4PCA024515LC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25005', '309G-P01-104', '309G-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1103703998', 'HITACHI  RPK12A', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25004', '309G-P01-104', '309G-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'K12101000808010030224', 'KONECO KOS12fC3WX', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25003', '309G-P01-104', '309G-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '6110185905YC20A0', 'PH12000ifn', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25002', '309G-P01-104', '309G-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'MD6538432', 'CONSUL CBF22CBBNA', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-25001', '309G-P01-104', '309G-P01-104', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'MD6538397', 'CONSUL CBF22CBBNA', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02982', 'AX02-AA1-001', 'AX02-AA1-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'EXB 150-02 Ventisol 150mm', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02981', 'AX02-AA1-001', 'AX02-AA1-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', ' EXB 150-02 Ventisol 150mm', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02980', 'AX01-P01-004', 'AX01-P01-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'EXB 150-02 Ventisol 150mm', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02979', 'AX01-P01-004', 'AX01-P01-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'EXB 150-02 Ventisol 150mm', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02978', 'AX02-AAA-012', 'AX02-AAA-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02977', 'AX02-AAA-012', 'AX02-AAA-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22298', 'EDPR-ADM-004', 'EDPR-ADM-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2608Y42248', 'Carrier - 42GWC0080BP03THC - 24.000 Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02976', 'AX02-AAA-002', 'AX02-AAA-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'EXB 150-02 Ventisol 150mm', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22297', 'AX02-AFM-003', 'AX02-AFM-003', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5118B00440067', 'Carrier - 42BCA030A510KEC - 30.000 Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22296', 'AX02-AFM-003', 'AX02-AFM-003', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5118B00440067', 'Carrier - 42BCA030A510KEC - 30.000 Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03016', 'AX02-SS1-000', 'AX02-SS1-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '-', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02975', 'BL17-ALI-000', 'BL17-ALI-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02974', 'AX02-SS1-072', 'AX02-SS1-072', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Multivac AXC 315 A  220V', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02973', 'AX02-AFM-004', 'AX02-AFM-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '-', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02972', 'AX02-AFM-010', 'AX02-AFM-010', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'DSA 160.80 - Torin', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22295', 'AX02-AAA-013', 'AX02-AAA-013', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'COLDEX TRANE', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47980', 'BL03-TER-000', 'BL03-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Carrier 42VCA007515LC 7.000Btu/h', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03015', 'AT14-SS1-001', 'AT14-SS1-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Consul 12.000 Btu/h', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47979', 'BL10-P01-000', 'BL10-P01-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '63229987534 / 63229987535', 'Split Hi-Wall Inverter Frio Trane 12.000 Btu/h 4MYW1612A1000BA / 4TYK1612A1000BA', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47978', 'BL10-P01-000', 'BL10-P01-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '63229987538 / 63229987539', 'Split Hi-Wall Inverter Frio Trane 24.000 Btu/h 4MYW1624A1000BA / 4TYK1624A1000BA', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47977', 'BL10-P01-000', 'BL10-P01-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3E22888011765 / 3E22988011896', 'Split Gree Eco Garden Inverter 12.000 Btu/h GWC12QCD3DNB8M-I / GWC12QCD3DNB8M-O', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47976', 'BL13-TER-000', 'BL13-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0318B12708408', 'SPRINGER MIDEA 42MBCA24M5/38MBCA24M5', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-00032', 'BL02-TER-000', 'BL02-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '-', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22294', 'AX02-ANT-008', 'AX02-ANT-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4918B00436928', 'FANCOLETE CARRIER 2,5TR 42BBA030A510HDC', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22293', 'AX02-ANT-008', 'AX02-ANT-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4918B00436926', 'FANCOLETE CARRIER 2,5TR 42BBA030A510HDC', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22291', 'AX02-AAA-007', 'AX02-AAA-007', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4918B00436924', 'FANCOLETE CARRIER 2,5TR 42BBA030A510HDC', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22290', 'EDPR-P01-009', 'EDPR-P01-009', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4918B00436923', 'CARRIER 42BBA030A510HDC FANCOLETE 2,5TR', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22289', 'AX02-ATN-054', 'AX02-ATN-054', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4918B00436922', 'FANCOLETE CARRIER 2,5TR 42BBA030A510HDC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47974', 'AX02-ATV-024', 'AX02-ATV-024', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4718B00433538', 'Marca: CARRIER / Modelo: 42BQA024510HC / Split Dutado', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47973', 'AX02-ATV-005', 'AX02-ATV-005', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4718B00433534', '42BQA024510HC - SPLIT CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24046', '309C-P01-102', '309C-P01-102', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '712AZMG8N549', 'LG - USNQ242CSG3 SPLIT LG', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24045', 'AX02-ATN-050', 'AX02-ATN-050', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '712AZMG8N548', 'USNQ242CSG3 SPLIT LG', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24043', 'EDPR-P01-058', 'EDPR-P01-058', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '712AZMG8N547', 'USNQ242CSG3 SPLIT LG', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47969', 'BL08-SEM-008', 'BL08-SEM-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '62230-45661204-00007', 'Split Dutado Trane 36.000 Btu/h Frio 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47968', 'BL08-SEM-008', 'BL08-SEM-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '62230-45661204-00006', 'Split Dutado Trane 36.000 Btu/h Frio 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47967', 'BL08-SEM-008', 'BL08-SEM-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '62230-45661204-00005', 'Split Dutado Trane 36.000 Btu/h Frio 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47966', 'BL08-SEM-008', 'BL08-SEM-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '62230-45661204-00004', 'Split Dutado Trane 36.000 Btu/h Frio 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47965', 'BL08-SEM-008', 'BL08-SEM-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '62230-45661204-00001', 'Split Dutado Trane 36.000 Btu/h Frio 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47964', 'BL14-SEM-032', 'BL14-SEM-032', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3717b00383665', '42BQA02451HC CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03014', 'BL14-000-000', 'BL14-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5197B56686', 'YQA3050 30.000 Btu/h Springer Carrier', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47963', 'BL16-MEZ-000', 'BL16-MEZ-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '38FVCA22C5 / 42FVCA22C5 CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47962', 'BL02-P01-006', 'BL02-P01-006', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3902B16524', '42LSE60226QLA 60000Btu/h CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47961', 'BL02-P01-006', 'BL02-P01-006', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3T0805-02420', 'MCX048E10RCA 48000Btu/h TRANE', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02971', 'AX02-AA1-017', 'AX02-AA1-017', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02970', 'AX02-AA1-017', 'AX02-AA1-017', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Muro 150B Multivac', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47960', 'BL19-TER-009', 'BL19-TER-009', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Springer Midea 42MBCA24M5 / 38MBCA24M5', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22287', 'AX02-AFM-006', 'AX02-AFM-006', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'TCY1607035937', 'Hitachi TCYE30A3M', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47959', 'EDPR-TER-070', 'EDPR-TER-070', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '349', 'ELGIN SSFIA-12000-2 / SSFEA-12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22286', 'EDPR-P01-067', 'EDPR-P01-067', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2516B00331389', '42LSA30226ALB', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22285', 'EDPR-P01-067', 'EDPR-P01-067', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2516B00331444', '42LSA30226ALB', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02884', 'EDPR-P01-067', 'EDPR-P01-067', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2516B00331440', '42LSA30226ALB', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47958', 'AX02-SS1-000', 'AX02-SS1-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '38FVCA22C5 / 42FVCA22C5', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02969', 'AX02-ANT-004', 'AX02-ANT-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'AXC 100B Multivac 100mm', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02968', 'EDPR-ADM-005', 'EDPR-ADM-005', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'EXB 150-02 Ventisol 150mm', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-01720', 'BL16-TER-007', 'BL16-TER-007', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3800Y51650', 'CARRIER 42DXC24226 24.000 Btu/h', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03013', 'BL08-SEM-000', 'BL08-SEM-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0411B67809', 'MCD125RB 12.000 Btu/h Springer Carrier', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02882', 'AX02-AAT-015', 'AX02-AAT-015', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0918B00402094', '42BCA030A510KEC CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22288', 'AX01-P14-013', 'AX01-P14-013', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '-', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47955', 'AX02-ATV-002', 'AX02-ATV-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '02GTPXDJB01014', 'SAMSUNG AR24KSSPASNXAZ (OUT)', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22281', 'BL13-P01-000', 'BL13-P01-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0608B00405', 'Carrier 42BCA018A510KDC', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22280', 'AX02-P01-075', 'AX02-P01-075', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Fancolete dutado', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03012', 'BL16-MEZ-001', 'BL16-MEZ-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4596B58720', 'XCB185D', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02960', 'EDPR-P01-046', 'EDPR-P01-046', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Multivac Muro 150B-T', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24042', 'BL16-TER-002', 'BL16-TER-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4817B12360116', 'SPLIT HI WALL 42MBCA24M5 CARRIER MIDEA', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47952', 'BL17-ALS-056', 'BL17-ALS-056', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0602B27742', 'SPRINGER CARRIER 42LNA36226QL8 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22274', 'AX02-ATN-056', 'AX02-ATN-056', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'TCY1606033939', 'TCYE30A3M', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24035', 'BL07-SEM-032', 'BL07-SEM-032', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '710AZMG38107', 'SPLIT HI WALL USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47945', 'AX02-AAT-011', 'AX02-AAT-011', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C101037760708407150046', 'RKP010B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47943', 'AX02-ATV-025', 'AX02-ATV-025', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPI1612060226', 'RPI24A3M', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47939', 'AX02-ATV-001', 'AX02-ATV-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1413B58544', '38KCD/24515MC', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22267', 'BL17-ALS-078', 'BL17-ALS-078', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2417B10953903', 'Carrier Built-in Versatile 38KCK024515MC 24000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47413', 'AX02-ATV-005', 'AX02-ATV-005', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'SO918B00402036', 'SPLIT DUTADO MOD 42BQAO24510HC CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47414', 'AX02-ATV-021', 'AX02-ATV-021', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'SO918B00402031', 'SPLIT DUTADO MOD 42BQAO24510HC CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47937', 'BL08-MEZ-034', 'BL08-MEZ-034', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1898Y5141B', '42DXB24226', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22263', 'AX02-AAA-008', 'AX02-AAA-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0817B00363160', '42BCA030A510KEC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47936', 'AX02-ATN-049', 'AX02-ATN-049', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0715B15983585/000001218469', '38MKCA22M5/42MKCA22M5', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22262', 'AT14-SS1-002', 'AT14-SS1-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3500B37855', '42LSA30226AL 220V CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22261', 'AX02-AA1-001', 'AX02-AA1-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0817B00363459', '42BCA030A510KEC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47935', 'AX02-SS1-076', 'AX02-SS1-076', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4500Y30275 - 220 V', '42DXD09228', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47412', 'AX02-ATV-013', 'AX02-ATV-013', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'SO918B00402029', 'SPLIT DUTADO - 42BQAO24510HC - EVAPORADORA CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-00836', 'AX02-ATN-054', 'AX02-ATN-054', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'SO918B00402125', 'SPLIT DUTADO - 42BQAO24510HC CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24040', 'AX02-SS1-081', 'AX02-SS1-081', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RAA 1102694736', 'RAA12A HITACHI 12000 BTUS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24039', 'AX02-ATN-054', 'AX02-ATN-054', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPI1612060228', 'RPI24A3M  24000 BTUS HITACHI', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24038', 'AX02-ATN-050', 'AX02-ATN-050', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '710AZBZ38471', 'SPLIT HI WALL - USNQ242CSG3 EVAPORADORA 22000 BTUS LG INVERTER', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24037', 'AX02-ALI-001', 'AX02-ALI-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'SB918B00402035', '42LVCC22C5 CARRIER XPOWER', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02880', 'AX02-P01-075', 'AX02-P01-075', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0918B00402090', 'FANCOLET DUTADO - 42BCA030A510KEC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24031', 'BL14-MEZ-065', 'BL14-MEZ-065', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3417B11378371', 'Split hi-wall Midea 42MBCA24M5', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24031 ', 'BL14-MEZ-065', 'BL14-MEZ-065', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3517B11387829', 'SPLIT HI WALL - 42MBCA24M5 - CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02881', 'AX02-SS1-076', 'AX02-SS1-076', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0918B00402091', 'FANCOLET DUTADO 2,5 TR CARRIER - 42BCA030A510KEC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24033', 'BL16-TER-007', 'BL16-TER-007', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '710AZKA71253', 'SPLIT HI WALL - USNQ242CSG3 EVAPORADORA 22000 BTUS LG', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24036', 'BL09-SEM-014', 'BL09-SEM-014', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'MB5684592', 'CBJ22CBBNA CONSUL', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24003', 'AX02-SS1-089', 'AX02-SS1-089', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4404B21018', 'SPRINGER CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03001', 'BL07-SEM-012', 'BL07-SEM-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '879286', 'SPRINGER - RG19ER5S', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24008', 'AX01-SS1-000', 'AX01-SS1-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1614B12879986', 'Mod.: 38KCD024515MC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24025', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Hi Wall Carrier Frio 22.000Btu/h 42LVCC22C5/38LVCC22C5 220V X-Power Inverter', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02876', 'AT13-000-000', 'AT13-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0817B00363463', 'FANCOLETE DUTADO CARRIER 2.5TR', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02875', 'AT13-000-000', 'AT13-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0817B00363463', 'FANCOLETE DUTADO CARRIER 2.5TR', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02217', 'AT13-000-000', 'AT13-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '40HP18B-S', 'Ar Condicionado Fancolete 1,5 Trs 220v Carrier Hw Frio ', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02216', 'BL14-MEZ-094', 'BL14-MEZ-094', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Carrier 40HP18B-S 1,5TR 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02874', 'AX02-ATN-054', 'AX02-ATN-054', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0817B00363463', 'FANCOLETE DUTADO CARRIER 2.5TR', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-22260', 'AT13-000-000', 'AT13-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '40HP18B-S', 'FANCOLETE CARRIER HW 18.000BTUS ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24023', 'AT13-000-000', 'AT13-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42MBCA24M5', 'Split Hw Inverter 24.000 Btus Frio 220v Springer Midea', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24007', 'AX01-SS1-000', 'AX01-SS1-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1614B12879986', 'Mod.: 38KCD024515MC CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-SLF-24006', 'BL01-000-000', 'BL01-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'B071650406', 'Mod.: CRCB075KB0LA300000000000000000005', '0', 'Garantia');
insert into assets values ('ACAT-000-SLF-24005', 'BL01-000-000', 'BL01-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'B071650405', 'Mod: CRCB075KB0LA300000000000000000005', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24022', 'AT13-000-000', 'AT13-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42MBCA24M5', 'Split Hw Inverter 24.000 Btus Frio 220v Springer Midea', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24021', 'AT13-000-000', 'AT13-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42MBCA24M5', 'Split Hw Inverter 24.000 Btus Frio 220v Springer Midea', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24020', 'AT13-000-000', 'AT13-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42MBCA24M5', 'Split Hw Inverter 24.000 Btus Frio 220v Springer Midea', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24019', 'AX01-000-000', 'AX01-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42MBCA24M5', 'Split Hw Inverter 24.000 Btus Frio 220v Springer Midea', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24018', 'BL10-000-000', 'BL10-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42MBCA24M5', 'Split Hw Inverter 24.000 Btus Frio 220v Springer Midea', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47398', 'AX02-ATV-020', 'AX02-ATV-020', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42BQA024510HC', 'Carrier Heavy Duty 24.000 BTUs Frio 220V Monofásico', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47397', 'AT13-000-000', 'AT13-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42BQA024510HC', 'Carrier Heavy Duty 24.000 BTUs Frio 220V Monofásico', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47396', 'AT13-000-000', 'AT13-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42BQA024510HC', 'Carrier - Split Dutado 24.000 btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47395', 'AX02-ATV-013', 'AX02-ATV-013', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '042BQA024510HC', 'Carrier / Split Dutado 24.000 Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47934', 'AX02-ATV-008', 'AX02-ATV-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '042BQA024510HC', 'Carrier / Split 24.000BTU / Unidade Interna 220V ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47393', 'AX02-ATN-049', 'AX02-ATN-049', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', ' 42BQA24510HC', 'Carrier / Split 24.000BTU / Unidade Interna 220V ', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02926', 'BL14-MEZ-096', 'BL14-MEZ-096', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'HP431400514', 'TRANE/40HP18', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02922', 'AX02-ATN-050', 'AX02-ATN-050', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'TCY1609 046430', 'HITACHI - TCYE30A3M - 30.000BTU/h', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03003', 'AX02-SS1-053', 'AX02-SS1-053', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'TRACER NUMBER 5000082087', 'SPRINGER MINIMAX 12.000 BTU/H', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-03002', 'BL17-000-000', 'BL17-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '628238561', 'CARRIER - XCA 18500', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24016', 'BL16-000-000', 'BL16-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '42VCA22C5 - 22.000 Btu/h', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47404', 'AX02-000-000', 'AX02-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42BQA024510HC', 'Carrier Heavy Duty 24.000 BTUs Frio 220V Monofásico', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47403', 'AX02-000-000', 'AX02-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42BQA024510HC', 'Carrier Heavy Duty 24.000 BTUs Frio 220V Monofásico', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47402', 'AX02-000-000', 'AX02-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42BQA024510HC', 'Carrier Heavy Duty 24.000 BTUs Frio 220V Monofásico', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47401', 'AX02-000-000', 'AX02-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42BQA024510HC', 'Carrier Heavy Duty 24.000 BTUs Frio 220V Monofásico', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47400', 'AX02-SS1-092', 'AX02-SS1-092', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42BQA024510HC', 'Carrier Heavy Duty 24.000 BTUs Frio 220V Monofásico', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47399', 'AX01-000-000', 'AX01-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '42BQA024510HC', 'Carrier Heavy Duty 24.000 BTUs Frio 220V Monofásico', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24026', 'AX02-ATV-021', 'AX02-ATV-021', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'R-410, 9,52A,  - 1~ - 220V~ ', 'Unid. Evaporadora USNQ242CSG3 - LG INVERTER V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02923', 'BL18-TER-000', 'BL18-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RAA1102 694819', 'HITACHI RAA12A - 12.000 BTU/h - Potência: 1.078W - I=5,0A', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02218', 'AX02-SS1-000', 'AX02-SS1-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2T0108-01456', 'HECA08HNH2NAAB - 00 380/240V - 176W - 60Hz', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02934', 'AX02-TER-012', 'AX02-TER-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-24024', 'AX02-SS1-000', 'AX02-SS1-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4314B00256623 - 220V ', 'CARRIER / 42BQA024510KC / 24.000 BTU/H', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-47411', 'AX02-ATV-023', 'AX02-ATV-023', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3114800240084', 'CARRIER - Mod.:4260A924516KC - 24.000 BTU/h', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-01894', 'BL14-SEM-027', 'BL14-SEM-027', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Carrier Piso-Teto - 38XCDO24515MC - 24.000 Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00073', 'AX01-SS1-010', 'AX01-SS1-010', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '-', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02893', 'BL04-000-000', 'BL04-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1406B43988', 'Carrier / 42XQA018515SKC', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00178', 'BL02-SS1-008', 'BL02-SS1-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '3F - 380V', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00177', 'BL02-SS1-008', 'BL02-SS1-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '3F - 380V', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00161', 'BL02-SS1-008', 'BL02-SS1-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '3F - 380V', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00160', 'BL02-SS1-008', 'BL02-SS1-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '3F - 380V', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00159', 'BL02-SS1-006', 'BL02-SS1-006', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '1F - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00158', 'BL02-SS1-006', 'BL02-SS1-006', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '3F - 380V', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00157', 'BL02-SS1-006', 'BL02-SS1-006', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '1F - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00156', 'BL02-SS1-006', 'BL02-SS1-006', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '3F - 380V', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00155', 'BL02-SS1-006', 'BL02-SS1-006', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '3F - 380V', '0', 'Garantia');
insert into assets values ('ACAT-000-QDR-00154', 'BL02-SS1-017', 'BL02-SS1-017', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '1F - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-01248', 'AX02-AAT-009', 'AX02-AAT-009', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'E/80 2727', 'Starco FV-08-4C', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02142', 'BL08-SEM-000', 'BL08-SEM-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5105B15959 / 1206B25185', 'Carrier - 42XQA030515KC / 38XCB030515MC - 30.000Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02299', 'BL08-MEZ-000', 'BL08-MEZ-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Carrier - 42LVCC22C5 - 22.000 Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02325', 'AX02-ATV-012', 'AX02-ATV-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C703077281111054001', 'TRANE - 4RVA0024A10R0AA', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02325', 'AX02-ATV-012', 'AX02-ATV-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4RVA0024A10R0AA', 'TRANE', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02317', 'AX02-ATV-012', 'AX02-ATV-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4RVA0024A10R0AA', 'TRANE', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02316', 'AX02-ATV-021', 'AX02-ATV-021', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4RVA0024A10R0AA', 'TRANE', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02303', 'AX02-ATV-012', 'AX02-ATV-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C70317471709141184002', 'TRANE - 4TVH0096BK000AA', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02301', 'AX02-ATV-012', 'AX02-ATV-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C703077281111054007', 'TRANE - 4RVA0024A10R0AA', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02928', 'AX02-TER-012', 'AX02-TER-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-02927', 'AX02-TER-012', 'AX02-TER-012', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'MultiVac - Muro 150B - 220V - 55W - Vazão máx. 340m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-01913', 'BL14-MEZ-041', 'BL14-MEZ-041', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'CARRIER - 42LS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02506', '309D-P02-202', '309D-P02-202', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '605KALC00112', 'Marca: LG / Modelo: LSNC1823RM1 / 18.000 BTUS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02502', '309D-P02-202', '309D-P02-202', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '905AZCQY171', 'Marca: LG / Modelo: TSNC1828RMO / 18.000 BTUS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02501', '309D-P02-202', '309D-P02-202', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '905AZTH8Y177', 'Marca: LG / Modelo: TSNC1828RMO / 18.000 BTUS', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-01709', 'BL18-TER-000', 'BL18-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2102B19818', 'YCH 1305D', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02892', 'BL08-000-000', 'BL08-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503A.ZUJ52342', 'LG / USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02839', 'AX02-AA1-001', 'AX02-AA1-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'TCY1603 013208', 'Hitachi / TCYE30A3M', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02838', 'AX02-AA1-001', 'AX02-AA1-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'TCY1603 014467', 'Hitachi / TCYD30A3M', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02837', 'AX02-AA1-001', 'AX02-AA1-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'TCY1603 013209', 'Hitachi / TCYE30A3M', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02836', 'AX02-AA1-001', 'AX02-AA1-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'TCY1603 014469', 'Hitachi / TCYD30A3M', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02835', 'AX02-AA1-001', 'AX02-AA1-001', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'TCY1603 014470', 'Hitachi / TCYD30A3M', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02833', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0316B00318724', 'Carrier 42BCA030A510KEC 30000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02831', 'EDPR-ADM-002', 'EDPR-ADM-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0316B00318722', 'Carrier / 42BCA030A510KEC', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02830', 'EDPR-ADM-002', 'EDPR-ADM-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'HP271500091', 'Carrier / 40HP18', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02832', 'EDPR-TER-000', 'EDPR-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0316B00318780', 'Carrier / 42BCA055A510KEC', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02829', 'EDPR-ADM-002', 'EDPR-ADM-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'HP271500075', 'Carrier / 40HP18', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02828', 'EDPR-ADM-002', 'EDPR-ADM-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'HP271500102', 'Carrier / 40HP18', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02827', 'EDPR-ADM-002', 'EDPR-ADM-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'HP271500104', 'Carrier / 40HP18', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02826', 'EDPR-ADM-002', 'EDPR-ADM-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'HP271500119', 'Fancolete Carrier 40HP18 18.000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02825', 'EDPR-ADM-002', 'EDPR-ADM-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'HP271500082', 'Carrier / 40HP18', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02824', 'EDPR-ADM-002', 'EDPR-ADM-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'HP271500098', 'Carrier / 40HP18', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02891', 'BL08-000-000', 'BL08-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503A.ZEX52357', 'LG / USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02890', 'BL08-000-000', 'BL08-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503A.ZER52340', 'LG / USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02889', 'BL16-MEZ-004', 'BL16-MEZ-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503A.ZBZ52229', 'LG / USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02888', 'BL08-000-000', 'BL08-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503A.ZGF52359', 'LG / USNQ242CSG3', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02887', 'CASF-000-000', 'CASF-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '503A,ZJT52348', 'LG Libero Inverter USNQ242CSG3/USUQ242CSG3 22.000Btu/h R-410A 220Vac', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02886', 'AX02-ATV-022', 'AX02-ATV-022', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4715800315642', 'Carrier / 42BQA024510KC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02885', 'AX02-ATV-022', 'AX02-ATV-022', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4715800315645', 'Carrier / 42BQA024510KC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02254', 'AX02-ATN-060', 'AX02-ATN-060', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Samsung Inverter ASV24PSBTNXAZ 24000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-01346', 'AX02-SS1-084', 'AX02-SS1-084', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RAP0608', 'Hitachi / RAP075B75', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-01512', 'EDPR-ACM-014', 'EDPR-ACM-014', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'CARRIER/426WC0100', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-01511', 'EDPR-ACM-014', 'EDPR-ACM-014', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'CARRIER/426WCO050', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02597', '309D-P06-603', '309D-P06-603', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3911B75019', 'Springer Carrier Modelo 42RWCA022515LS 22.000BTU/h', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02596', '309D-P06-603', '309D-P06-603', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3911B75020', 'Springer Carrier Modelo 42RWCA022515LS 22.000BTU/h', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-01472', 'EDPR-TER-057', 'EDPR-TER-057', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'ZT0710-01738', 'CWCS202AB - 1,66 TR (20.000 BTU/h) - TRANE', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02538', '309D-P03-304', '309D-P03-304', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C101004881007A19150181', 'HITACHI RKP020B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02537', '309D-P03-304', '309D-P03-304', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C101004881007A19150293', 'HITACHI RKP020B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02536', '309D-P03-304', '309D-P03-304', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'PHILCO PH12000IQFM', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02535', '309D-P03-304', '309D-P03-304', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'PHILCO PH12000IFM', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02534', '309D-P03-304', '309D-P03-304', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'PHILCO PH12000IFM', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02533', '309D-P03-304', '309D-P03-304', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1102699407', 'HITACHI RPK18AS', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-01444', 'EDPR-ADM-004', 'EDPR-ADM-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '2308Y37709', 'Carrier - 42GWC0080BP03THC - 24.000 Btu/h - 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02348', '309C-P01-103', '309C-P01-103', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '47443813060800700', 'Marca: HITACHI / Modelo: RKP010B / HIWALL 18.000 BTUs', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02347', '309C-P01-103', '309C-P01-103', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '15370428060700600', 'Marca: HITACHI / Modelo: RKP010B / HIWALL 18.000 BTUs', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02346', '309C-P01-103', '309C-P01-103', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '15370428060700600', 'Marca: HITACHI / Modelo: RKP010B / HIWALL 18.000 BTUs', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02345', '309C-P01-103', '309C-P01-103', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '13437', 'Marca: FUJITSU / Modelo: ASB12ASCCW / HIWALL 12.000 BTUs', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-01661', 'BL17-ALS-000', 'BL17-ALS-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'COLDEX FRIGOR / UNTH-6C0-220V - 2 TR', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02329', 'AX02-SS1-086', 'AX02-SS1-086', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '60906A0198', 'Trane WDPA06KBH3F00000', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02328', 'AX02-SS1-086', 'AX02-SS1-086', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RVT0608 415325', 'Splitão Hitachi RVT075 B8P', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02737', '309G-P06-602', '309G-P06-602', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1503921914', 'HITACHI RACIVI12B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02736', '309G-P06-602', '309G-P06-602', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1503922123', 'HITACHI - RAC1V12B', '0', 'Garantia');
insert into assets values ('ACAT-CG1-CHR-01582', 'AT44-TER-000', 'AT44-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1007000', 'TRANE/CBAB050 - 50 TR', '0', 'Garantia');
insert into assets values ('ACAT-CG1-CHR-01581', 'AT44-TER-000', 'AT44-TER-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1007001', 'TRANE/CBAB050 - 50 TR', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02735', '309G-P06-602', '309G-P06-602', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1502912807', 'HITACHI RACIV22B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02734', '309G-P06-602', '309G-P06-602', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1503922123', 'HITACHI RACIV22B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02733', '309G-P06-602', '309G-P06-602', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'C101046750885141509', 'HITACHI RPK010B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02732', '309G-P06-601', '309G-P06-601', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1408846987', 'HITACHI INVERTER RACIV18B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02730', '309G-P06-601', '309G-P06-601', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '153730428060700000', 'HITACHI ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02720', '309G-P05-503', '309G-P05-503', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1007B02417', 'CARRIER 42XQA024515KC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02719', '309G-P05-503', '309G-P05-503', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1102699334', 'HITACHI RPK18AS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02718', '309G-P05-503', '309G-P05-503', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'RPK1103708292', 'HITACHI RPK12A', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02717', '309G-P05-503', '309G-P05-503', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '43302773', 'ELECTROLUX SI12F', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02716', '309G-P05-503', '309G-P05-503', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '43302775', 'ELECTROLUX SI12F', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02702', '309G-P04-404', '309G-P04-404', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'JAAOGBB8077698001366', 'Komeco KOS18FC3HX', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02701', '309G-P04-404', '309G-P04-404', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'G50503311100158', 'ELGIN SUFIA 12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02699', '309G-P04-404', '309G-P04-404', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'G50503311100017', 'ELGIN SUFIA 12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-01428', 'AX02-ARC-004', 'AX02-ARC-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '200 m³/h - 5mmca', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-01427', 'AX02-ARC-002', 'AX02-ARC-002', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '200 m³/h - 5 mmca', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02647', '309G-P02-203', '309G-P02-203', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '290', 'Marca: ELGIN / Modelo: SSFIA12000-2 / 12.000 BTUs HiWall', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02646', '309G-P02-203', '309G-P02-203', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '278', 'Marca: ELGIN / Modelo: SSFIA12000-2 / 12.000 BTUs HiWall', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02645', '309G-P02-203', '309G-P02-203', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '337', 'Marca: ELGIN / Modelo: SSFIA12000-2 / 12.000 BTUs HiWall', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02013', 'AX02-AAA-013', 'AX02-AAA-013', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'COLDEX TRANE', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-02303', 'BL14-MEZ-043', 'BL14-MEZ-043', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0304B46255', 'Carrier Piso/Teto 42LSA25225ALB', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02298', 'BL10-P01-004', 'BL10-P01-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Hi Wall Inverter X-Power 42LVCC22C5/38LVCC22C5 Frio 22.000 Btu/h R-410A 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02357', '309C-P02-201', '309C-P02-201', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1519B15197983', 'Electrolux 42MBCB12M5 12000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02884', 'BL04-SEM-000', 'BL04-SEM-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'NO 1898Y51413', 'Carrier/42KNAN34010', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02101', 'AT13-SS1-038', 'AT13-SS1-038', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'K423PKD1V', 'TWE042C140B1 - TRANE', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02800', 'BL01-000-000', 'BL01-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '22.000 BTUs', 'Springer/42KWCA022515LS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02797', 'BL01-000-000', 'BL01-000-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '22.000 BTUs', 'Springer/42KWCA022515LS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02796', 'BL01-ALE-059', 'BL01-ALE-059', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '22.000 BTUs', 'Springer/42KWCA022515LS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02795', 'BL01-ALE-059', 'BL01-ALE-059', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '24.000 BTUs', 'Hitachi/RKP020B', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02794', 'BL17-ALS-078', 'BL17-ALS-078', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0808B14297', 'Carrier/40MSC060TCR', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02793', 'BL17-ALS-078', 'BL17-ALS-078', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0808B14302', 'CARRIER/40MSC060TCR', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-01978', 'BL10-SEM-048', 'BL10-SEM-048', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Hitachi Piso/Teto', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-01955', 'BL10-SEM-038', 'BL10-SEM-038', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5203B19488', 'CARRIER', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-01953', 'AX02-SS1-067', 'AX02-SS1-067', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'SPRINGER - 1.75 TR', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02426', '309C-P04-404', '309C-P04-404', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3911B75022', 'Marca: SPRINGER / Modelo:', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02425', '309C-P04-404', '309C-P04-404', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '381', 'ELGIN Modelo: SSFIA-12000-2 | Capacidade: 12.000 BTUs', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02413', '309C-P04-402', '309C-P04-402', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '297', 'ELGIN - SUFIA 12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02412', '309C-P04-402', '309C-P04-402', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '387', 'ELGIN SUFIA 12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02411', '309C-P04-402', '309C-P04-402', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '333', 'ELGIN - SUFIA 12000-2', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02410', '309C-P04-402', '309C-P04-402', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3911B75029', 'SPRINGER 42RWCA022515LS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02409', '309C-P04-402', '309C-P04-402', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '3911675018', 'SPRINGER 42RWCA022515LS ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02402', '309C-P03-304', '309C-P03-304', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '53106Y28402', 'SPRINGER 42RWCA022515LS ', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02401', '309C-P03-304', '309C-P03-304', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '53106Y28408', 'SPRINGER 42NCA022515L5', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-02400', '309C-P03-304', '309C-P03-304', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '62N743739', '51BXR010-B-761-62', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02399', '309C-P03-304', '309C-P03-304', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5106D21253', 'TEMPSTAR 38XCB012515NF', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-02397', '309C-P03-304', '309C-P03-304', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0807B37986', '42XQB018515LC', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-01785', 'AT13-SS1-000', 'AT13-SS1-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'CARRIER 42LQA030515KC 30000Btu/h R22 220V', '0', 'Garantia');
insert into assets values ('ACAT-CG1-BOM-00036', 'BL02-SS1-008', 'BL02-SS1-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Motor Trifásico 7,5cv 1740rpm 5,5kW', '0', 'Garantia');
insert into assets values ('ACAT-CG1-BOM-00035', 'BL02-SS1-008', 'BL02-SS1-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Motor Trifásico 7,5cv 1740rpm 5,5kW', '0', 'Garantia');
insert into assets values ('ACAT-CG1-BOM-00034', 'BL02-SS1-008', 'BL02-SS1-008', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Motor Trifásico 7,5cv 1740rpm 5,5kW', '0', 'Garantia');
insert into assets values ('ACAT-000-CAS-00044', 'BL02-SS1-017', 'BL02-SS1-017', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '-', '0', 'Garantia');
insert into assets values ('ACAT-000-EXT-00768', 'AX02-ATV-015', 'AX02-ATV-015', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Ventokit 280 40W 220V 280m3/h', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-00761', 'BL02-P02-014', 'BL02-P02-014', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0188PXACB00389K', 'SAMSUNG ASV24PSBTNXAZ / ASV24PSBTXXAZ', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-01018', 'AX02-AAA-004', 'AX02-AAA-004', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'CARRIER/42 PC 1212 E 220 - 2.6 TR', '0', 'Garantia');
insert into assets values ('ACAT-000-ACJ-00695', 'AX02-SS1-000', 'AX02-SS1-000', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', '-', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-00681', 'AX02-ATV-014', 'AX02-ATV-014', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '-', 'Carrier Dutado', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-00675', 'AX02-ATV-016', 'AX02-ATV-016', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '1614B12880127', 'Springer Carrier 40KWCA024515LC/38KCD024515MC 24.000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-CG1-BOM-00587', 'BL01-TER-063', 'BL01-TER-063', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '10766630', 'WEG 3132M', '0', 'Garantia');
insert into assets values ('ACAT-CG1-CHR-00583', 'BL01-TER-063', 'BL01-TER-063', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'B0509C0003', 'TRANE/RTAA100DYB1A0002', '0', 'Garantia');
insert into assets values ('ACAT-CG1-CHR-00582', 'BL01-TER-063', 'BL01-TER-063', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'B0509C0002', 'TRANE/RTAA100DYB1A0002', '0', 'Garantia');
insert into assets values ('ACAT-CG1-CHR-00581', 'BL01-TER-063', 'BL01-TER-063', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', 'B0509C0001', 'TRANE/RTAA100DYB1A0002', '0', 'Garantia');
insert into assets values ('ACAT-000-FCL-01298', 'AX02-TER-089', 'AX02-TER-089', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '5104887426', 'CARRIER 42DCB009515LC 9.000Btu/h 220V', '0', 'Garantia');
insert into assets values ('ACAT-000-SLF-01326', 'AX02-SS1-084', 'AX02-SS1-084', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0701B06720', 'CARRIER/50BZE16386S', '0', 'Garantia');
insert into assets values ('ACAT-000-SLF-01325', 'AX02-SS1-089', 'AX02-SS1-089', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4500B49838', 'CARRIER/50BZE163865', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-01324', 'AX02-SS1-089', 'AX02-SS1-089', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '4300B12162', 'CARRIER/40MSA040236VS', '0', 'Garantia');
insert into assets values ('ACAT-000-SPL-01323', 'AX02-SS1-089', 'AX02-SS1-089', 'Nome do equipamento', 'Descrição do ativo', 'A', 0, 0, 0, 'Fabricante', '0601B38941', 'CARRIER/40MSA040236VS ', '0', 'Garantia');

INSERT INTO contracts VALUES ('CT-2016-0134', '2016-09-23', null, '2016-09-23', 'Contrato de Compra de Energia Regulada - CCER - entre o SENADO FEDERAL e a CEB Distribuição S/A, de energia elétrica para as unidades consumidoras de identificação nº 466.453-1; 491.042-7; 491.747-2; 491.750-2; 493.169-6; 605.120-0; 623.849-1; 675.051-6; 966.027-5 e 1.089.425-X.', 'CEB Distribuição S.A.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/3842');
INSERT INTO contracts VALUES ('CTA-2017-0119', '2017-12-29', null, '2017-12-29', 'Estabelecer as principais condições da prestação e utilização do serviço público de energia elétrica entre a CEB Distribuição S.A e o SENADO FEDERAL, de acordo com as condições gerais de fornecimento de energia elétrica e demais regulamentos expedidos pela Agência Nacional de Energia Elétrica - ANEEL - no fornecimento continuado de energia elétrica para as diversas Unidades Consumidoras do Senado Federal, durante o período de 60 (sessenta) meses consecutivos.', 'CEB Distribuição S.A.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/4306');
INSERT INTO contracts VALUES ('TE-2017-0014', '2017-11-23', null, '2017-11-23', 'O Ministério de Estado do Planejamento, Desenvolvimento e Gestão, através da Secretaria de Patrimônio da União - MPDG/SPU - e a Presidência do SENADO FEDERAL, no uso de suas atribuições legais, resolvem celebrar a transferência ao Senado Federal, por meio de cessão de uso, do imóvel de propriedade da União situado no Setor de Clubes Esportivos Sul - SCE/SUL - Trecho 3 - Lote 07 - Brasília - Distrito Federal.', 'N/A', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/4262');
INSERT INTO contracts VALUES ('CT-2016-0165', '2016-12-19', null, '2016-12-19', 'Contratação de empresa prestadora, de forma contínua, dos serviços públicos de abastecimento de água e esgotamento sanitário, a serem utilizados no Complexo Arquitetônico do SENADO FEDERAL pela Companhia de Saneamento Ambiental do Distrito Federal - CAESB - durante o período indeterminado de vigência contratual.', 'CAESB - Companhia de Saneamento Ambiental do Distrito Federal', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/3931');
INSERT INTO contracts VALUES ('CT-2014-0088', '2014-12-09', '2019-12-08', '2014-12-09', 'Contratação de empresa especializada para a prestação de serviços de manutenção no Sistema de Geração de Energia Elétrica de Emergência, do Complexo Arquitetônico do SENADO FEDERAL, composto de 05 (cinco) grupos motores-geradores, movidos à óleo diesel, durante o período de 36 (trinta e seis) meses consecutivos.', 'RCS Tecnologia Ltda.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/3095');
INSERT INTO contracts VALUES ('CT-2016-110', '2016-08-25', '2021-08-24', '2016-08-25', 'Contratação de empresa especializada para a prestação de serviços continuados e sob demanda, referentes à operação e manutenção preventiva e corretiva do Sistema Elétrico do Complexo Arquitetônico do SENADO FEDERAL, com operação de sistema informatizado de gerenciamento de manutenção e suprimento de insumos necessários à execução dos serviços, durante o período de 36 (trinta e seis) meses consecutivos.', 'RCS Tecnologia Ltda.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/3769');
INSERT INTO contracts VALUES ('CT-2017-0084', '2017-10-24', '2017-12-01', '2020-11-30', 'Contratação de empresa especializada para prestação de serviços continuados e sob demanda, referentes à operação, manutenção preventiva e corretiva do Sistema Hidrossanitário em todo o Complexo Arquitetônico do SENADO FEDERAL, incluindo a operação de sistema de controle de manutenção informatizado, fornecimento de suprimentos, insumos e de mão de obra necessários à plena execução dos serviços, durante o período de 36 (trinta e seis) meses consecutivos.', 'RCS Tecnologia Ltda.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/4298');

insert into departments values ('SF', 'SF', 'Senado Federal', true);
insert into departments values ('COMDIR', 'SF', 'COMISSÃO DIRETORA', true);
insert into departments values ('PRVPRE', 'COMDIR', 'PRIMEIRA VICE-PRESIDÊNCIA', true);
insert into departments values ('SGVPRE', 'COMDIR', 'SEGUNDA VICE-PRESIDÊNCIA', true);
insert into departments values ('PRSECR', 'COMDIR', 'PRIMEIRA SECRETARIA', true);
insert into departments values ('SGSECR', 'COMDIR', 'SEGUNDA SECRETARIA', true);
insert into departments values ('TRSECR', 'COMDIR', 'TERCEIRA SECRETARIA', true);
insert into departments values ('QTSECR', 'COMDIR', 'QUARTA SECRETARIA', true);
insert into departments values ('PRSUPL', 'COMDIR', 'GABINETE DO PRIMEIRO SUPLENTE DE SECRETÁRIO', true);
insert into departments values ('SGSUPL', 'COMDIR', 'GABINETE DO SEGUNDO SUPLENTE DE SECRETÁRIO', true);
insert into departments values ('TRSUPL', 'COMDIR', 'GABINETE DO TERCEIRO SUPLENTE DE SECRETÁRIO', true);
insert into departments values ('QTSUPL', 'COMDIR', 'GABINETE DO QUARTO SUPLENTE DE SECRETÁRIO', true);
insert into departments values ('CEDIT', 'COMDIR', 'CONSELHO EDITORIAL', true);
insert into departments values ('CGCGE', 'COMDIR', 'COMITÊ DE GOVERNANÇA CORPORATIVA E GESTÃO ESTRATÉGICA', true);
insert into departments values ('COSILB', 'COMDIR', 'CONSELHO DE SUPERVISÃO DO ILB', true);
insert into departments values ('CSIS', 'COMDIR', 'CONSELHO DE SUPERVISÃO DO SISTEMA INTEGRADO DE SAÚDE(SIS)', true);
insert into departments values ('PRESID', 'SF', 'PRESIDÊNCIA', true);
insert into departments values ('CEPRES', 'PRESID', 'CERIMONIAL DA PRESIDENCIA', true);
insert into departments values ('SECOEV', 'CEPRES', 'SERVIÇO DE COORDENAÇÃO DE EVENTOS', true);
insert into departments values ('SEPGPR', 'CEPRES', 'SERVIÇO DE PLANEJAMENTO E GESTÃO', true);
insert into departments values ('SERAGE', 'CEPRES', 'SERVIÇO DE RECEPÇÃO E AGENDA', true);
insert into departments values ('GBPRES', 'PRESID', 'GABINETE DA PRESIDÊNCIA', true);
insert into departments values ('ASIMP', 'PRESID', 'ASSESSORIA DE IMPRENSA DA PRESIDÊNCIA', true);
insert into departments values ('ASPRES', 'PRESID', 'ASSESSORIA TÉCNICA DA PRESIDÊNCIA', true);
insert into departments values ('SERINT', 'PRESID', 'SECRETARIA DE RELAÇÕES INTERNACIONAIS DA PRESIDÊNCIA', true);
insert into departments values ('STRANS', 'PRESID', 'SECRETARIA DE TRANSPARÊNCIA', true);
insert into departments values ('ATSTRANS', 'STRANS', 'ASSESSORIA TÉCNICA DA STRANS', true);
insert into departments values ('DATASEN', 'STRANS', 'INSTITUTO DE PESQUISA DATASENADO', true);
insert into departments values ('SEGS', 'DATASEN', 'SERVIÇO DE GERENCIAMENTO DE SISTEMAS', true);
insert into departments values ('SEPEA', 'DATASEN', 'SERVIÇO DE PESQUISA E ANÁLISE', true);
insert into departments values ('OMV', 'DATASEN', 'OBSERVATÓRIO DA MULHER CONTRA A VIOLÊNCIA', true);
insert into departments values ('DATJUR', 'PRESID', 'DIRETORIA DE ASSUNTOS TÉCNICOS E JURÍDICOS', true);
insert into departments values ('GABSEN', 'SF', 'GABINETES DOS SENADORES', true);
insert into departments values ('GSAANAST', 'GABSEN', 'GABINETE DO SENADOR ANTONIO ANASTASIA', true);
insert into departments values ('E1AANAST', 'GSAANAST', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR ANTONIO ANASTASIA', true);
insert into departments values ('GSACORON', 'GABSEN', 'GABINETE DO SENADOR ANGELO CORONEL', true);
insert into departments values ('E1ACORON', 'GSACORON', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR ANGELO CORONEL', true);
insert into departments values ('GSADIA', 'GABSEN', 'GABINETE DO SENADOR ALVARO DIAS', true);
insert into departments values ('EAADIA', 'GSADIA', 'ESCRITÓRIO DE AP. Nº 01 DO SENADOR ALVARO DIAS', true);
insert into departments values ('GSAGUR', 'GABSEN', 'GABINETE DO SENADOR ACIR GURGACZ', true);
insert into departments values ('EAAGUR', 'GSAGUR', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR ACIR GURGACZ', true);
insert into departments values ('GSAOLIVE', 'GABSEN', 'GABINETE DO SENADOR AROLDE DE OLIVEIRA', true);
insert into departments values ('E1AOLIVE', 'GSAOLIVE', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR AROLDE DE OLIVEIRA', true);
insert into departments values ('GSAVIEIR', 'GABSEN', 'GABINETE DO SENADOR ALESSANDRO VIEIRA', true);
insert into departments values ('E1AVIEIR', 'GSAVIEIR', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR ALESSANDRO VIEIRA', true);
insert into departments values ('GSCGOMES', 'GABSEN', 'GABINETE DO SENADOR CID GOMES', true);
insert into departments values ('E1CGOMES', 'GSCGOMES', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR CID GOMES', true);
insert into departments values ('GSCMOURA', 'GABSEN', 'GABINETE DO SENADOR CONFÚCIO MOURA', true);
insert into departments values ('E1CMOURA', 'GSCMOURA', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR SENADOR CONFÚCIO MOURA', true);
insert into departments values ('GSCNOG', 'GABSEN', 'GABINETE DO SENADOR CIRO NOGUEIRA', true);
insert into departments values ('E1CNOG', 'GSCNOG', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR CIRO NOGUEIRA', true);
insert into departments values ('GSCRODRI', 'GABSEN', 'GABINETE DO SENADOR CHICO RODRIGUES', true);
insert into departments values ('E1CRODRI', 'GSCRODRI', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR CHICO RODRIGUES', true);
insert into departments values ('GSCVIANA', 'GABSEN', 'GABINETE DO SENADOR CARLOS VIANA', true);
insert into departments values ('E1CVIANA', 'GSCVIANA', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR CARLOS VIANA', true);
insert into departments values ('GSDALCOL', 'GABSEN', 'GABINETE DO SENADOR DAVI ALCOLUMBRE', true);
insert into departments values ('E1DALCOL', 'GSDALCOL', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR DAVI ALCOLUMBRE', true);
insert into departments values ('GSDBERGE', 'GABSEN', 'GABINETE DO SENADOR DÁRIO BERGER', true);
insert into departments values ('E1DBERGE', 'GSDBERGE', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR DÁRIO BERGER', true);
insert into departments values ('GSDRIBEI', 'GABSEN', 'GABINETE DA SENADORA DANIELLA RIBEIRO', true);
insert into departments values ('E1DRIBEI', 'GSDRIBEI', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA DANIELLA RIBEIRO', true);
insert into departments values ('GSEAMI', 'GABSEN', 'GABINETE DO SENADOR ESPERIDIÃO AMIN', true);
insert into departments values ('E1EAMI', 'GSEAMI', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR ESPERIDIÃO AMIN', true);
insert into departments values ('GSEBRA', 'GABSEN', 'GABINETE DO SENADOR EDUARDO BRAGA', true);
insert into departments values ('E1EBRA', 'GSEBRA', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR EDUARDO BRAGA', true);
insert into departments values ('GSEFERRE', 'GABSEN', 'GABINETE DO SENADOR ELMANO FÉRRER', true);
insert into departments values ('E1EFERRE', 'GSEFERRE', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR ELMANO FÉRRER', true);
insert into departments values ('GSEGAMA', 'GABSEN', 'GABINETE DA SENADORA ELIZIANE GAMA', true);
insert into departments values ('E1EGAMA', 'GSEGAMA', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA ELIZIANE GAMA', true);
insert into departments values ('GSEGIRAO', 'GABSEN', 'GABINETE DO SENADOR EDUARDO GIRÃO', true);
insert into departments values ('E1EGIRAO', 'GSEGIRAO', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR EDUARDO GIRÃO', true);
insert into departments values ('GSFARN', 'GABSEN', 'GABINETE DO SENADOR FLÁVIO ARNS', true);
insert into departments values ('EAFARN', 'GSFARN', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR FLÁVIO ARNS', true);
insert into departments values ('GSFB', 'GABSEN', 'GABINETE DO SENADOR FLÁVIO BOLSONARO', true);
insert into departments values ('E1FB', 'GSFB', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR FLÁVIO BOLSONARO', true);
insert into departments values ('GSFCONTA', 'GABSEN', 'GABINETE DO SENADOR FABIANO CONTARATO', true);
insert into departments values ('E1FCONTA', 'GSFCONTA', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR FABIANO CONTARATO', true);
insert into departments values ('GSFERCOE', 'GABSEN', 'GABINETE DO SENADOR FERNANDO BEZERRA COELHO', true);
insert into departments values ('E1FERCOE', 'GSFERCOE', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR FERNANDO BEZERRA COELHO', true);
insert into departments values ('E2FERCOE', 'GSFERCOE', 'ESCRITÓRIO DE APOIO Nº 02 DO SENADOR FERNANDO BEZERRA COELHO', true);
insert into departments values ('GSHCST', 'GABSEN', 'GABINETE DO SENADOR HUMBERTO COSTA', true);
insert into departments values ('E1HCST', 'GSHCST', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR HUMBERTO COSTA', true);
insert into departments values ('E2HCST', 'GSHCST', 'ESCRITÓRIO DE APOIO Nº 02 DO SENADOR HUMBERTO COSTA', true);
insert into departments values ('GSIRAJA', 'GABSEN', 'GABINETE DO SENADOR IRAJÁ', true);
insert into departments values ('E1IRAJA', 'GSIRAJA', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR IRAJÁ', true);
insert into departments values ('GSIZALCI', 'GABSEN', 'GABINETE DO SENADOR IZALCI LUCAS', true);
insert into departments values ('E1IZALCI', 'GSIZALCI', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR IZALCI LUCAS', true);
insert into departments values ('GSJAYM', 'GABSEN', 'GABINETE DO SENADOR JAYME CAMPOS', true);
insert into departments values ('E1JAYM', 'GSJAYM', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR JAYME CAMPOS', true);
insert into departments values ('GSJBAR', 'GABSEN', 'GABINETE DO SENADOR JADER BARBALHO', true);
insert into departments values ('E1JBAR', 'GSJBAR', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR JADER BABALHO', true);
insert into departments values ('GSJKAJUR', 'GABSEN', 'GABINETE DO SENADOR JORGE KAJURU', true);
insert into departments values ('E1JKAJUR', 'GSJKAJUR', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR JORGE KAJURU', true);
insert into departments values ('GSJMAR', 'GABSEN', 'GABINETE DO SENADOR JOSÉ MARANHÃO', true);
insert into departments values ('E1JMAR', 'GSJMAR', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR JOSÉ MARANHÃO', true);
insert into departments values ('GSJMELLO', 'GABSEN', 'GABINETE DO SENADOR JORGINHO MELLO', true);
insert into departments values ('E1JMELLO', 'GSJMELLO', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR JORGINHO MELLO', true);
insert into departments values ('GSJPRAT', 'GABSEN', 'GABINETE DO SENADOR JEAN PAUL PRATES', true);
insert into departments values ('E1JPRAT', 'GSJPRAT', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR JEAN PAUL PRATES', true);
insert into departments values ('GSJSELMA', 'GABSEN', 'GABINETE DA SENADORA JUÍZA SELMA', true);
insert into departments values ('E1JSELMA', 'GSJSELMA', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA JUÍZA SELMA', true);
insert into departments values ('GSJSER', 'GABSEN', 'GABINETE DO SENADOR JOSÉ SERRA', true);
insert into departments values ('E1JSER', 'GSJSER', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR JOSÉ SERRA', true);
insert into departments values ('GSJVAS', 'GABSEN', 'GABINETE DO SENADOR JARBAS VASCONCELOS', true);
insert into departments values ('EAJVAS', 'GSJVAS', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR JARBAS VASCONCELOS', true);
insert into departments values ('GSJWAG', 'GABSEN', 'GABINETE DO SENADOR JAQUES WAGNER', true);
insert into departments values ('E1JWAG', 'GSJWAG', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR JAQUES WAGNER', true);
insert into departments values ('GSKAAB', 'GABSEN', 'GABINETE DA SENADORA KÁTIA ABREU', true);
insert into departments values ('EAKAAB', 'GSKAAB', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA KÁTIA ABREU', true);
insert into departments values ('E2KAAB', 'GSKAAB', 'ESCRITÓRIO DE APOIO Nº 02 DA SENADORA KÁTIA ABREU', true);
insert into departments values ('GSLBARRE', 'GABSEN', 'GABINETE DO SENADOR LUCAS BARRETO', true);
insert into departments values ('E1LBARRE', 'GSLBARRE', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR LUCAS BARRETO', true);
insert into departments values ('GSLCARM', 'GABSEN', 'GABINETE DO SENADOR LUIZ CARLOS DO CARMO', true);
insert into departments values ('E1LCARM', 'GSLCARM', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR LUIZ CARLOS DO CARMO', true);
insert into departments values ('GSLEILAB', 'GABSEN', 'GABINETE DA SENADORA LEILA BARROS', true);
insert into departments values ('E1LEILAB', 'GSLEILAB', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA LEILA BARROS', true);
insert into departments values ('GSLHEINZ', 'GABSEN', 'GABINETE DO SENADOR LUIS CARLOS HEINZE', true);
insert into departments values ('E1LHEINZ', 'GSLHEINZ', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR LUIS CARLOS HEINZE', true);
insert into departments values ('E2LHEINZ', 'GSLHEINZ', 'ESCRITÓRIO DE APOIO Nº 02 DO SENADOR LUIS CARLOS HEINZE', true);
insert into departments values ('GSLMARTI', 'GABSEN', 'GABINETE DO SENADOR LASIER MARTINS', true);
insert into departments values ('E1LMARTI', 'GSLMARTI', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR LASIER MARTINS', true);
insert into departments values ('GSMALV', 'GABSEN', 'GABINETE DA SENADORA MARIA DO CARMO ALVES', true);
insert into departments values ('EAMALV', 'GSMALV', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA MARIA DO CARMO ALVES', true);
insert into departments values ('GSMBITTA', 'GABSEN', 'GABINETE DO SENADOR MARCIO BITTAR', true);
insert into departments values ('E1MBITTA', 'GSMBITTA', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR MARCIO BITTAR', true);
insert into departments values ('GSMCASTR', 'GABSEN', 'GABINETE DO SENADOR MARCELO CASTRO', true);
insert into departments values ('E1MCASTR', 'GSMCASTR', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR MARCELO CASTRO', true);
insert into departments values ('GSMGABRI', 'GABSEN', 'GABINETE DA SENADORA MARA GABRILLI', true);
insert into departments values ('E1MGABRI', 'GSMGABRI', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA MARA GABRILLI', true);
insert into departments values ('GSMGOM', 'GABSEN', 'GABINETE DA SENADORA MAILZA GOMES', true);
insert into departments values ('EAMGOM', 'GSMGOM', 'ESCRITÓRIO DE APOIO N°01 DA SENADORA MAILZA GOMES', true);
insert into departments values ('GSMJESUS', 'GABSEN', 'GABINETE DO SENADOR MECIAS DE JESUS', true);
insert into departments values ('E1MJESUS', 'GSMJESUS', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR MECIAS DE JESUS', true);
insert into departments values ('GSMROGER', 'GABSEN', 'GABINETE DO SENADOR MARCOS ROGÉRIO', true);
insert into departments values ('E1MROGER', 'GSMROGER', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR MARCOS ROGÉRIO', true);
insert into departments values ('GSMVAL', 'GABSEN', 'GABINETE DO SENADOR MARCOS DO VAL', true);
insert into departments values ('E1MVAL', 'GSMVAL', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR MARCOS DO VAL', true);
insert into departments values ('GSNTRAD', 'GABSEN', 'GABINETE DO SENADOR NELSINHO TRAD', true);
insert into departments values ('E1NTRAD', 'GSNTRAD', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR NELSINHO TRAD', true);
insert into departments values ('GSOALENC', 'GABSEN', 'GABINETE DO SENADOR OTTO ALENCAR', true);
insert into departments values ('E1OALENC', 'GSOALENC', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR OTTO ALENCAR', true);
insert into departments values ('GSOAZIZ', 'GABSEN', 'GABINETE DO SENADOR OMAR AZIZ', true);
insert into departments values ('E1OAZIZ', 'GSOAZIZ', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR OMAR AZIZ', true);
insert into departments values ('GSOGUIMA', 'GABSEN', 'GABINETE DO SENADOR ORIOVISTO GUIMARÃES', true);
insert into departments values ('E1OGUIMA', 'GSOGUIMA', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR ORIOVISTO GUIMARÃES', true);
insert into departments values ('GSOLIMPI', 'GABSEN', 'GABINETE DO SENADOR MAJOR OLIMPIO', true);
insert into departments values ('E1OLIMPI', 'GSOLIMPI', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR MAJOR OLIMPIO', true);
insert into departments values ('GSPAULOR', 'GABSEN', 'GABINETE DO SENADOR PAULO ROCHA', true);
insert into departments values ('E1PAULOR', 'GSPAULOR', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR PAULO ROCHA', true);
insert into departments values ('GSPPAI', 'GABSEN', 'GABINETE DO SENADOR PAULO PAIM', true);
insert into departments values ('EAPPAI', 'GSPPAI', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR PAULO PAIM', true);
insert into departments values ('GSPVALER', 'GABSEN', 'GABINETE DO SENADOR PLÍNIO VALÉRIO', true);
insert into departments values ('E1PVALER', 'GSPVALER', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR PLÍNIO VALÉRIO', true);
insert into departments values ('GSRBULH', 'GABSEN', 'GABINETE DA SENADORA RENILDE BULHÕES', true);
insert into departments values ('E1RBULH', 'GSRBULH', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA RENILDE BULHÕES', true);
insert into departments values ('GSRCAL', 'GABSEN', 'GABINETE DO SENADOR RENAN CALHEIROS', true);
insert into departments values ('EARCAL', 'GSRCAL', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR RENAN CALHEIROS', true);
insert into departments values ('GSRCUNHA', 'GABSEN', 'GABINETE DO SENADOR RODRIGO CUNHA', true);
insert into departments values ('E1RCUNHA', 'GSRCUNHA', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR RODRIGO CUNHA', true);
insert into departments values ('GSREGUFF', 'GABSEN', 'GABINETE DO SENADOR REGUFFE', true);
insert into departments values ('GSRFREIT', 'GABSEN', 'GABINETE DA SENADORA ROSE DE FREITAS', true);
insert into departments values ('E1RFREIT', 'GSRFREIT', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA ROSE DE FREITAS', true);
insert into departments values ('GSROMARI', 'GABSEN', 'GABINETE DO SENADOR ROMÁRIO', true);
insert into departments values ('E1ROMARI', 'GSROMARI', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR ROMÁRIO', true);
insert into departments values ('GSRPACHE', 'GABSEN', 'GABINETE DO SENADOR RODRIGO PACHECO', true);
insert into departments values ('E1RPACHE', 'GSRPACHE', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR RODRIGO PACHECO', true);
insert into departments values ('GSRROCHA', 'GABSEN', 'GABINETE DO SENADOR ROBERTO ROCHA', true);
insert into departments values ('E1RROCHA', 'GSRROCHA', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR ROBERTO ROCHA', true);
insert into departments values ('GSRROD', 'GABSEN', 'GABINETE DO SENADOR RANDOLFE RODRIGUES', true);
insert into departments values ('E1RROD', 'GSRROD', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR RANDOLFE RODRIGUES', true);
insert into departments values ('GSRSANT', 'GABSEN', 'GABINETE DO SENADOR ROGÉRIO CARVALHO', true);
insert into departments values ('E1RSANT', 'GSRSANT', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR ROGÉRIO CARVALHO', true);
insert into departments values ('GSSCAM', 'GABSEN', 'GABINETE DO SENADOR SIQUEIRA CAMPOS', true);
insert into departments values ('GSSCASTR', 'GABSEN', 'GABINETE DO SENADOR SÉRGIO DE CASTRO', true);
insert into departments values ('E1SCASTR', 'GSSCASTR', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR SÉRGIO DE CASTRO', true);
insert into departments values ('GSSPET', 'GABSEN', 'GABINETE DO SENADOR SÉRGIO PETECÃO', true);
insert into departments values ('E1SPET', 'GSSPET', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR SÉRGIO PETECÃO', true);
insert into departments values ('GSSTEBET', 'GABSEN', 'GABINETE DA SENADORA SIMONE TEBET', true);
insert into departments values ('E1STEBET', 'GSSTEBET', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA SIMONE TEBET', true);
insert into departments values ('GSSTHRON', 'GABSEN', 'GABINETE DA SENADORA SORAYA THRONICKE', true);
insert into departments values ('E1STHRON', 'GSSTHRON', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA SORAYA THRONICKE', true);
insert into departments values ('GSSTYVEN', 'GABSEN', 'GABINETE DO SENADOR STYVENSON VALENTIM', true);
insert into departments values ('E1STYVEN', 'GSSTYVEN', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR STYVENSON VALENTIM', true);
insert into departments values ('GSTJER', 'GABSEN', 'GABINETE DO SENADOR TASSO JEREISSATI', true);
insert into departments values ('EATJER', 'GSTJER', 'ESCRITÓRIO DE AP. Nº 01 DO SENADOR TASSO JEREISSATI', true);
insert into departments values ('GSTMOTA', 'GABSEN', 'GABINETE DO SENADOR TELMÁRIO MOTA', true);
insert into departments values ('E1TMOTA', 'GSTMOTA', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR TELMÁRIO MOTA', true);
insert into departments values ('GSTPINTO', 'GABSEN', 'GABINETE DO SENADOR THIERES PINTO', true);
insert into departments values ('E1TPINTO', 'GSTPINTO', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR THIERES PINTO', true);
insert into departments values ('GSVANDER', 'GABSEN', 'GABINETE DO SENADOR VANDERLAN CARDOSO', true);
insert into departments values ('E1VANDER', 'GSVANDER', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR VANDERLAN CARDOSO', true);
insert into departments values ('GSVENEZI', 'GABSEN', 'GABINETE DO SENADOR VENEZIANO VITAL DO RÊGO', true);
insert into departments values ('E1VENEZI', 'GSVENEZI', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR VENEZIANO VITAL RÊGO', true);
insert into departments values ('GSWEVERT', 'GABSEN', 'GABINETE DO SENADOR WEVERTON ROCHA', true);
insert into departments values ('E1WEVERT', 'GSWEVERT', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR WEVERTON ROCHA', true);
insert into departments values ('GSWFAGUN', 'GABSEN', 'GABINETE DO SENADOR WELLINGTON FAGUNDES', true);
insert into departments values ('E1WFAGUN', 'GSWFAGUN', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR WELLINGTON FAGUNDES', true);
insert into departments values ('E2WFAGUN', 'GSWFAGUN', 'ESCRITÓRIO DE APOIO Nº 02 DO SENADOR WELLINGTON FAGUNDES', true);
insert into departments values ('GSZMAIA', 'GABSEN', 'GABINETE DA SENADORA ZENAIDE MAIA', true);
insert into departments values ('E1ZMAIA', 'GSZMAIA', 'ESCRITÓRIO DE APOIO Nº 01 DA SENADORA ZENAIDE MAIA', true);
insert into departments values ('GSZMARIN', 'GABSEN', 'GABINETE DO SENADOR ZEQUINHA MARINHO', true);
insert into departments values ('E1ZMARIN', 'GSZMARIN', 'ESCRITÓRIO DE APOIO Nº 01 DO SENADOR ZEQUINHA MARINHO', true);
insert into departments values ('GABLID', 'SF', 'GABINETES DE LIDERANÇAS', true);
insert into departments values ('BLMCON', 'GABLID', 'BLOCO DA LIDERANÇA DA MINORIA NO CONGRESSO NACIONAL', true);
insert into departments values ('BLPP', 'GABLID', 'BLOCO PARLAMENTAR PSDB/PSL', true);
insert into departments values ('BLPRD', 'GABLID', 'BLOCO PARLAMENTAR DA RESISTÊNCIA DEMOCRÁTICA', true);
insert into departments values ('BLSENIND', 'GABLID', 'BLOCO PARLAMENTAR SENADO INDEPENDENTE', true);
insert into departments values ('BLUNIDB', 'GABLID', 'BLOCO PARLAMENTAR UNIDOS PELO BRASIL', true);
insert into departments values ('BLVANG', 'GABLID', 'BLOCO PARLAMENTAR VANGUARDA', true);
insert into departments values ('GLCID', 'GABLID', 'GABINETE DA LIDERANÇA DO CIDADANIA', true);
insert into departments values ('GLDEM', 'GABLID', 'GABINETE DA LIDERANÇA DOS DEMOCRATAS', true);
insert into departments values ('GLDGCN', 'GABLID', 'GABINETE DA LIDERANÇA DO GOVERNO NO CONGRESSO NACIONAL', true);
insert into departments values ('GLDGOV', 'GABLID', 'GABINETE DA LIDERANÇA DO GOVERNO', true);
insert into departments values ('GLDMAI', 'GABLID', 'GABINETE DA LIDERANÇA DO BLOCO DA MAIORIA', true);
insert into departments values ('GLDMIN', 'GABLID', 'GABINETE DA LIDERANÇA DO BLOCO DA MINORIA', true);
insert into departments values ('GLDPDT', 'GABLID', 'GABINETE DA LIDERANÇA DO PDT', true);
insert into departments values ('GLDPP', 'GABLID', 'GABINETE DA LIDERANÇA DO PARTIDO PROGRESSISTA', true);
insert into departments values ('GLDPR', 'GABLID', 'GABINETE DA LIDERANÇA DO PARTIDO DA REPUBLICA', true);
insert into departments values ('GLDPSB', 'GABLID', 'GABINETE DA LIDERANÇA DO PSB', true);
insert into departments values ('GLDPT', 'GABLID', 'GABINETE DA LIDERANÇA DO PT', true);
insert into departments values ('GLIDPSL', 'GABLID', 'GABINETE DA LIDERANÇA DO PSL', true);
insert into departments values ('GLMDB', 'GABLID', 'GABINETE DA LIDERANÇA DO MDB', true);
insert into departments values ('GLPL', 'GABLID', 'GABINETE DA LIDERANÇA DO PARTIDO LIBERAL', true);
insert into departments values ('GLPODEMOS', 'GABLID', 'GABINETE DA LIDERANÇA DO PODEMOS', true);
insert into departments values ('GLPPL', 'GABLID', 'GABINETE DA LIDERANÇA DO PPL', true);
insert into departments values ('GLPRB', 'GABLID', 'GABINETE DA LIDERANÇA DO PRB', true);
insert into departments values ('GLPROS', 'GABLID', 'GABINETE DA LIDERANÇA DO PARTIDO REPUBLICANO DA ORDEM SOCIAL – PROS', true);
insert into departments values ('GLPSC', 'GABLID', 'GABINETE DA LIDERANÇA DO PSC', true);
insert into departments values ('GLPSD', 'GABLID', 'GABINETE DA LIDERANÇA DO PSD', true);
insert into departments values ('GLPSDB', 'GABLID', 'GABINETE DA LIDERANÇA DO PSDB', true);
insert into departments values ('GLPV', 'GABLID', 'GABINETE DA LIDERANÇA DO PV', true);
insert into departments values ('GLREDE', 'GABLID', 'GABINETE DA LIDERANÇA DO REDE SUSTENTABILIDADE', true);
insert into departments values ('OSE', 'SF', 'ÓRGÃOS SUPERIORES DE EXECUÇÃO', true);
insert into departments values ('DGER', 'OSE', 'DIRETORIA-GERAL', true);
insert into departments values ('GBDGER', 'DGER', 'GABINETE DA DIRETORIA GERAL', true);
insert into departments values ('SEADGR', 'GBDGER', 'SERVIÇO DE APOIO ADMINISTRATIVO DO GBDGER', true);
insert into departments values ('EDGER', 'GBDGER', 'ESCRITÓRIO SETORIAL DE GESTÃO DA DGER', true);
insert into departments values ('ASQUALOG', 'DGER', 'ASSESSORIA DE QUALIDADE DE ATENDIMENTO E LOGÍSTICA', true);
insert into departments values ('SEGEPAVI', 'ASQUALOG', 'SERVIÇO DE GESTÃO DE PASSAGENS AÉREAS, PASSAPORTES E VISTOS', true);
insert into departments values ('SEQUALOG', 'ASQUALOG', 'SERVIÇO DE APOIO ADMINISTRATIVO DA ASQUALOG', true);
insert into departments values ('ATDGER', 'DGER', 'ASSESSORIA TÉCNICA DA DIRETORIA-GERAL', true);
insert into departments values ('PRDSTI', 'DGER', 'SECRETARIA DE TECNOLOGIA DA INFORMAÇÃO PRODASEN', true);
insert into departments values ('GBPRD', 'PRDSTI', 'GABINETE ADMINISTRATIVO DO PRODASEN', true);
insert into departments values ('SACTI', 'PRDSTI', 'SERVIÇO DE APOIO ÀS CONTRATAÇÕES DE TI', true);
insert into departments values ('COATEN', 'PRDSTI', 'COORDENAÇÃO DE ATENDIMENTO', true);
insert into departments values ('SAEQUI', 'COATEN', 'SERVIÇO DE ADMINISTRAÇÃO DE EQUIPAMENTOS', true);
insert into departments values ('SEAATE', 'COATEN', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COATEN', true);
insert into departments values ('SEADMT', 'COATEN', 'SERVIÇO DE ATENDIMENTO ADMINISTRATIVO', true);
insert into departments values ('SEARE', 'COATEN', 'SERVIÇO DE ATENDIMENTO ÀS ÁREAS ESPECIAIS', true);
insert into departments values ('SEARP', 'COATEN', 'SERVIÇO DE ATENDIMENTO REMOTO E PRESENCIAL', true);
insert into departments values ('SEATLE', 'COATEN', 'SERVIÇO DE ATENDIMENTO LEGISLATIVO', true);
insert into departments values ('SEMOTI', 'COATEN', 'SERVIÇO DE CONTROLE DE QUALIDADE E MONITORAÇÃO DA PLATAFORMA DE TECNOLOGIA DA INFORMAÇÃO', true);
insert into departments values ('SEPARL', 'COATEN', 'SERVIÇO DE ATENDIMENTO PARLAMENTAR', true);
insert into departments values ('SERMAN', 'COATEN', 'SERVIÇO DE RELACIONAMENTO COM MANTENEDORES', true);
insert into departments values ('COINTI', 'PRDSTI', 'COORDENAÇÃO DE INFRAESTRUTURA DE TECNOLOGIA DA INFORMAÇÃO', true);
insert into departments values ('SEAINT', 'COINTI', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COINTI', true);
insert into departments values ('SEINDC', 'COINTI', 'SERVIÇO DE APOIO À INFRAESTRUTURA DE DATACENTER', true);
insert into departments values ('SEPRTI', 'COINTI', 'SERVIÇO DE PRODUÇÃO DA COINTI', true);
insert into departments values ('SESBD', 'COINTI', 'SERVIÇO DE SUPORTE A BANCO DE DADOS', true);
insert into departments values ('SESIA', 'COINTI', 'SERVIÇO DE SUPORTE À INFRAESTRUTURA DE APLICAÇÕES', true);
insert into departments values ('SESIER', 'COINTI', 'SERVIÇO DE SUPORTE À INFRAESTRUTURA DE REDE', true);
insert into departments values ('SESIET', 'COINTI', 'SERVIÇO DE SUPORTE À INFRAESTRUTURA E ESTAÇÕES DE TRABALHO', true);
insert into departments values ('SESSR', 'COINTI', 'SERVIÇO DE SUPORTE A EQUIPAMENTOS SERVIDORES DE REDE', true);
insert into departments values ('SGMD', 'COINTI', 'SERVIÇO DE GERÊNCIA DE MUDANÇAS', true);
insert into departments values ('COLEP', 'PRDSTI', 'COORDENAÇÃO DE INFORMÁTICA LEGISLATIVA E PARLAMENTAR', true);
insert into departments values ('SEALEP', 'COLEP', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COLEP', true);
insert into departments values ('SECN', 'COLEP', 'SERVIÇO DE SOLUÇÕES PARA O CONGRESSO NACIONAL', true);
insert into departments values ('SEDSVE', 'COLEP', 'SERVIÇO DE DESENVOLVIMENTO DO SISTEMA DE VOTAÇÃO ELETRÔNICA', true);
insert into departments values ('SEGAB', 'COLEP', 'SERVIÇO DE SOLUÇÕES PARA GABINETES PARLAMENTARES', true);
insert into departments values ('SELEJU', 'COLEP', 'SERVIÇO DE SOLUÇÕES PARA INFORMAÇÃO LEGISLATIVA E JURÍDICA', true);
insert into departments values ('SEPLE', 'COLEP', 'SERVIÇO DE SOLUÇÕES PARA O PROCESSO LEGISLATIVO ELETRÔNICO', true);
insert into departments values ('SESAP', 'COLEP', 'SERVIÇO DE SOLUÇÕES PARA A ATIVIDADE PARLAMENTAR E CONSULTORIAS', true);
insert into departments values ('SESCOM', 'COLEP', 'SERVIÇO DE SOLUÇÕES PARA AS COMISSÕES', true);
insert into departments values ('SESOF', 'COLEP', 'SERVIÇO DE SOLUÇÕES PARA O ORÇAMENTO E FISCALIZAÇÃO', true);
insert into departments values ('SESPLE', 'COLEP', 'SERVIÇO DE SOLUÇÕES PARA O PLENÁRIO', true);
insert into departments values ('COSTIC', 'PRDSTI', 'COORDENAÇÃO DE SOLUÇÕES DE TECNOLOGIA DA INFORMAÇÃO CORPORATIVA', true);
insert into departments values ('SEAIND', 'COSTIC', 'SERVIÇO DE ARQUITETURA DA INFORMAÇÃO E DESIGN', true);
insert into departments values ('SEATIC', 'COSTIC', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COSTIC', true);
insert into departments values ('SEIDIC', 'COSTIC', 'SERVIÇO DE SOLUÇÕES PARA ÁREAS DE INFORMAÇÃO, DOCUMENTAÇÃO E COMUNICAÇÃO SOCIAL', true);
insert into departments values ('SEPOR', 'COSTIC', 'SERVIÇO DE SOLUÇÕES PARA PORTAIS', true);
insert into departments values ('SESADM', 'COSTIC', 'SERVIÇO DE SOLUÇÕES PARA ÁREAS TÉCNICAS E ADMINISTRATIVAS', true);
insert into departments values ('SESAS', 'COSTIC', 'SERVIÇO DE SOLUÇÕES PARA ÁREAS DE ASSESSORAMENTO SUPERIOR', true);
insert into departments values ('SESIC', 'COSTIC', 'SERVIÇO DE SOLUÇÕES DE INTELIGÊNCIA CORPORATIVA', true);
insert into departments values ('SESOC', 'COSTIC', 'SERVIÇO DE SOLUÇÕES CORPORATIVAS', true);
insert into departments values ('SESRH', 'COSTIC', 'SERVIÇO DE SOLUÇÕES PARA ÁREA DE RECURSOS HUMANOS', true);
insert into departments values ('EPRD', 'PRDSTI', 'ESCRITÓRIO SETORIAL DE GESTÃO DO PRODASEN', true);
insert into departments values ('NQPPPS', 'PRDSTI', 'NÚCLEO DE QUALIDADE E PADRONIZAÇÃO DE PROCESSOS E PRODUTOS DE SOFTWARE', true);
insert into departments values ('SADCON', 'DGER', 'SECRETARIA DE ADMINISTRAÇÃO DE CONTRATAÇÕES', true);
insert into departments values ('COATC', 'SADCON', 'COORDENAÇÃO DE APOIO TÉCNICO A CONTRATAÇÕES', true);
insert into departments values ('SACT', 'COATC', 'SERVIÇO DE APOIO A CONTRATAÇÕES EM TECNOLOGIA', true);
insert into departments values ('SEEDIT', 'COATC', 'SERVIÇO DE ELABORAÇÃO DE EDITAIS', true);
insert into departments values ('SEELAC', 'COATC', 'SERVIÇO DE ELABORAÇÃO DE CONTRATOS', true);
insert into departments values ('COCDIR', 'SADCON', 'COORDENAÇÃO DE CONTRATAÇÕES DIRETAS', true);
insert into departments values ('SEECON', 'COCDIR', 'SERVIÇO DE EXECUÇÃO DE CONTRATOS', true);
insert into departments values ('SEEXCO', 'COCDIR', 'SERVIÇO DE EXECUÇÃO DE COMPRAS', true);
insert into departments values ('SEGREP', 'COCDIR', 'SERVIÇO DE GERENCIAMENTO DE REGISTRO DE PREÇOS', true);
insert into departments values ('COCVAP', 'SADCON', 'COORDENAÇÃO DE CONTROLE E VALIDAÇÃO DE PROCESSOS', true);
insert into departments values ('SELESC', 'COCVAP', 'SERVIÇO DE ELABORAÇÃO DE ESTIMATIVA DE CUSTOS', true);
insert into departments values ('COPLAC', 'SADCON', 'COORDENAÇÃO DE PLANEJAMENTO E CONTROLE DE CONTRATAÇÕES', true);
insert into departments values ('SECON', 'COPLAC', 'SERVIÇO DE CONTRATOS', true);
insert into departments values ('SEINPE', 'COPLAC', 'SERVIÇO DE INSTRUÇÃO DE PENALIDADES', true);
insert into departments values ('SEPCO', 'COPLAC', 'SERVIÇO DE PLANEJAMENTO E CONTROLE', true);
insert into departments values ('SIRC', 'COPLAC', 'SERVIÇO DE INSTRUÇÃO DE REAJUSTES CONTRATUAIS', true);
insert into departments values ('COPELI', 'SADCON', 'COMISSÃO PERMANENTE DE LICITAÇÃO', true);
insert into departments values ('SEACPL', 'COPELI', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COPELI', true);
insert into departments values ('SECADFOR', 'COPELI', 'SERVIÇO DE CADASTRO DE FORNECEDORES', true);
insert into departments values ('SEINPLP', 'COPELI', 'SERVIÇO DE INSTRUÇÃO PROCESSUAL', true);
insert into departments values ('EDCON', 'SADCON', 'ESCRITÓRIO SETORIAL DE GESTÃO DA SADCON', true);
insert into departments values ('SAFIN', 'DGER', 'SECRETARIA DE FINANÇAS, ORÇAMENTO E CONTABILIDADE', true);
insert into departments values ('SEGCPA', 'SAFIN', 'SERVIÇO DE GESTÃO', true);
insert into departments values ('COEXECO', 'SAFIN', 'COORDENAÇÃO DE EXECUÇÃO ORÇAMENTÁRIA', true);
insert into departments values ('SERCOE', 'COEXECO', 'SERVIÇO DE REVISÃO E CONTROLE DE EMPENHOS', true);
insert into departments values ('COEXEFI', 'SAFIN', 'COORDENAÇÃO DE EXECUÇÃO FINANCEIRA', true);
insert into departments values ('SEPADA', 'COEXEFI', 'SERVIÇO DE PAGAMENTO DE DESPESAS ADMINISTRATIVAS', true);
insert into departments values ('SEPAF', 'COEXEFI', 'SERVIÇO DE PAGAMENTO A FORNECEDORES', true);
insert into departments values ('SEPAFOL', 'COEXEFI', 'SERVIÇO DE PAGAMENTO DA FOLHA DE PESSOAL', true);
insert into departments values ('CONTAB', 'SAFIN', 'COORDENAÇÃO DE CONTABILIDADE', true);
insert into departments values ('SEACONF', 'CONTAB', 'SERVIÇO DE ANÁLISE DE CONFORMIDADE', true);
insert into departments values ('SECOB', 'CONTAB', 'SERVIÇO DE COBRANÇA ADMINISTRATIVA', true);
insert into departments values ('SECONTA', 'CONTAB', 'SERVIÇO DE CONTABILIDADE ANALÍTICA', true);
insert into departments values ('COPAC', 'SAFIN', 'COORDENAÇÃO DE PLANEJAMENTO E ACOMPANHAMENTO ORÇAMENTÁRIO', true);
insert into departments values ('SEAOIG', 'COPAC', 'SERVIÇO DE ACOMPANHAMENTO ORÇAMENTÁRIO E INFORMAÇÕES GERENCIAIS', true);
insert into departments values ('SEPEO', 'COPAC', 'SERVIÇO DE PLANEJAMENTO E ESTUDOS ORÇAMENTÁRIOS', true);
insert into departments values ('ESAFIN', 'SAFIN', 'ESCRITÓRIO SETORIAL DE GESTÃO DA SAFIN', true);
insert into departments values ('SEGP', 'DGER', 'SECRETARIA DE GESTÃO DE PESSOAS', true);
insert into departments values ('GBSEGP', 'SEGP', 'GABINETE ADMINISTRATIVO DA SEGP', true);
insert into departments values ('NSTSF', 'GBSEGP', 'NÚCLEO DE SERVIDORES EM TRÂNSITO - SF', true);
insert into departments values ('SEACOMP', 'SEGP', 'SERVIÇO DE APOIO A COMISSÕES PROCESSANTES', true);
insert into departments values ('SEARQP', 'SEGP', 'SERVIÇO DE ARQUIVO DE PESSOAL', true);
insert into departments values ('SEATUS', 'SEGP', 'SERVIÇO DE ATENDIMENTO AO USUÁRIO', true);
insert into departments values ('SEPUGP', 'SEGP', 'SERVIÇO DE PUBLICAÇÃO DA SEGP', true);
insert into departments values ('SESTI', 'SEGP', 'SERVIÇO DE SUPORTE EM TECNOLOGIA DA INFORMAÇÃO', true);
insert into departments values ('COAPES', 'SEGP', 'COORDENAÇÃO DE ADMINISTRAÇÃO DE PESSOAL', true);
insert into departments values ('SEAPES', 'COAPES', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COAPES', true);
insert into departments values ('SEDDEV', 'COAPES', 'SERVIÇO DE DIREITOS E DEVERES FUNCIONAIS', true);
insert into departments values ('SEFREQ', 'COAPES', 'SERVIÇO DE CONTROLE DE FREQUÊNCIA', true);
insert into departments values ('SEPCOM', 'COAPES', 'SERVIÇO DE CADASTRO PARLAMENTAR E PESSOAL COMISSIONADO', true);
insert into departments values ('SERCOPE', 'COAPES', 'SERVIÇO DE REGISTRO E CONTROLE DE PESSOAL EFETIVO', true);
insert into departments values ('SGEST', 'COAPES', 'SERVIÇO DE GESTÃO DE ESTÁGIOS', true);
insert into departments values ('NSASF', 'COAPES', 'NÚCLEO DE SERVIDORES AFASTADOS - SF', true);
insert into departments values ('COASAS', 'SEGP', 'COORDENAÇÃO DE ATENÇÃO À SAÚDE DO SERVIDOR', true);
insert into departments values ('SEJM', 'COASAS', 'SERVIÇO DE JUNTA MÉDICA', true);
insert into departments values ('SEMEDE', 'COASAS', 'SERVIÇO MÉDICO DE EMERGÊNCIA', true);
insert into departments values ('SESOQVT', 'COASAS', 'SERVIÇO DE SAÚDE OCUPACIONAL E QUALIDADE DE VIDA NO TRABALHO', true);
insert into departments values ('COASIS', 'SEGP', 'COORDENAÇÃO DE AUTORIZAÇÃO DO SIS', true);
insert into departments values ('COATREL', 'SEGP', 'COORDENAÇÃO DE ATENDIMENTO E RELACIONAMENTO', true);
insert into departments values ('SEABEN', 'COATREL', 'SERVIÇO DE ATENDIMENTO A BENEFICIÁRIOS', true);
insert into departments values ('SECRER', 'COATREL', 'SERVIÇO DE CREDENCIAMENTO E RELACIONAMENTO', true);
insert into departments values ('COBEP', 'SEGP', 'COORDENAÇÃO DE BENEFÍCIOS PREVIDENCIÁRIOS', true);
insert into departments values ('SEAPOPE', 'COBEP', 'SERVIÇO DE APOIO OPERACIONAL', true);
insert into departments values ('SEAPOS', 'COBEP', 'SERVIÇO DE APOSENTADORIA DE SERVIDORES', true);
insert into departments values ('SECOPE', 'COBEP', 'SERVIÇO DE CONCESSÃO DE PENSÕES', true);
insert into departments values ('SEINF', 'COBEP', 'SERVIÇO DE INSTRUÇÃO E REGISTROS FUNCIONAIS', true);
insert into departments values ('SEIPRE', 'COBEP', 'SERVIÇO DE CONTROLE E INFORMAÇÕES PREVIDENCIÁRIAS', true);
insert into departments values ('SESPAR', 'COBEP', 'SERVIÇO DE SEGURIDADE PARLAMENTAR', true);
insert into departments values ('COGEFI', 'SEGP', 'COORDENAÇÃO DE GESTÃO FINANCEIRA DO SIS', true);
insert into departments values ('SECOBR', 'COGEFI', 'SERVIÇO DE COBRANÇA', true);
insert into departments values ('SEPASI', 'COGEFI', 'SERVIÇO DE PAGAMENTO', true);
insert into departments values ('COPAG', 'SEGP', 'COORDENAÇÃO DE PAGAMENTO DE PESSOAL', true);
insert into departments values ('SEACFP', 'COPAG', 'SERVIÇO DE ANÁLISE E CONFERÊNCIA DA FOLHA DE PAGAMENTO', true);
insert into departments values ('SEAPAG', 'COPAG', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COPAG', true);
insert into departments values ('SECOCR', 'COPAG', 'SERVIÇO DE CONSTITUIÇÃO E COBRANÇA DE CRÉDITOS REMUNERATÓRIOS', true);
insert into departments values ('SECONF', 'COPAG', 'SERVIÇO DE CONSIGNAÇÕES FACULTATIVAS', true);
insert into departments values ('SEEFOL', 'COPAG', 'SERVIÇO DE ELABORAÇÃO DE FOLHA', true);
insert into departments values ('SEICAP', 'COPAG', 'SERVIÇO DE INSTRUÇÃO E CÁLCULOS', true);
insert into departments values ('SEOTIS', 'COPAG', 'SERVIÇO DE OBRIGAÇÕES TRIBUTÁRIAS E INFORMAÇÕES SOCIAIS', true);
insert into departments values ('COPOPE', 'SEGP', 'COORDENAÇÃO DE POLÍTICAS DE PESSOAL', true);
insert into departments values ('SECODEPE', 'COPOPE', 'SERVIÇO DE GESTÃO DE COMPETÊNCIAS, DESEMPENHO E POLÍTICAS DE', true);
insert into departments values ('SEGCAS', 'COPOPE', 'SERVIÇO DE GESTÃO DE CARGOS, SALÁRIOS E SELEÇÃO', true);
insert into departments values ('ESEGP', 'SEGP', 'ESCRITÓRIO SETORIAL DE GESTÃO DA SEGP', true);
insert into departments values ('NAPOPD', 'SEGP', 'APOSENTADOS - PD', true);
insert into departments values ('NAPOSE', 'SEGP', 'APOSENTADOS - SEEP', true);
insert into departments values ('NAPOSF', 'SEGP', 'APOSENTADOS - SF', true);
insert into departments values ('NFALPD', 'SEGP', 'FALECIDOS - PD', true);
insert into departments values ('NFALSE', 'SEGP', 'FALECIDOS - SEEP', true);
insert into departments values ('NFALSF', 'SEGP', 'FALECIDOS - SF', true);
insert into departments values ('SEGRAF', 'DGER', 'SECRETARIA DE EDITORAÇÃO E PUBLICAÇÕES', true);
insert into departments values ('GBGRAF', 'SEGRAF', 'GABINETE ADMINISTRATIVO DA SEGRAF', true);
insert into departments values ('SECFAT', 'SEGRAF', 'SERVIÇO DE CONVÊNIOS E FATURAMENTO', true);
insert into departments values ('SEDTI', 'SEGRAF', 'SERVIÇO DE DESENVOLVIMENTO DE TI E ATUALIZAÇÃO TECNOLÓGICA', true);
insert into departments values ('COEDIT', 'SEGRAF', 'COORDENAÇÃO DE EDIÇÕES TÉCNICAS', true);
insert into departments values ('SEAEDI', 'COEDIT', 'SERVIÇO DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SEDACERV', 'COEDIT', 'SERVIÇO DE DISTRIBUIÇÃO E CONTROLE DO ACERVO', true);
insert into departments values ('SELIVR', 'COEDIT', 'SERVIÇO DE LIVRARIA', true);
insert into departments values ('SEMID', 'COEDIT', 'SERVIÇO DE MULTIMÍDIA', true);
insert into departments values ('SEPQS', 'COEDIT', 'SERVIÇO DE PESQUISA DA COEDIT', true);
insert into departments values ('SEPUBT', 'COEDIT', 'SERVIÇO DE PUBLICAÇÕES TÉCNICO LEGISLATIVAS', true);
insert into departments values ('COGEP', 'SEGRAF', 'COORDENAÇÃO DE GESTÃO DA PRODUÇÃO', true);
insert into departments values ('SAUSEP', 'COGEP', 'SERVIÇO DE ATENDIMENTO AO USUÁRIO', true);
insert into departments values ('SEAGEP', 'COGEP', 'SERVIÇO DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SECOQU', 'COGEP', 'SERVIÇO DE CONTROLE DE QUALIDADE', true);
insert into departments values ('SEEREM', 'COGEP', 'SERVIÇO DE EXPEDIÇÃO E REMESSA', true);
insert into departments values ('SEGING', 'COGEP', 'SERVIÇO DE GESTÃO DE INSUMOS GRÁFICOS', true);
insert into departments values ('COIND', 'SEGRAF', 'COORDENAÇÃO INDUSTRIAL', true);
insert into departments values ('SEACAB', 'COIND', 'SERVIÇO DE ACABAMENTO', true);
insert into departments values ('SEACOI', 'COIND', 'SERVIÇO DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SECPRO', 'COIND', 'SERVIÇO DE CONTROLE DA PRODUÇÃO', true);
insert into departments values ('SEFPRO', 'COIND', 'SERVIÇO DE FORMATAÇÃO E PROGRAMAÇÃO VISUAL', true);
insert into departments values ('SEIB', 'COIND', 'SERVIÇO DE IMPRESSÃO EM BRAILLE', true);
insert into departments values ('SEID', 'COIND', 'SERVIÇO DE IMPRESSÃO DIGITAL', true);
insert into departments values ('SEIMOF', 'COIND', 'SERVIÇO DE IMPRESSÃO OFFSET', true);
insert into departments values ('SEMAIN', 'COIND', 'SERVIÇO DE MANUTENÇÃO INDUSTRIAL', true);
insert into departments values ('SEPDIG', 'COIND', 'SERVIÇO DE PROCESSAMENTO DIGITAL', true);
insert into departments values ('SEPIND', 'COIND', 'SERVIÇO DE PROGRAMAÇÃO INDUSTRIAL', true);
insert into departments values ('SEPUBL', 'COIND', 'SERVIÇO DE PUBLICAÇÕES OFICIAIS', true);
insert into departments values ('SERVSO', 'COIND', 'SERVIÇO DE REVISÃO', true);
insert into departments values ('EGRAF', 'SEGRAF', 'ESCRITÓRIO SETORIAL DE GESTÃO DA SEGRAF', true);
insert into departments values ('SGIDOC', 'DGER', 'SECRETARIA DE GESTÃO DE INFORMAÇÃO E DOCUMENTAÇÃO', true);
insert into departments values ('GBSGID', 'SGIDOC', 'GABINETE ADMINISTRATIVO DA SGIDOC', true);
insert into departments values ('SEADAJ', 'SGIDOC', 'SERVIÇO DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SETRIN', 'SGIDOC', 'SERVIÇO DE TRADUÇÃO E INTERPRETAÇÃO', true);
insert into departments values ('SICLAI', 'SGIDOC', 'SERVIÇO DE INFORMAÇÃO AO CIDADÃO', true);
insert into departments values ('COARQ', 'SGIDOC', 'COORDENAÇÃO DE ARQUIVO', true);
insert into departments values ('SEAHIS', 'COARQ', 'SERVIÇO DE ARQUIVO HISTÓRICO', true);
insert into departments values ('SEALEG', 'COARQ', 'SERVIÇO DE ARQUIVO LEGISLATIVO', true);
insert into departments values ('SEARAD', 'COARQ', 'SERVIÇO DE ARQUIVO ADMINISTRATIVO', true);
insert into departments values ('SECPAC', 'COARQ', 'SERVIÇO DE CONSERVAÇÃO E PRESERVAÇÃO DO ACERVO', true);
insert into departments values ('SECTA', 'COARQ', 'SERVIÇO DE CONSULTORIA TÉCNICA ARQUIVÍSTICA', true);
insert into departments values ('SEPESA', 'COARQ', 'SERVIÇO DE PESQUISA E ATENDIMENTO AO USUÁRIO', true);
insert into departments values ('SEPROELE', 'COARQ', 'SERVIÇO DE PROCESSO ELETRÔNICO', true);
insert into departments values ('SEPROT', 'COARQ', 'SERVIÇO DE PROTOCOLO ADMINISTRATIVO', true);
insert into departments values ('SEQARQ', 'COARQ', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COARQ', true);
insert into departments values ('COBIB', 'SGIDOC', 'COORDENAÇÃO DE BIBLIOTECA', true);
insert into departments values ('SEABIB', 'COBIB', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COBIB', true);
insert into departments values ('SEART', 'COBIB', 'SERVIÇO DE PROCESSAMENTO DE ARTIGOS DE REVISTA', true);
insert into departments values ('SEBIBT', 'COBIB', 'SERVIÇO DE BIBLIOTECA TÉCNICA DE INFORMÁTICA', true);
insert into departments values ('SEBID', 'COBIB', 'SERVIÇO DE BIBLIOTECA DIGITAL', true);
insert into departments values ('SEDECO', 'COBIB', 'SERVIÇO DE DESENVOLVIMENTO DE COLEÇÕES', true);
insert into departments values ('SEEMP', 'COBIB', 'SERVIÇO DE EMPRÉSTIMO E DEVOLUÇÃO DE MATERIAL BIBLIOGRÁFICO', true);
insert into departments values ('SEGER', 'COBIB', 'SERVIÇO DE GERÊNCIA DA REDE VIRTUAL DE BIBLIOTECAS', true);
insert into departments values ('SEJOR', 'COBIB', 'SERVIÇO DE PROCESSAMENTO DE JORNAIS', true);
insert into departments values ('SELIV', 'COBIB', 'SERVIÇO DE PROCESSAMENTO DE LIVROS', true);
insert into departments values ('SEMACO', 'COBIB', 'SERVIÇO DE MANUTENÇÃO E CONSERVAÇÃO DO ACERVO', true);
insert into departments values ('SEPESP', 'COBIB', 'SERVIÇO DE PESQUISA PARLAMENTAR', true);
insert into departments values ('SEPRIB', 'COBIB', 'SERVIÇO DE PESQUISA E RECUPERAÇÃO DE INFORMAÇÕES BIBLIOGRÁFICAS', true);
insert into departments values ('SERCOR', 'COBIB', 'SERVIÇO DE REGISTRO DE COLEÇÕES DE REVISTAS', true);
insert into departments values ('COMUS', 'SGIDOC', 'COORDENAÇÃO DE MUSEU', true);
insert into departments values ('SEAAD', 'COMUS', 'SERVIÇO DE APOIO DE ADMINISTRATIVO', true);
insert into departments values ('SEAGEC', 'COMUS', 'SERVIÇO DE ATENDIMENTO E GESTÃO DE ESPAÇOS CULTURAIS', true);
insert into departments values ('SECPM', 'COMUS', 'SERVIÇO DE CONSERVAÇÃO E PRESERVAÇÃO DO MUSEU', true);
insert into departments values ('SEECC', 'COMUS', 'SERVIÇO DE EXPOSIÇÕES, CURADORIA E COMUNICAÇÃO', true);
insert into departments values ('SEGAM', 'COMUS', 'SERVIÇO DE GESTÃO DE ACERVO MUSEOLÓGICO', true);
insert into departments values ('ESGID', 'SGIDOC', 'ESCRITÓRIO SETORIAL DE GESTÃO DA SGIDOC', true);
insert into departments values ('SINFRA', 'DGER', 'SECRETARIA DE INFRAESTRUTURA', true);
insert into departments values ('SEAU', 'SINFRA', 'SERVIÇO DE ATENDIMENTO AO USUÁRIO', true);
insert into departments values ('SEDACOPE', 'SINFRA', 'SERVIÇO DE DIRETRIZES ARQUITETÔNICAS PARA O PATRIMÔNIO EDIFICADO', true);
insert into departments values ('SEORC', 'SINFRA', 'SERVIÇO DE ORÇAMENTOS', true);
insert into departments values ('COEMANT', 'SINFRA', 'COORDENAÇÃO DE ENGENHARIA DE MANUTENÇÃO', true);
insert into departments values ('SEGEEN', 'COEMANT', 'SERVIÇO DE GESTÃO DE ENERGIA ELÉTRICA', true);
insert into departments values ('SEMAC', 'COEMANT', 'SERVIÇO DE MANUTENÇÃO CIVIL', true);
insert into departments values ('SEMAINST', 'COEMANT', 'SERVIÇO DE MANUTENÇÃO DE INSTALAÇÕES', true);
insert into departments values ('SEMEL', 'COEMANT', 'SERVIÇO DE MANUTENÇÃO ELETROMECÂNICA', true);
insert into departments values ('SEPLAG', 'COEMANT', 'SERVIÇO DE PLANEJAMENTO E GESTÃO', true);
insert into departments values ('COPRE', 'SINFRA', 'COORDENAÇÃO DE PROJETOS E REFORMAS', true);
insert into departments values ('SEFIS', 'COPRE', 'SERVIÇO DE FISCALIZAÇÃO', true);
insert into departments values ('SEPINF', 'COPRE', 'SERVIÇO DE PROJETOS DE INFRAESTRUTURA', true);
insert into departments values ('SEPROARQ', 'COPRE', 'SERVIÇO DE PROJETOS DE ARQUITETURA', true);
insert into departments values ('COPROJ', 'SINFRA', 'COORDENAÇÃO DE PROJETOS E OBRAS DE INFRAESTRUTURA', true);
insert into departments values ('EINFRA', 'SINFRA', 'ESCRITÓRIO SETORIAL DE GESTÃO DA SINFRA', true);
insert into departments values ('SPATR', 'DGER', 'SECRETARIA DE PATRIMÔNIO', true);
insert into departments values ('GBPATR', 'SPATR', 'GABINETE ADMINISTRATIVO DA SPATR', true);
insert into departments values ('SEAIM', 'SPATR', 'SERVIÇO DE DOCUMENTAÇÃO E ADMINISTRAÇÃO DE IMÓVEIS', true);
insert into departments values ('SECQEC', 'SPATR', 'SERVIÇO DE CONTROLE DE QUALIDADE E ESPECIFICAÇÕES DE MATERIAIS E BENS COMUNS', true);
insert into departments values ('SECQEE', 'SPATR', 'SERVIÇO DE CONTROLE DE QUALIDADE E ESPECIFICAÇÕES DE MATERIAIS E BENS ESPECIAIS', true);
insert into departments values ('COAPAT', 'SPATR', 'COORDENAÇÃO DE ADMINISTRAÇÃO PATRIMONIAL', true);
insert into departments values ('SEAPAT', 'COAPAT', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COAPAT', true);
insert into departments values ('SEINV', 'COAPAT', 'SERVIÇO DE INVENTÁRIOS', true);
insert into departments values ('SESIN', 'COAPAT', 'SERVIÇO DE SINALIZAÇÃO', true);
insert into departments values ('SETTP', 'COAPAT', 'SERVIÇO DE TOMBAMENTO E DE TRANSFERÊNCIAS PATRIMONIAIS', true);
insert into departments values ('COARO', 'SPATR', 'COORDENAÇÃO DE ADMINISTRAÇÃO DE RESIDÊNCIAS OFICIAIS', true);
insert into departments values ('SECMAN', 'COARO', 'SERVIÇO DE CONSERVAÇÃO E MANUTENÇÃO', true);
insert into departments values ('SEODIU', 'COARO', 'SERVIÇO DE APOIO OPERACIONAL DIURNO', true);
insert into departments values ('SEONOT', 'COARO', 'SERVIÇO DE APOIO OPERACIONAL NOTURNO', true);
insert into departments values ('COASAL', 'SPATR', 'COORDENAÇÃO DE ADMINISTRAÇÃO E SUPRIMENTO DE ALMOXARIFADOS', true);
insert into departments values ('SAINF', 'COASAL', 'SERVIÇO DE ALMOXARIFADO DE INFORMÁTICA', true);
insert into departments values ('SAPF', 'COASAL', 'SERVIÇO DE ALMOXARIFADO DE PRODUTOS GRÁFICOS', true);
insert into departments values ('SEALMX', 'COASAL', 'SERVIÇO DE ADMINISTRAÇÃO DE ALMOXARIFADOS', true);
insert into departments values ('SEASAL', 'COASAL', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COASAL', true);
insert into departments values ('SEPLSU', 'COASAL', 'SERVIÇO DE PLANEJAMENTO E SUPRIMENTO DE BENS DE ALMOXARIFADOS', true);
insert into departments values ('COGER', 'SPATR', 'COORDENAÇÃO DE SERVIÇOS GERAIS', true);
insert into departments values ('SEAOP', 'COGER', 'SERVIÇO DE ATENDIMENTO OPERACIONAL', true);
insert into departments values ('SECOLI', 'COGER', 'SERVIÇO DE CONSERVAÇÃO E LIMPEZA', true);
insert into departments values ('SEPOZE', 'COGER', 'SERVIÇO DE PORTARIA E ZELADORIA', true);
insert into departments values ('SETRAN', 'COGER', 'SERVIÇO DE TRANSPORTES', true);
insert into departments values ('COOTELE', 'SPATR', 'COORDENAÇÃO DE TELECOMUNICAÇÕES', true);
insert into departments values ('SEALMAT', 'COOTELE', 'SERVIÇO DE ALMOXARIFADO DE MATERIAL DE TELECOMUNICAÇÕES', true);
insert into departments values ('SECACD', 'COOTELE', 'SERVIÇO CENTRAL DE ATENDIMENTO E CONTROLE DE DADOS TÉCNICOS', true);
insert into departments values ('SECOMUT', 'COOTELE', 'SERVIÇO DE COMUTAÇÃO TELEFÔNICA', true);
insert into departments values ('SEQUALI', 'COOTELE', 'SERVIÇO DE APOIO ADMINISTRATIVO E CONTROLE DE QUALIDADE', true);
insert into departments values ('SERETE', 'COOTELE', 'SERVIÇO DE REDE TELEFÔNICA', true);
insert into departments values ('SETARIF', 'COOTELE', 'SERVIÇO DE TARIFAÇÃO', true);
insert into departments values ('SETEMO', 'COOTELE', 'SERVIÇO DE TELECOMUNICAÇÕES MÓVEIS', true);
insert into departments values ('SETIIN', 'COOTELE', 'SERVIÇO DE TECNOLOGIA DA INFORMAÇÃO', true);
insert into departments values ('EPATR', 'SPATR', 'ESCRITÓRIO SETORIAL DE GESTÃO DA SPATR', true);
insert into departments values ('SPOL', 'DGER', 'SECRETARIA DE POLÍCIA DO SENADO FEDERAL', true);
insert into departments values ('GBSPSF', 'SPOL', 'GABINETE ADMINISTRATIVO DA SPOL', true);
insert into departments values ('SECEAA', 'SPOL', 'SERVIÇO CENTRAL DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SECOP', 'SPOL', 'SERVIÇO DE CONTROLE OPERACIONAL', true);
insert into departments values ('SEINTE', 'SPOL', 'SERVIÇO DE INTELIGÊNCIA POLICIAL', true);
insert into departments values ('SEPOLI', 'SPOL', 'SERVIÇO DE POLICIAMENTO', true);
insert into departments values ('SEPREV', 'SPOL', 'SERVIÇO DE PREVENÇÃO DE ACIDENTES E SEGURANÇA DO TRABALHO', true);
insert into departments values ('COPINV', 'SPOL', 'COORDENAÇÃO DE POLÍCIA DE INVESTIGAÇÃO', true);
insert into departments values ('SECART', 'COPINV', 'SERVIÇO CARTORÁRIO', true);
insert into departments values ('SERINV', 'COPINV', 'SERVIÇO DE INVESTIGAÇÕES', true);
insert into departments values ('SESTEC', 'COPINV', 'SERVIÇO DE SUPORTE TÉCNICO', true);
insert into departments values ('COPROT', 'SPOL', 'COORDENAÇÃO DE PROTEÇÃO A AUTORIDADES', true);
insert into departments values ('SEAERE', 'COPROT', 'SERVIÇO DE APOIO AEROPORTUÁRIO', true);
insert into departments values ('SEPDIGN', 'COPROT', 'SERVIÇO DE PROTEÇÃO DE DIGNITÁRIOS', true);
insert into departments values ('SEPPLEC', 'COPROT', 'SERVIÇO DE PROTEÇÃO DE PLENÁRIOS E COMISSÕES', true);
insert into departments values ('SEPPRES', 'COPROT', 'SERVIÇO DE PROTEÇÃO PRESIDENCIAL', true);
insert into departments values ('COSUP', 'SPOL', 'COORDENAÇÃO DE SUPORTE ÀS ATIVIDADES POLICIAIS', true);
insert into departments values ('SECRED', 'COSUP', 'SERVIÇO DE CREDENCIAMENTO', true);
insert into departments values ('SELOG', 'COSUP', 'SERVIÇO DE LOGÍSTICA', true);
insert into departments values ('SESTIN', 'COSUP', 'SERVIÇO DE SUPORTE EM TECNOLOGIA DA INFORMAÇÃO', true);
insert into departments values ('SETRE', 'COSUP', 'SERVIÇO DE TREINAMENTO E PROJETOS', true);
insert into departments values ('ESPSF', 'SPOL', 'ESCRITÓRIO SETORIAL DE GESTÃO DA SPOL', true);
insert into departments values ('DIRECON', 'DGER', 'DIRETORIA-EXECUTIVA DE CONTRATAÇÕES', true);
insert into departments values ('SEINTP', 'DIRECON', 'SERVIÇO DE INSTRUÇÃO PROCESSUAL', true);
insert into departments values ('ASSETEC', 'DIRECON', 'ASSESSORIA TÉCNICA', true);
insert into departments values ('ESGEST', 'DIRECON', 'ESCRITÓRIO SETORIAL DE GESTÃO', true);
insert into departments values ('NGACTI', 'DIRECON', 'NÚCLEO DE GESTÃO E APOIO ÀS CONTRATAÇÕES DE TECNOLOGIA DA INFORMAÇÃO', true);
insert into departments values ('NGCIC', 'DIRECON', 'NÚCLEO DE GESTÃO DE CONTRATOS DE INFRAESTRUTURA E COMUNICAÇÃO', true);
insert into departments values ('NGCOT', 'DIRECON', 'NÚCLEO DE GESTÃO DE CONTRATOS DE TERCEIRIZAÇÃO', true);
insert into departments values ('SEAGCO', 'NGCOT', 'SERVIÇO DE APOIO ADMINISTRATIVO DA NGCOT', true);
insert into departments values ('DIREG', 'DGER', 'DIRETORIA-EXECUTIVA DE GESTÃO', true);
insert into departments values ('ATEC', 'DIREG', 'ASSESSORIA TÉCNICA', true);
insert into departments values ('ESEG', 'DIREG', 'ESCRITÓRIO SETORIAL DE GESTÃO', true);
insert into departments values ('NCAS', 'DIREG', 'NÚCLEO DE COORDENAÇÃO DE AÇÕES SOCIOAMBIENTAIS', true);
insert into departments values ('EGOV', 'DGER', 'ESCRITÓRIO CORPORATIVO DE GOVERNANÇA E GESTÃO ESTRATÉGICA', true);
insert into departments values ('SGM', 'OSE', 'SECRETARIA GERAL DA MESA', true);
insert into departments values ('GBSGME', 'SGM', 'GABINETE DA SECRETARIA GERAL DA MESA', true);
insert into departments values ('ATRSGM', 'SGM', 'ASSESSORIA TÉCNICA', true);
insert into departments values ('SAOP', 'SGM', 'SECRETARIA DE APOIO A ÓRGÃOS DO PARLAMENTO', true);
insert into departments values ('GBSAOP', 'SAOP', 'GABINETE ADMINISTRATIVO DA SAOP', true);
insert into departments values ('COAPOP', 'SAOP', 'COORDENAÇÃO DE APOIO A ÓRGÃOS DE PREMIAÇÕES', true);
insert into departments values ('SAPREMI', 'COAPOP', 'SERVIÇO DE APOIO A PREMIAÇÕES', true);
insert into departments values ('COAPOT', 'SAOP', 'COORDENAÇÃO DE APOIO A ÓRGÃOS TÉCNICOS', true);
insert into departments values ('SACCS', 'COAPOT', 'SERVIÇO DE APOIO AO CONSELHO DE COMUNICAÇÃO SOCIAL DO CONGRESSO NACIONAL', true);
insert into departments values ('SCOM', 'SGM', 'SECRETARIA DE COMISSÕES', true);
insert into departments values ('GBSCOM', 'SCOM', 'GABINETE ADMINISTRATIVO DA SECRETARIA DE COMISSÕES', true);
insert into departments values ('SEACOM', 'SCOM', 'SERVIÇO DE APOIO OPERACIONAL ÀS COMISSÕES', true);
insert into departments values ('COAPEC', 'SCOM', 'COORDENAÇÃO DE APOIO AO PROGRAMA E-CIDADANIA', true);
insert into departments values ('COCETI', 'SCOM', 'COORDENAÇÃO DE COMISSÕES ESPECIAIS, TEMPORÁRIAS E PARLAMENTARES DE INQUÉRITO', true);
insert into departments values ('COCM', 'SCOM', 'COORDENAÇÃO DE COMISSÕES MISTAS', true);
insert into departments values ('SACCAI', 'COCM', 'SECRETARIA DE APOIO À COMISSÃO MISTA DE CONTROLE DAS ATIVIDADES DE INTELIGÊNCIA', true);
insert into departments values ('SACMCF', 'COCM', 'SECRETARIA DE APOIO À COMISSÃO MISTA PERMANENTE DE REGULAMENTAÇÃO E CONSOLIDAÇÃO DA LEGISLAÇÃO FEDERAL', true);
insert into departments values ('SACMCPLP', 'COCM', 'SECRETARIA DE APOIO À COMISSÃO MISTA PERMANENTE DE ASSUNTOS', true);
insert into departments values ('SACMCVM', 'COCM', 'SECRETARIA DE APOIO À COMISSÃO MISTA PERMANENTE DE COMBATE À', true);
insert into departments values ('SACMMC', 'COCM', 'SECRETARIA DE APOIO À COMISSÃO MISTA PERMANENTE SOBRE MUDANÇAS', true);
insert into departments values ('COCPSF', 'SCOM', 'COORDENAÇÃO DE COMISSÕES PERMANENTES DO SENADO FEDERAL', true);
insert into departments values ('SACAE', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE ASSUNTOS ECONÔMICOS', true);
insert into departments values ('SACAS', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE ASSUNTOS SOCIAIS', true);
insert into departments values ('SACCJ', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE CONSTITUIÇÃO, JUSTIÇA E CIDADANIA', true);
insert into departments values ('SACCT', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE CIÊNCIA, TECNOLOGIA, INOVAÇÃO,', true);
insert into departments values ('SACDH', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE DIREITOS HUMANOS E LEGISLAÇÃO', true);
insert into departments values ('SACDIR', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DIRETORA', true);
insert into departments values ('SACDR', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE DESENVOLVIMENTO REGIONAL E TURISMO', true);
insert into departments values ('SACE', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE EDUCAÇÃO, CULTURA E ESPORTE', true);
insert into departments values ('SACIFR', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE SERVIÇOS DE INFRAESTRUTURA', true);
insert into departments values ('SACMA', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE MEIO AMBIENTE', true);
insert into departments values ('SACRA', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE AGRICULTURA E REFORMA AGRÁRIA', true);
insert into departments values ('SACRE', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE RELAÇÕES EXTERIORES E DEFESA NACIONAL', true);
insert into departments values ('SACTFC', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO DE TRANSPARÊNCIA, GOVERNANÇA,', true);
insert into departments values ('SAPCSF', 'COCPSF', 'SECRETARIA DE APOIO À COMISSÃO SENADO DO FUTURO', true);
insert into departments values ('SEADI', 'SGM', 'SECRETARIA DE ATAS E DIÁRIOS', true);
insert into departments values ('GBSEADI', 'SEADI', 'GABINETE ADMINISTRATIVO DA SEADI', true);
insert into departments values ('COELDI', 'SEADI', 'COORDENAÇÃO DE ELABORAÇÃO DE DIÁRIOS', true);
insert into departments values ('SEELAD', 'COELDI', 'SERVIÇO DE ELABORAÇÃO DE DIÁRIOS', true);
insert into departments values ('SERSAD', 'COELDI', 'SERVIÇO DE REVISÃO DE SUMÁRIOS, ATAS E DIÁRIOS', true);
insert into departments values ('SESUMA', 'COELDI', 'SERVIÇO DE ELABORAÇÃO DE SUMÁRIOS E ATAS', true);
insert into departments values ('CORTEL', 'SEADI', 'COORDENAÇÃO DE REGISTROS E TEXTOS LEGISLATIVOS DE PLENÁRIOS', true);
insert into departments values ('SEPTEX', 'CORTEL', 'SERVIÇO DE PROCESSAMENTO DE TEXTOS LEGISLATIVOS', true);
insert into departments values ('SERLEP', 'CORTEL', 'SERVIÇO DE REGISTROS LEGISLATIVOS DE PLENÁRIOS', true);
insert into departments values ('SERTEP', 'CORTEL', 'SERVIÇO DE REVISÃO DE REGISTROS E TEXTOS LEGISLATIVOS DE PLENÁRIOS', true);
insert into departments values ('SERERP', 'SGM', 'SECRETARIA DE REGISTRO E REDAÇÃO PARLAMENTAR', true);
insert into departments values ('GBSERERP', 'SERERP', 'GABINETE ADMINISTRATIVO DA SERERP', true);
insert into departments values ('SEOPE', 'SERERP', 'SERVIÇO DE APOIO OPERACIONAL', true);
insert into departments values ('SETAUD', 'SERERP', 'SERVIÇO DE TÉCNICA DE ÁUDIO', true);
insert into departments values ('CORCOM', 'SERERP', 'COORDENAÇÃO DE REGISTRO EM COMISSÕES', true);
insert into departments values ('SEACO', 'CORCOM', 'SERVIÇO DE APOIO ÀS ATIVIDADES EM COMISSÕES', true);
insert into departments values ('SERCOMIS', 'CORCOM', 'SERVIÇO DE REGISTRO EM COMISSÕES', true);
insert into departments values ('SESUCOM', 'CORCOM', 'SERVIÇO DE SUPERVISÃO DO REGISTRO EM COMISSÕES', true);
insert into departments values ('COREM', 'SERERP', 'COORDENAÇÃO DE REDAÇÃO E MONTAGEM', true);
insert into departments values ('SEREDA', 'COREM', 'SERVIÇO DE REDAÇÃO', true);
insert into departments values ('SERMON', 'COREM', 'SERVIÇO DE MONTAGEM', true);
insert into departments values ('CORER', 'SERERP', 'COORDENAÇÃO DE REVISÃO DE REGISTRO', true);
insert into departments values ('SERER', 'CORER', 'SERVIÇO DE REVISÃO DE REGISTRO', true);
insert into departments values ('CORPLEN', 'SERERP', 'COORDENAÇÃO DE REGISTRO EM PLENÁRIO', true);
insert into departments values ('SERPLEN', 'CORPLEN', 'SERVIÇO DE REGISTRO EM PLENÁRIO', true);
insert into departments values ('SEXPE', 'SGM', 'SECRETARIA DE EXPEDIENTE', true);
insert into departments values ('GBSEXP', 'SEXPE', 'GABINETE ADMINISTRATIVO DA SEXPE', true);
insert into departments values ('COEMAT', 'SEXPE', 'COORDENAÇÃO DE EXPEDIÇÃO E ACOMPANHAMENTO DE MATÉRIAS LEGISLATIVAS', true);
insert into departments values ('SEAMAT', 'COEMAT', 'SERVIÇO DE ACOMPANHAMENTO DE MATÉRIAS LEGISLATIVAS', true);
insert into departments values ('SEEXPED', 'COEMAT', 'SERVIÇO DE EXPEDIÇÃO', true);
insert into departments values ('COEXPO', 'SEXPE', 'COORDENAÇÃO DE ELABORAÇÃO DE EXPEDIENTES OFICIAIS', true);
insert into departments values ('SEDOCE', 'COEXPO', 'SERVIÇO DE DOCUMENTAÇÃO ELETRÔNICA', true);
insert into departments values ('SEINPL', 'COEXPO', 'SERVIÇO DE INSPEÇÃO DOS PROCESSADOS LEGISLATIVOS', true);
insert into departments values ('SINFLEG', 'SGM', 'SECRETARIA DE INFORMAÇÃO LEGISLATIVA', true);
insert into departments values ('SEAIL', 'SINFLEG', 'SERVIÇO DE APOIO ADMINISTRATIVO', true);
insert into departments values ('COER', 'SINFLEG', 'COORDENAÇÃO DE ESTATÍSTICAS, PESQUISA E RELATÓRIOS LEGISLATIVOS', true);
insert into departments values ('SEPEL', 'COER', 'SERVIÇO DE PESQUISA LEGISLATIVA', true);
insert into departments values ('SERAP', 'COER', 'SERVIÇO DO RELATÓRIO DA PRESIDÊNCIA', true);
insert into departments values ('SEREL', 'COER', 'SERVIÇO DE RELATÓRIOS MENSAIS E ESTATÍSTICAS LEGISLATIVAS', true);
insert into departments values ('COPIL', 'SINFLEG', 'COORDENAÇÃO DE PADRONIZAÇÃO DA INFORMAÇÃO LEGISLATIVA', true);
insert into departments values ('SEDAN', 'COPIL', 'SERVIÇO DE ANAIS', true);
insert into departments values ('SEPRON', 'COPIL', 'SERVIÇO DE TRATAMENTO DE PRONUNCIAMENTOS', true);
insert into departments values ('SESINO', 'COPIL', 'SERVIÇO DE SINOPSE', true);
insert into departments values ('NMIL', 'SINFLEG', 'NÚCLEO DE MODERNIZAÇÃO DA INFORMAÇÃO LEGISLATIVA', true);
insert into departments values ('SEGEPROL', 'NMIL', 'SERVIÇO DE GESTÃO DE PROCESSOS LEGISLATIVOS', true);
insert into departments values ('SEMOP', 'NMIL', 'SERVIÇO DE MODERNIZAÇÃO E PROJETOS', true);
insert into departments values ('SLCN', 'SGM', 'SECRETARIA LEGISLATIVA DO CONGRESSO NACIONAL', true);
insert into departments values ('GBADM', 'SLCN', 'GABINETE ADMINISTRATIVO', true);
insert into departments values ('COLECN', 'SLCN', 'COORDENAÇÃO DAS MATÉRIAS LEGISLATIVAS DO CONGRESSO NACIONAL', true);
insert into departments values ('SECOLEG', 'COLECN', 'SERVIÇO DE COLEGIADOS', true);
insert into departments values ('SEMORC', 'COLECN', 'SERVIÇO DE MATÉRIAS ORÇAMENTÁRIAS', true);
insert into departments values ('CORDIACN', 'SLCN', 'COORDENAÇÃO DA ORDEM DO DIA DO CONGRESSO NACIONAL', true);
insert into departments values ('SEMEPRO', 'CORDIACN', 'SERVIÇO DE MEDIDAS PROVISÓRIAS', true);
insert into departments values ('SEVETOS', 'CORDIACN', 'SERVIÇO DE VETOS', true);
insert into departments values ('SLSF', 'SGM', 'SECRETARIA LEGISLATIVA DO SENADO FEDERAL', true);
insert into departments values ('GBLSF', 'SLSF', 'GABINETE ADMINISTRATIVO', true);
insert into departments values ('COINTEL', 'SLSF', 'COORDENAÇÃO DE INTELIGÊNCIA LEGISLATIVA', true);
insert into departments values ('SEAPIL', 'COINTEL', 'SERVIÇO DE ANÁLISE E PRODUÇÃO DE INFORMAÇÕES LEGISLATIVAS', true);
insert into departments values ('COMIL', 'SLSF', 'COORDENAÇÃO DE MATÉRIAS E INSTRUÇÃO LEGISLATIVA', true);
insert into departments values ('SEINLEG', 'COMIL', 'SERVIÇO DE INSTRUÇÃO LEGISLATIVA', true);
insert into departments values ('SEPME', 'COMIL', 'SERVIÇO DE PREPARAÇÃO DE MATÉRIAS E EXPEDIENTES', true);
insert into departments values ('COORD', 'SLSF', 'COORDENAÇÃO DA ORDEM DO DIA', true);
insert into departments values ('SEAPLER', 'COORD', 'SERVIÇO DE ACOMPANHAMENTO DE PLENÁRIO E REVISÃO', true);
insert into departments values ('SEPORD', 'COORD', 'SERVIÇO DE PREPARAÇÃO DA ORDEM DO DIA', true);
insert into departments values ('COALSGM', 'SGM', 'COORDENAÇÃO DE APOIO LOGÍSTICO', true);
insert into departments values ('SEAPA', 'COALSGM', 'SERVIÇO DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SEAPLEN', 'COALSGM', 'SERVIÇO DE APOIO AO PLENÁRIO', true);
insert into departments values ('COAME', 'SGM', 'COORDENAÇÃO DE APOIO À MESA', true);
insert into departments values ('CORELE', 'SGM', 'COORDENAÇÃO DE REDAÇÃO LEGISLATIVA', true);
insert into departments values ('COVESP', 'SGM', 'COORDENAÇÃO DOS SISTEMAS DE VOTAÇÕES ELETRÔNICAS E DE SONORIZAÇÃO DE PLENÁRIOS', true);
insert into departments values ('SEAP', 'COVESP', 'SERVIÇO DE OPERAÇÃO DE ÁUDIO DE PLENÁRIOS', true);
insert into departments values ('SEMAAP', 'COVESP', 'SERVIÇO DE MANUTENÇÃO E ATENDIMENTO AUDIOVISUAL DE PLENÁRIOS', true);
insert into departments values ('SESVE', 'COVESP', 'SERVIÇO DE OPERAÇÃO DO SISTEMA DE VOTAÇÕES ELETRÔNICAS', true);
insert into departments values ('ESGM', 'SGM', 'ESCRITÓRIO SETORIAL DE GESTÃO DA SGM', true);
insert into departments values ('OAS', 'SF', 'ÓRGÃOS DE ASSESSORAMENTO SUPERIOR', true);
insert into departments values ('CONLEG', 'OAS', 'CONSULTORIA LEGISLATIVA', true);
insert into departments values ('GBCLEG', 'CONLEG', 'GABINETE ADMINISTRATIVO DA CONLEG', true);
insert into departments values ('CONTEC', 'CONLEG', 'CONSELHO TÉCNICO DA CONLEG', true);
insert into departments values ('ECOLEG', 'CONLEG', 'ESCRITÓRIO SETORIAL DE GESTÃO DA CONLEG', true);
insert into departments values ('NALEG', 'CONLEG', 'NÚCLEO DE ACOMPANHAMENTO LEGISLATIVO', true);
insert into departments values ('NDIR', 'CONLEG', 'NÚCLEO DE DIREITO', true);
insert into departments values ('NDISC', 'CONLEG', 'NÚCLEO DE DISCURSOS', true);
insert into departments values ('NECO', 'CONLEG', 'NÚCLEO DE ECONOMIA', true);
insert into departments values ('NEPLEG', 'CONLEG', 'NÚCLEO DE ESTUDOS E PESQUISAS DA CONSULTORIA LEGISLATIVA', true);
insert into departments values ('NSOC', 'CONLEG', 'NÚCLEO SOCIAL', true);
insert into departments values ('NSTLEG', 'CONLEG', 'NÚCLEO DE SUPORTE TÉCNICO-LEGISLATIVO', true);
insert into departments values ('SEAPG', 'NSTLEG', 'SERVIÇO DE APOIO GERENCIAL', true);
insert into departments values ('SEATCN', 'NSTLEG', 'SERVIÇO DE APOIO TÉCNICO DA CONLEG', true);
insert into departments values ('CONORF', 'OAS', 'CONSULTORIA DE ORÇAMENTOS, FISCALIZAÇÃO E CONTROLE', true);
insert into departments values ('GBCORF', 'CONORF', 'GABINETE ADMINISTRATIVO DA CONORF', true);
insert into departments values ('ECONOR', 'CONORF', 'ESCRITÓRIO SETORIAL DE GESTÃO DA CONORF', true);
insert into departments values ('NGIOS', 'CONORF', 'NÚCLEO DE SUPORTE TÉCNICO, GESTÃO DA INFORMAÇÃO ORÇAMENTÁRIA E SIGA-BRASIL', true);
insert into departments values ('SEEORÇ', 'NGIOS', 'SERVIÇO DE PESQUISA E ACOMPANHAMENTO DA EXECUÇÃO ORÇAMENTÁRIA', true);
insert into departments values ('SEPROR', 'NGIOS', 'SERVIÇO DE APOIO AO PROCESSO ORÇAMENTÁRIO', true);
insert into departments values ('SESORÇ', 'NGIOS', 'SERVIÇO DE GESTÃO DOS SISTEMAS ORÇAMENTÁRIOS', true);
insert into departments values ('NUCI', 'CONORF', 'NÚCLEO DE EDUCAÇÃO, CULTURA, CIÊNCIA, TECNOLOGIA, INTEGRAÇÃO NACIONAL E MEIO AMBIENTE', true);
insert into departments values ('NUCII', 'CONORF', 'NÚCLEO DE INFRA-ESTRUTURA, PLANEJAMENTO E DESENVOLVIMENTO URBANO', true);
insert into departments values ('NUCIII', 'CONORF', 'NÚCLEO DE FAZENDA E DESENVOLVIMENTO, AGRICULTURA E DESENVOLVIMENTO AGRÁRIO', true);
insert into departments values ('NUCIV', 'CONORF', 'NÚCLEO DE JUSTIÇA E DEFESA, PREVIDÊNCIA E ASSISTÊNCIA SOCIAL', true);
insert into departments values ('NUCV', 'CONORF', 'NÚCLEO DE PODERES DO ESTADO E REPRESENTAÇÃO E SAÚDE', true);
insert into departments values ('ADVOSF', 'OAS', 'ADVOCACIA DO SENADO FEDERAL', true);
insert into departments values ('NASSET', 'ADVOSF', 'NÚCLEO DE ASSESSORAMENTO E ESTUDOS TéCNICOS', true);
insert into departments values ('NATA', 'ADVOSF', 'NÚCLEO DE APOIO TÉCNICO ADMINISTRATIVO', true);
insert into departments values ('SEADV', 'NATA', 'SERVIÇO DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SEEPESQ', 'NATA', 'SERVIÇO DE EXECUÇÃO E PESQUISA', true);
insert into departments values ('EADVOS', 'NATA', 'ESCRITÓRIO SETORIAL DE GESTÃO DA ADVOSF', true);
insert into departments values ('NPADM', 'ADVOSF', 'NÚCLEO DE PROCESSOS ADMINISTRATIVOS', true);
insert into departments values ('NPCONT', 'ADVOSF', 'NÚCLEO DE PROCESSOS DE CONTRATAÇÕES', true);
insert into departments values ('NPJUD', 'ADVOSF', 'NÚCLEO DE PROCESSOS JUDICIAIS', true);
insert into departments values ('AUDIT', 'OAS', 'AUDITORIA DO SENADO FEDERAL', true);
insert into departments values ('GBAUDIT', 'AUDIT', 'GABINETE ADMINISTRATIVO DA AUDIT', true);
insert into departments values ('COAUDCF', 'AUDIT', 'COORDENAÇÃO DE AUDITORIA CONTÁBIL E FINANCEIRA', true);
insert into departments values ('SEAUDCO', 'COAUDCF', 'SERVIÇO DE AUDITORIA CONTÁBIL', true);
insert into departments values ('SEAUDCT', 'COAUDCF', 'SERVIÇO DE AUDITORIA DE CONTAS', true);
insert into departments values ('COAUDCON', 'AUDIT', 'COORDENAÇÃO DE AUDITORIA DE CONTRATAÇÕES', true);
insert into departments values ('SEAUDCOT', 'COAUDCON', 'SERVIÇO DE AUDITORIA DE CONFORMIDADE DE CONTRATAÇÕES', true);
insert into departments values ('SEAUDOPE', 'COAUDCON', 'SERVIÇO DE AUDITORIA OPERACIONAL DE CONTRATAÇÕES', true);
insert into departments values ('COAUDGEP', 'AUDIT', 'COORDENAÇÃO DE AUDITORIA DE GESTÃO DE PESSOAS', true);
insert into departments values ('SEAUDAC', 'COAUDGEP', 'SERVIÇO DE AUDITORIA DE ADMISSÕES E CONCESSÕES', true);
insert into departments values ('SEAUDGEP', 'COAUDGEP', 'SERVIÇO DE AUDITORIA DE GESTÃO DE PESSOAS', true);
insert into departments values ('COAUDTI', 'AUDIT', 'COORDENAÇÃO DE AUDITORIA DE TECNOLOGIA DA INFORMAÇÃO', true);
insert into departments values ('SEAUDGTI', 'COAUDTI', 'SERVIÇO DE AUDITORIA DE GESTÃO DE TECNOLOGIA DA INFORMAÇÃO', true);
insert into departments values ('SEAUDOTI', 'COAUDTI', 'SERVIÇO DE AUDITORIA DE OPERAÇÕES DE TECNOLOGIA DA INFORMAÇÃO', true);
insert into departments values ('ESAUDIT', 'AUDIT', 'ESCRITÓRIO SETORIAL DE GESTÃO DA AUDIT', true);
insert into departments values ('SECOM', 'OAS', 'SECRETARIA DE COMUNICAÇÃO SOCIAL', true);
insert into departments values ('GBECOM', 'SECOM', 'GABINETE ADMINISTRATIVO DA SECOM', true);
insert into departments values ('SEADCO', 'GBECOM', 'SERVIÇO DE APOIO ADMINISTRATIVO DA SECOM', true);
insert into departments values ('ASIMPRE', 'SECOM', 'ASSESSORIA DE IMPRENSA (SECOM)', true);
insert into departments values ('ATCOM', 'SECOM', 'ASSESSORIA TÉCNICA', true);
insert into departments values ('SAJS', 'SECOM', 'SECRETARIA AGÊNCIA E JORNAL DO SENADO', true);
insert into departments values ('SEAAJS', 'SAJS', 'SERVIÇO DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SEARJS', 'SAJS', 'SERVIÇO DE ARTE', true);
insert into departments values ('COBERT', 'SAJS', 'COORDENAÇÃO DE COBERTURA', true);
insert into departments values ('SEAUDIO', 'COBERT', 'SERVIÇO DE AUDIOVISUAL', true);
insert into departments values ('SEFOTO', 'COBERT', 'SERVIÇO DE FOTOGRAFIA', true);
insert into departments values ('SEREPT', 'COBERT', 'SERVIÇO DE REPORTAGEM', true);
insert into departments values ('COEDAJS', 'SAJS', 'COORDENAÇÃO DE EDIÇÃO', true);
insert into departments values ('SEIMPRE', 'COEDAJS', 'SERVIÇO DE IMPRESSOS', true);
insert into departments values ('SEPN', 'COEDAJS', 'SERVIÇO DE PORTAL DE NOTÍCIAS', true);
insert into departments values ('SERCOQ', 'COEDAJS', 'SERVIÇO DE REVISÃO E CONTROLE DE QUALIDADE', true);
insert into departments values ('COJORN', 'SAJS', 'COORDENAÇÃO JORNAL DO SENADO', true);
insert into departments values ('SEC', 'SECOM', 'SECRETARIA DE ENGENHARIA DE COMUNICAÇÃO', true);
insert into departments values ('SAENGC', 'SEC', 'SERVIÇO DE APOIO ADMINISTRATIVO (SEC)', true);
insert into departments values ('CODM', 'SEC', 'COORDENAÇÃO DE DOCUMENTAÇÃO MULTIMÍDIA', true);
insert into departments values ('SEDICO', 'CODM', 'SERVIÇO DE DIFUSÃO DE CONTEÚDO', true);
insert into departments values ('SEIMUL', 'CODM', 'SERVIÇO DE INFRAESTRUTURA E MANUTENÇÃO MULTIMíDIA', true);
insert into departments values ('SESDIG', 'CODM', 'SERVIÇO DE DESENVOLVIMENTO E INTEGRAÇÃO DE SISTEMAS DIGITAIS', true);
insert into departments values ('SETDIG', 'CODM', 'SERVIÇO DE SUPORTE TéCNICO E DIGITALIZAÇÃO', true);
insert into departments values ('COENGTVR', 'SEC', 'COORDENAÇÃO DE ENGENHARIA DE TV E RÁDIO', true);
insert into departments values ('SECONTE', 'COENGTVR', 'SERVIÇO DE CONTROLE DE EQUIPAMENTOS', true);
insert into departments values ('SETETV', 'COENGTVR', 'SERVIÇO TÉCNICO DE TV', true);
insert into departments values ('SETRAD', 'COENGTVR', 'SERVIÇO TÉCNICO DA RÁDIO', true);
insert into departments values ('CORTV', 'SEC', 'COORDENAÇÃO DE TRANSMISSÃO DE TV E RÁDIO', true);
insert into departments values ('SEAMEL', 'CORTV', 'SERVIÇO DE ALMOXARIFADO DE MATERIAL ELETRÔNICO', true);
insert into departments values ('SEATEL', 'CORTV', 'SERVIÇO DE ATENDIMENTO ELETRÔNICO', true);
insert into departments values ('SEMATV', 'CORTV', 'SERVIÇO DE MANUTENÇÃO DA REDE DE TV E RÁDIO', true);
insert into departments values ('SETRAR', 'CORTV', 'SERVIÇO DE TRANSMISSÃO DE RÁDIO', true);
insert into departments values ('SETTV', 'CORTV', 'SERVIÇO DE TRANSMISSÃO DE TV', true);
insert into departments values ('COTI', 'SEC', 'COORDENAÇÃO DE TECNOLOGIA DA INFORMAÇÃO', true);
insert into departments values ('SRPPM', 'SECOM', 'SECRETARIA DE RELAÇÕES PÚBLICAS, PUBLICIDADE E MARKETING', true);
insert into departments values ('SARPSF', 'SRPPM', 'SERVIÇO DE APOIO ADMINISTRATIVO (SRPPM)', true);
insert into departments values ('COGENV', 'SRPPM', 'COORDENAÇÃO DE GESTÃO DE EVENTOS', true);
insert into departments values ('SELEG', 'COGENV', 'SERVIÇO DE EVENTOS LEGISLATIVOS E PROTOCOLARES', true);
insert into departments values ('SEVAD', 'COGENV', 'SERVIÇO DE EVENTOS ADMINISTRATIVOS', true);
insert into departments values ('COMAP', 'SRPPM', 'COORDENAÇÃO DE PUBLICIDADE E MARKETING', true);
insert into departments values ('SEMARK', 'COMAP', 'SERVIÇO DE MARKETING', true);
insert into departments values ('SEPUP', 'COMAP', 'SERVIÇO DE PUBLICIDADE E PROPAGANDA', true);
insert into departments values ('COVISITA', 'SRPPM', 'COORDENAÇÃO DE VISITAÇÃO INSTITUCIONAL E DE RELACIONAMENTO COM A COMUNIDADE', true);
insert into departments values ('SECOI', 'COVISITA', 'SERVIÇO DE COOPERAÇÃO INSTITUCIONAL', true);
insert into departments values ('SEVISI', 'COVISITA', 'SERVIÇO DE VISITA INSTITUCIONAL', true);
insert into departments values ('SRSF', 'SECOM', 'SECRETARIA RÁDIO SENADO', true);
insert into departments values ('SARSF', 'SRSF', 'SERVIÇO DE APOIO ADMINISTRATIVO', true);
insert into departments values ('SEMADI', 'SRSF', 'SERVIÇO DE PROGRAMAÇÃO E DIVULGAÇÃO', true);
insert into departments values ('SERAG', 'SRSF', 'SERVIÇO RÁDIO AGÊNCIA', true);
insert into departments values ('CORED', 'SRSF', 'COORDENAÇÃO DE REDAÇÃO', true);
insert into departments values ('SEPORE', 'CORED', 'SERVIÇO DE PROGRAMAÇÃO REGIONAL', true);
insert into departments values ('SEPROD', 'CORED', 'SERVIÇO DE PRODUÇÃO', true);
insert into departments values ('SEREPO', 'CORED', 'SERVIÇO DE REPORTAGEM', true);
insert into departments values ('SERLOC', 'CORED', 'SERVIÇO DE LOCUÇÃO', true);
insert into departments values ('SEVOZ', 'CORED', 'SERVIÇO DE EDIÇÃO DA VOZ DO BRASIL', true);
insert into departments values ('STVSEN', 'SECOM', 'SECRETARIA TV SENADO', true);
insert into departments values ('COADTV', 'STVSEN', 'COORDENAÇÃO ADMINISTRATIVA', true);
insert into departments values ('SEACER', 'COADTV', 'SERVIÇO DE ACERVO', true);
insert into departments values ('SEOPER', 'COADTV', 'SERVIÇO DE OPERAÇÃO', true);
insert into departments values ('CONTV', 'STVSEN', 'COORDENAÇÃO DE CONTEÚDO', true);
insert into departments values ('SEDCT', 'CONTV', 'SERVIÇO DE DOCUMENTÁRIOS', true);
insert into departments values ('SEPJOR', 'CONTV', 'SERVIÇO DE PROGRAMAS JORNALÍSTICOS', true);
insert into departments values ('SEPRES', 'CONTV', 'SERVIÇO DE PROJETOS ESPECIAIS', true);
insert into departments values ('SERTV', 'CONTV', 'SERVIÇO DE REPORTAGEM DA SECRETARIA TV SENADO', true);
insert into departments values ('COPRTV', 'STVSEN', 'COORDENAÇÃO DE PROGRAMAÇÃO', true);
insert into departments values ('SEINT', 'COPRTV', 'SERVIÇO DE INTERNET', true);
insert into departments values ('SEITPG', 'COPRTV', 'SERVIÇO DE INTERPROGRAMAS', true);
insert into departments values ('SERMPR', 'COPRTV', 'SERVIÇO DE MULTIPROGRAMAÇÃO', true);
insert into departments values ('SEVIIN', 'COPRTV', 'SERVIÇO DE VIVO E ÍNTEGRAS', true);
insert into departments values ('DJORN', 'SECOM', 'DIRETORIA DE JORNALISMO', true);
insert into departments values ('NINTRA', 'DJORN', 'NÚCLEO DE INTRANET', true);
insert into departments values ('NMIDIAS', 'DJORN', 'NÚCLEO DE MÍDIAS SOCIAIS', true);
insert into departments values ('NPAUTAS', 'DJORN', 'NÚCLEO DE PAUTAS INTEGRADAS', true);
insert into departments values ('NCONT', 'SECOM', 'NÚCLEO DE CONTRATAÇÕES E CONTRATOS', true);
insert into departments values ('ESECOM', 'NCONT', 'ESCRITÓRIO SETORIAL DE GESTÃO (SECOM)', true);
insert into departments values ('OSU', 'SF', 'ÓRGÃOS SUPERVISIONADOS', true);
insert into departments values ('ILB', 'OSU', 'INSTITUTO LEGISLATIVO BRASILEIRO', true);
insert into departments values ('DEXILB', 'ILB', 'DIRETORIA EXECUTIVA DO ILB', true);
insert into departments values ('GBILB', 'DEXILB', 'GABINETE ADMINISTRATIVO DA DEXILB', true);
insert into departments values ('SEAT', 'DEXILB', 'SERVIÇO DE APOIO TÉCNICO', true);
insert into departments values ('COADFI', 'DEXILB', 'COORDENAÇÃO ADMINISTRATIVA E FINANCEIRA', true);
insert into departments values ('SCCO', 'COADFI', 'SERVIÇO DE CONTRATOS E CONVÊNIOS', true);
insert into departments values ('SEACOA', 'COADFI', 'SERVIÇO DE APOIO ADMINISTRATIVO DA COADFI', true);
insert into departments values ('SEPLAF', 'COADFI', 'SERVIÇO DE PLANEJAMENTO E ACOMPANHAMENTO FINANCEIRO', true);
insert into departments values ('COESUP', 'DEXILB', 'COORDENAÇÃO DE EDUCAÇÃO SUPERIOR', true);
insert into departments values ('SEFOPEE', 'COESUP', 'SERVIÇO DE FOMENTO À PESQUISA E EXTENSÃO', true);
insert into departments values ('SEPOS', 'COESUP', 'SERVIÇO DOS CURSOS DE PÓS-GRADUAÇÃO', true);
insert into departments values ('SESEA', 'COESUP', 'SERVIÇO DE SECRETARIADO ACADÊMICO', true);
insert into departments values ('COPERI', 'DEXILB', 'COORDENAÇÃO DE PLANEJAMENTO E RELAÇÕES INSTITUCIONAIS', true);
insert into departments values ('SACL', 'COPERI', 'SERVIÇO DE ATENDIMENTO À COMUNIDADE DO LEGISLATIVO', true);
insert into departments values ('SFCO', 'COPERI', 'SERVIÇO DE FORMAÇÃO DA COMUNIDADE', true);
insert into departments values ('SIDV', 'COPERI', 'SERVIÇO DE INFORMAÇÃO E DIVULGAÇÃO', true);
insert into departments values ('SPAC', 'COPERI', 'SERVIÇO DE PLANEJAMENTO E ACOMPANHAMENTO DA COMUNIDADE', true);
insert into departments values ('SPPE', 'COPERI', 'SERVIÇO DE PLANEJAMENTO E PROJETOS ESPECIAIS', true);
insert into departments values ('COTIN', 'DEXILB', 'COORDENAÇÃO DE TECNOLOGIA DA INFORMAÇÃO', true);
insert into departments values ('SEIT', 'COTIN', 'SERVIÇO DE INFRAESTRUTURA TECNOLÓGICA', true);
insert into departments values ('SPDT', 'COTIN', 'SERVIÇO DE PESQUISA E DESENVOLVIMENTO TECNOLÓGICO', true);
insert into departments values ('COTREN', 'DEXILB', 'COORDENAÇÃO DE CAPACITAÇÃO, TREINAMENTO E ENSINO', true);
insert into departments values ('SEED', 'COTREN', 'SERVIÇO DE ENSINO À DISTÂNCIA', true);
insert into departments values ('SETREINA', 'COTREN', 'SERVIÇO DE TREINAMENTO', true);
insert into departments values ('EILB', 'DEXILB', 'ESCRITÓRIO SETORIAL DE GESTÃO DO ILB', true);
insert into departments values ('COCIPE', 'ILB', 'COMITÊ CIENTÍFICO-PEDAGÓGICO', true);
insert into departments values ('COMPER', 'SF', 'COMISSÕES PARLAMENTARES PERMANENTES', true);
insert into departments values ('CAE', 'COMPER', 'COMISSÃO DE ASSUNTOS ECONÔMICOS', true);
insert into departments values ('CAS', 'COMPER', 'COMISSÃO DE ASSUNTOS SOCIAIS', true);
insert into departments values ('CCJ', 'COMPER', 'COMISSÃO DE CONSTITUIÇÃO, JUSTIÇA E CIDADANIA', true);
insert into departments values ('CCT', 'COMPER', 'COMISSÃO DE CIÊNCIA, TECNOLOGIA, INOVAÇÃO, COMUNICAÇÃO E INFORMÁTICA', true);
insert into departments values ('CDH', 'COMPER', 'COMISSÃO DE DIREITOS HUMANOS E LEGISLAÇÃO PARTICIPATIVA', true);
insert into departments values ('CDR', 'COMPER', 'COMISSÃO DE DESENVOLVIMENTO REGIONAL E TURISMO', true);
insert into departments values ('CE', 'COMPER', 'COMISSÃO DE EDUCAÇÃO, CULTURA E ESPORTE', true);
insert into departments values ('CI', 'COMPER', 'COMISSÃO DE SERVIÇOS DE INFRAESTRUTURA', true);
insert into departments values ('CMA', 'COMPER', 'COMISSÃO DE MEIO AMBIENTE', true);
insert into departments values ('CRA', 'COMPER', 'COMISSÃO DE AGRICULTURA E REFORMA AGRÁRIA', true);
insert into departments values ('CRE', 'COMPER', 'COMISSÃO DE RELAÇÕES EXTERIORES', true);
insert into departments values ('CTFC', 'COMPER', 'COMISSÃO DE TRANSPARÊNCIA, GOVERNANÇA, FISCALIZAÇÃO E CONTROLE E DEFESA DO CONSUMIDOR', true);
insert into departments values ('PROPAR', 'SF', 'PROCURADORIA PARLAMENTAR', true);
insert into departments values ('CORREG', 'SF', 'CORREGEDORIA PARLAMENTAR', true);
insert into departments values ('CEDP', 'SF', 'CONSELHO DE ÉTICA E DECORO PARLAMENTAR', true);
insert into departments values ('CCINCL', 'SF', 'CONSELHO DA COMENDA DE INCENTIVO À CULTURA LUÍS DA CÂMARA CASCUDO', true);
insert into departments values ('CCOMESP', 'SF', 'CONSELHO DA COMENDA DO MÉRITO ESPORTIVO', true);
insert into departments values ('CCOMFACF', 'SF', 'CONSELHO DA COMENDA DO MÉRITO FUTEBOLÍSTICO ASSOCIAÇÃO CHAPECOENSE DE FUTEBOL', true);
insert into departments values ('CCOMZA', 'SF', 'CONSELHO DA COMENDA ZILDA ARNS', true);
insert into departments values ('CCONIMS', 'SF', 'CONSELHO DA COMENDA NISE MAGALHÃES DA SILVEIRA', true);
insert into departments values ('CDBL', 'SF', 'CONSELHO DO DIPLOMA BERTHA LUTZ', true);
insert into departments values ('CDGN', 'SF', 'CONSELHO DA COMENDA DORINA DE GOUVÊA NOWILL', true);
insert into departments values ('CDHC', 'SF', 'CONSELHO DA COMENDA DE DIREITOS HUMANOS DOM HÉLDER CÂMARA', true);
insert into departments values ('CEPSF', 'SF', 'CONSELHO DE ESTUDOS POLÍTICOS DO SENADO FEDERAL', true);
insert into departments values ('CPREJE', 'SF', 'CONSELHO DO PRÊMIO JOVEM EMPREENDEDOR', true);
insert into departments values ('CSAN', 'SF', 'CONSELHO DA COMENDA SENADOR ABDIAS NASCIMENTO', true);
insert into departments values ('DJEM', 'SF', 'CONSELHO DO DIPLOMA JOSÉ ERMÍRIO DE MORAES', true);
insert into departments values ('IFI', 'SF', 'INSTITUIÇÃO FISCAL INDEPENDENTE', true);
insert into departments values ('OUVIDSF', 'SF', 'OUVIDORIA DO SENADO FEDERAL', true);
insert into departments values ('CORCID', 'OUVIDSF', 'COORDENAÇÃO DE RELACIONAMENTO COM O CIDADÃO', true);
insert into departments values ('SEALOS', 'CORCID', 'SERVIÇO DE RELACIONAMENTO PÚBLICO ALÔ SENADO', true);
insert into departments values ('SEAPCO', 'CORCID', 'SERVIÇO DE APOIO ADMINISTRATIVO DA CORCID', true);
insert into departments values ('PJRM', 'SF', 'CONSELHO DO PRÊMIO JORNALISTA ROBERTO MARINHO DE MÉRITO JORNALÍSTICO', true);
insert into departments values ('PJS', 'SF', 'CONSELHO DO PROJETO JOVEM SENADOR', true);
insert into departments values ('PMA', 'SF', 'CONSELHO DO PRÊMIO MÉRITO AMBIENTAL', true);
insert into departments values ('PROMUL', 'SF', 'PROCURADORIA ESPECIAL DA MULHER', true);
insert into departments values ('PSFHB', 'SF', 'CONSELHO DO PRÊMIO SENADO FEDERAL DE HISTÓRIA DO BRASIL', true);
insert into departments values ('RPBMER', 'SF', 'REPRESENTAÇÃO BRASILEIRA NO PARLAMENTO DO MERCOSUL', true);
insert into departments values ('CCS', 'SF', 'CONSELHO DE COMUNICAÇÃO SOCIAL', true);
insert into departments values ('COCN', 'SF', 'CONSELHO DA ORDEM DO CONGRESSO NACIONAL', true);
insert into departments values ('CMCF', 'COCN', 'COMISSÃO MISTA PERMANENTE DE REGULAMENTAÇÃO E CONSOLIDAÇÃO DA LEGISLAÇÃO FEDERAL', true);
insert into departments values ('CMCPLP', 'COCN', 'COMISSÃO MISTA DO CONGRESSO NACIONAL DE ASSUNTOS RELACIONADOS À COMUNIDADE DOS PAÍSES DE LÍNGUA PORTUGUESA', true);
insert into departments values ('CMCVM', 'COCN', 'COMISSÃO PERMANENTE MISTA DE COMBATE À VIOLÊNCIA CONTRA A MULHER', true);
insert into departments values ('CMMC', 'COCN', 'COMISSÃO MISTA PERMANENTE SOBRE MUDANÇAS CLIMÁTICAS', true);
insert into departments values ('CMO', 'COCN', 'COMISSÃO MISTA DE PLANOS, ORÇAMENTOS PÚBLICOS E FISCALIZAÇÃO', true);
insert into departments values ('DMEDR', 'SF', 'CONSELHO DO DIPLOMA DO MÉRITO EDUCATIVO DARCY RIBEIRO', true);
insert into departments values ('GLMAICN', 'SF', 'GABINETE DA LIDERANÇA DO BLOCO DA MAIORIA NO CONGRESSO NACIONAL', true);


-- persons
-- private.accounts
-- orders
-- order_messages
-- order_assets
-- asset_departments
-- private.logs
-- specs
-- items
-- order_items

-- alter sequences
alter sequence orders_order_id_seq restart with 100;
alter sequence persons_person_id_seq restart with 100;

-- create triggers
create trigger log_changes
after insert or update or delete on orders
for each row execute function create_logs();

create trigger log_changes
after insert or update or delete on orders_messages
for each row execute function create_logs();

create trigger log_changes
after insert or update or delete on orders_assets
for each row execute function create_logs();

create trigger log_changes
after insert or update or delete on assets
for each row execute function create_logs();

create trigger log_changes
after insert or update or delete on assets_departments;
for each row execute function create_logs();

create trigger log_changes
after insert or update or delete on contracts
for each row execute function create_logs();

create trigger log_changes
after insert or update or delete on departments
for each row execute function create_logs();

-- create policies (row-level security)
-- alter table tablename enable row level security;
-- create policy unauth_policy on rlstest for select to unauth using (true);
-- create policy auth_policy on rlstest for all to auth using (true) with check (true);
-- create policy graphiql on rlstest for all to postgres using (true) with check (true);
------- instructions:
-- 0) set all access privileges (grant or revoke commands)
-- 1) enable / disable rls for the table (can be used if a policy exists or not --> does not delete existing policies)
-- 2) create / drop policy ("using" --> select, update, delete ;  "with check" --> insert, update)
-- 3) if "for all" ==> 
-- 4) default policy is deny.