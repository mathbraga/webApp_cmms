begin;

set local auth.data.person_id to 1;

create table asset_relations (
  top_id text not null references assets (asset_id),
  parent_id text not null references assets (asset_id),
  asset_id text not null references assets (asset_id),
  primary key (top_id, parent_id, asset_id)
);

insert into asset_relations values ('ELET-00-0000', 'ELET-00-0000', 'a66');
insert into asset_relations values ('ELET-00-0000', 'a66', 'ELET-CA-0006');
insert into asset_relations values ('ELET-00-0000', 'a66', 'ELET-CA-0001');
insert into asset_relations values ('ELET-00-0000', 'ELET-00-0000', 'ELET-QD-0002');

create or replace function get_assets_tree (
  in input text,
  out top_id text,
  out parent_id text,
  out asset_id text
)
returns setof record
language sql
stable
as $$
  with recursive asset_tree (top_id, parent_id, asset_id) as (
    select top_id, parent_id, asset_id
      from asset_relations
      where parent_id = input
    union
    select ar.top_id, ar.parent_id, ar.asset_id
      from asset_tree as atree
        cross join asset_relations as ar
      where atree.asset_id = ar.parent_id
  )
    select top_id, parent_id, asset_id
      from asset_tree;
$$;

select * from get_assets_tree('ELET-00-0000');

rollback;