begin;

set local auth.data.person_id to 1;

create or replace function get_children_orders (
  in parent_prefix text,
  out child_id text,
  out order_ids_list integer[],
  out order_titles_list text[],
  out order_status_list order_status_type[]
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
    select asset_id as child_id,
           array_agg(order_id) as order_ids_list,
           array_agg(request_title) as order_titles_list,
           array_agg(status) as order_status_list
      from children
      inner join order_assets using (asset_id)
      inner join orders using (order_id)
    group by child_id;
$$;

create or replace function get_asset_history (
  in asset_id text,
  out fullname text,
  out created_at timestamptz,
  out asset_json jsonb
)
returns setof record
security definer
language sql
stable
as $$
  select p.full_name,
         l.created_at,
         l.new_row as asset_json
    from private.logs as l
    inner join persons as p using (person_id)
  where l.tablename = 'assets' and l.new_row @> ('{"asset_id": "' || asset_id || '"}')::jsonb;
$$;

create or replace function get_order_history (
  in order_id integer,
  out fullname text,
  out created_at timestamptz,
  out order_json jsonb
)
returns setof record
security definer
language sql
stable
as $$
  select p.full_name,
         l.created_at,
         l.new_row as order_json
    from private.logs as l
    inner join persons as p using (person_id)
  where l.tablename = 'orders' and l.new_row @> ('{"order_id": ' || order_id::text || '}')::jsonb;
$$;


-- select modify_appliance(
--   (
--     'CIVL-BM-0001',
--     'ELET-CA-0003',
--     'CASF-000-000',
--     'hahhah',
--     'hehehehhehehwhwhwhhw',
--     'A',
--     null,
--     null,
--     null,
--     null,
--     null
--   ),
--   null
-- );

-- select * from modify_order (
--   (5,'PEN','NOR','ELE',null,null,0,'Consertar ar-condicionado','DGER','Machado de Assis','Mario Vargas','3303-4352','Mario@senado.gov.br','Ar-condicionado nÇo estÇ funcionando','Sala 45 do Anexo I, Pavimento 9','2019-10-20 00:00:00-03',null,null,'2019-09-28 15:45:00.242708-03','2019-09-28 15:45:00.242708-03'),
--   array['BL14-000-000']
-- );

-- select * from modify_order (
--   (5,'FIL','NOR','ELE',null,null,0,'Consertar ar-condicionado','DGER','Machado de Assis','Mario Vargas','3303-4352','Mario@senado.gov.br','Ar-condicionado nÇo estÇ funcionando','Sala 45 do Anexo I, Pavimento 9','2019-10-20 00:00:00-03',null,null,'2019-09-28 15:45:00.242708-03','2019-09-28 15:45:00.242708-03'),
--   array['BL14-000-000']
-- );

-- select * from modify_order (
--   (5,'CON','NOR','ELE',null,null,100,'Consertar ar-condicionado','DGER','Machado de Assis','Mario Vargas','3303-4352','Mario@senado.gov.br','Ar-condicionado nÇo estÇ funcionando','Sala 45 do Anexo I, Pavimento 9','2019-10-20 00:00:00-03',null,null,'2019-09-28 15:45:00.242708-03','2019-09-28 15:45:00.242708-03'),
--   array['BL14-000-000']
-- );

-- select * from get_children_orders('BL14');

-- select * from get_asset_history('CIVL-BM-0001');

-- select * from get_order_history(5);

rollback;