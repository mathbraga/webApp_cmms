ALTER TABLE orders ALTER COLUMN request_department SET NOT NULL;

ALTER TABLE orders ALTER COLUMN completed DROP NOT NULL;
ALTER TABLE orders ALTER COLUMN ans_factor DROP NOT NULL;
ALTER TABLE orders ALTER COLUMN request_local DROP NOT NULL;
ALTER TABLE orders ALTER COLUMN sigad DROP NOT NULL;

ALTER TABLE assets ALTER COLUMN category DROP NOT NULL;
ALTER TABLE assets ALTER COLUMN category SET NOT NULL;


alter table orders alter column created_at set default now();

alter table assets alter column description DROP NOT NULL;

alter table orders alter column order_id drop default;
alter table orders alter column order_id add generated always as identity;

alter table teste alter column f1 drop default;
alter table teste alter column f1 add generated always as identity;

drop table teste;
create table teste (
  f1 integer primary key generated always as identity,
  f2 text
);


alter table assets add foreign key (place) references assets (asset_id);