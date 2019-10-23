begin;

set local auth.data.person_id to 1;

create type system_type as enum (
  'e', -- electrical
  'h', -- hydro
  'a'  -- air conditioning
);

create table asset_branches (
  -- asset_path ltree not null,
  asset_id text not null references assets (asset_id),
  parent_id text not null references assets (asset_id),
  top_id text not null references assets (asset_id),
  primary key (asset_id, parent_id, top_id)
);

insert into asset_branches values ('a66','ELET-00-0000','ELET-00-0000');
insert into asset_branches values ('ELET-CA-0006','a66','ELET-00-0000');
insert into asset_branches values ('ELET-CA-0001','a66','ELET-00-0000');
insert into asset_branches values ('ELET-QD-0002','ELET-00-0000','ELET-00-0000');

-- insert into asset_branches values ('a66', 'ARC-00-0000');

create or replace function get_children_assets (
  in parent_input text,
  out asset_id text,
  out parent text
)
returns setof record
language sql
stable
as $$
  with recursive asset_tree (asset_id, parent_id) as (
    select asset_id, parent_id
      from asset_branches
      where parent_id = parent_input
    union
    select a.asset_id, a.parent_id
      from asset_tree as atree
        cross join asset_branches as a
      where atree.asset_id = a.parent_id
  )
  select * from asset_tree;
$$;

select * from get_children_assets('ELET-00-0000');

rollback;