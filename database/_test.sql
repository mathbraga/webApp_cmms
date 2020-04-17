BEGIN;

create domain precision_value as numeric
    check(
        scale(value) < 3
    );

create domain location_value as numeric;

create table testing (
    qty precision_value,
    latitude location_value
);

insert into testing values (32.45, 4.78); --pass
insert into testing values (352.456, 4.78); --error

select * from testing;

ROLLBACK;