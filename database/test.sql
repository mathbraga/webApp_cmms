begin;
set local auth.data.person_id to 1;
create or replace function get_children_orders (
  in parent_prefix text,
  out child_id text,
  out order_ids_list integer[],
  out order_titles_list text[],
  out order_status_list text[]
)
language sql
strict
immutable
as $$
  with
    children as (
      select asset_id
        from assets
        where starts_with(asset_id, parent_prefix)
    )
    select asset_id as child_id
           array_agg(order_id) as order_ids_list,
           array_agg(request_title) as order_titles_list,
           array_agg(status) as order_status_list
      from children
      inner join order_assets using (asset_id)
      inner join orders using (order_id)
    group by child_id;
$$;
select * from get_children_orders('BL14');



-- getting an assets's update history from private.logs table:
create or replace function get_asset_history (
  in asset_id text,
  out fullname text,
  out created_at timestamptz,
  out asset_json jsonb
)
language sql
stable
as $$
  with target_asset as (
    select '{"asset_id":"' || asset_id || '"}'::jsonb
  )
  select p.fullname,
         l.created_at,
         l.new_row as asset_json
    from private.logs as l
    inner join persons as p using (person_id)
  where tablename = 'assets' and new_row ? target_asset;
$$;
rollback;