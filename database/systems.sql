begin;

create type system_type as enum (
  'e', -- electrical
  'h', -- hydro
  'a'  -- air conditioning
);

create table asset_trees (
  asset_path ltree not null,
  asset_id text not null references assets (asset_id),
  parent_id text not null references assets (asset_id),
  system_type system_type not null,
  primary key (parent_id, child_id)
);

rollback;