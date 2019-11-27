begin;

drop function if exists insert_order;
drop table if exists order_files;

create table order_files (
  order_id integer,-- references orders (order_id),
  filename text,
  uuid text,
  size bigint,
  person_id integer,-- references persons (person_id),
  created_at timestamptz default now()
);

create or replace function insert_order (
  in order_attributes orders,
  in assets_array integer[],
  in files_metadata files_metadata[],
  out new_order_id integer
)
language plpgsql
as $$
begin
  insert into orders values (
    default,
    order_attributes.status,
    order_attributes.priority,
    order_attributes.category,
    order_attributes.parent,
    order_attributes.contract_id,
    order_attributes.title,
    order_attributes.description,
    order_attributes.department_id,
    order_attributes.created_by,
    order_attributes.contact_name,
    order_attributes.contact_phone,
    order_attributes.contact_email,
    order_attributes.place,
    order_attributes.progress,
    order_attributes.date_limit,
    order_attributes.date_start,
    order_attributes.date_end,
    default,
    default
  ) returning order_id into new_order_id;

  insert into order_assets select new_order_id, unnest(assets_array);

  insert into order_files
    select new_order_id,
           f.filename,
           f.uuid,
           f.size,
           current_setting('auth.data.person_id')::integer,
           now()
      from unnest(files_metadata) as f;

end; $$;


commit;