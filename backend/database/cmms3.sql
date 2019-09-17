-- - CREATE EXTENSION
-- - CREATE TYPES
-- - CREATE SCHEMA
-- - CREATE TABLE
-- - CREATE POLICY
-- - CREATE VIEW
-- - CREATE FUNCTION
-- - CREATE TRIGGER
-- - CREATE ROLE
-- - GRANT
-- - COMMENTS



drop table if exists order_items;
drop table if exists items;
drop table if exists orders;
drop table if exists contracts;
drop table if exists standards;

begin;

create table standards (
  standard_id text primary key,
  description text
);

create table contracts (
  parent_type text,
  parent_number integer,
  contract_type text not null, -- transform into enum
  contract_number integer not null,
  date_start date not null,
  date_end date not null,
  primary key (contract_type, contract_number),
  foreign key (parent_type, parent_number) references contracts (contract_type, contract_number)
);

create table orders (
  order_id integer not null primary key,
  date_end date,
  contract_type text not null,
  contract_number integer not null,
  foreign key (contract_type, contract_number) references contracts (contract_type, contract_number)
);

create table items (
  contract_type text not null,
  contract_number integer not null,
  item_id text,
  standard_id text references standards (standard_id),
  description text,
  available real not null,
  provisioned real not null,
  consumed real not null,
  quantity_type text not null, -- transformar em enum (integer or real)
  unit text,
  primary key (contract_type, contract_number, item_id),
  foreign key (contract_type, contract_number) references contracts (contract_type, contract_number)
);

create table order_items (
  order_id integer references orders (order_id),
  contract_type text not null,
  contract_number integer not null,
  item_id text not null,
  quantity real,
  foreign key (contract_type, contract_number, item_id) references items (contract_type, contract_number, item_id)
);



commit;