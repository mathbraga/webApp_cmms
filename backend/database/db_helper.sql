CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER SEQUENCE orders_order_id_seq RESTART WITH 10;
ALTER SEQUENCE persons_person_id_seq RESTART WITH 10;


select * from assets where asset_id like 'ACAT%';
select * from assets where starts_with(asset_id, 'ACAT-');
select * from assets where asset_id similar to '%((ACAT-))%';

CREATE DATABASE hzl WITH OWNER hzlopes TEMPLATE cmms2 ENCODING 'WIN1252';