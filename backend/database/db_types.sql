alter type asset_category_type add value 'X' after 'Z';
alter type asset_category_type add value 'A';
update assets set category = 'A' where category = 'E';
--------------------------------------------------------------------
-- updating enums
alter type order_category_type rename to order_category_old;
alter type order_status_type   rename to order_status_old;
alter type order_priority_type rename to order_priority_old;

alter type order_category_old  add value 'ELE';
alter type order_status_old    add value 'PEN';
alter type order_priority_old  add value |'BAI';

update orders set (category, status, priority) = ('ELE', 'PEN', 'BAI') where true;

create type order_status_type as enum ('CAN', 'NEG', 'PEN', 'SUS', 'FIL', 'EXE', 'CON');
create type order_priority_type as enum ('BAI', 'NOR', 'ALT', 'URG');
create type order_category_type as enum ('EST', 'FOR', 'INF', 'ELE', 'HID', 'MAR', 'PIS', 'REV', 'VED', 'VID', 'SER');
alter table orders alter column status   type order_status_type   using status::text::order_status_type;
alter table orders alter column category type order_category_type using category::text::order_category_type;
alter table orders alter column priority type order_priority_type using priority::text::order_priority_type;
drop type order_status_old;
drop type order_category_old;
drop type order_priority_old;