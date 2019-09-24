drop sequence if exists orders_ids_numbers;
-------------------------------------------------------------
create sequence if not exists orders_ids_numbers
as bigint
increment by 1
minvalue extract(year from now())*1000000
maxvalue 999999
start with extract(year from now())*1000000
owned by testeos.f1
;
--------------------------------------------------------------
alter sequence orders_order_id_seq restart with 10;
alter sequence persons_person_id_seq restart with 10;
