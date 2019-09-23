comment on table persons is null;

comment on column orders.order_id is E'@name id';
comment on column orders.order_id is null;

comment on function custom_create_order is E'@arg0variant base';
comment on function custom_create_order is null;

comment on column orders.created_at is E'@omit read';
comment on column orders.created_at is null;

