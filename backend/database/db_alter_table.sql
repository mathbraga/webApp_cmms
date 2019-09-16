ALTER TABLE orders ALTER COLUMN request_department SET NOT NULL;

ALTER TABLE orders ALTER COLUMN completed DROP NOT NULL;
ALTER TABLE orders ALTER COLUMN ans_factor DROP NOT NULL;
ALTER TABLE orders ALTER COLUMN request_local DROP NOT NULL;
ALTER TABLE orders ALTER COLUMN sigad DROP NOT NULL;

ALTER TABLE assets ALTER COLUMN category DROP NOT NULL;
ALTER TABLE assets ALTER COLUMN category SET NOT NULL;


alter table orders alter column created_at set default now();

ALTER TABLE orders ALTER COLUMN order_id DROP NOT NULL;

alter table orders alter column order_id drop default;
alter table orders alter column order_id add generated always as identity;




