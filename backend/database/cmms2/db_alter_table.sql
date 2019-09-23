alter table orders alter column request_department set not null;

alter table orders alter column completed drop not null;
alter table orders alter column ans_factor drop not null;
alter table orders alter column request_local drop not null;
alter table orders alter column sigad drop not null;

alter table assets alter column category drop not null;
alter table assets alter column category set not null;


alter table orders alter column created_at set default now();

alter table assets alter column description drop not null;

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