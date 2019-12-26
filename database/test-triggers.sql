begin;

insert into specs (spec_id, spec_sf, version, name, spec_category_id, spec_subcategory_id, unit, qty_decimals)
  overriding system value values (20001, 'ZZ-99999', '999', 'testing', 1, 1, 'm', false);

insert into specs (spec_id, spec_sf, version, name, spec_category_id, spec_subcategory_id, unit, qty_decimals)
  overriding system value values (20002, 'ZW-99999', '999', 'testing', 1, 1, 'm', true);

-- select spec_id, name, qty_decimals from specs where qty_decimals = false;

insert into contracts (contract_id, contract_sf, contract_status_id, company, title, description)
  overriding system value values (20001, '99999999', 1, 'ZZZZZZZZZ', 'ZZZWWWZ', 'teste.');

insert into contracts (contract_id, contract_sf, contract_status_id, company, title, description)
  overriding system value values (20002, '99999ZZZ', 1, 'ZZZZZZZZZ', 'ZZZWWWZ', 'teste.');

-- select contract_id, contract_sf from contracts where description = 'teste.';

insert into supplies (supply_id, supply_sf, contract_id, spec_id, qty, bid_price)
  overriding system value values (20001, 'ZZZ', 20001, 20001, 20, '9.9');

insert into supplies (supply_id, supply_sf, contract_id, spec_id, qty, bid_price)
  overriding system value values (20002, 'ZWW', 20001, 20002, 20, '9.9');

insert into supplies (supply_id, supply_sf, contract_id, spec_id, qty, bid_price)
  overriding system value values (20003, 'WZZWW', 20001, 20002, 20, '9.9');

-- select supply_sf, contract_id, spec_id from supplies where supply_sf = 'ZZZ'; 

insert into tasks (task_id, task_status_id, task_priority_id, task_category_id, title, description, person_id, contract_id)
  overriding system value values (20001, 1, 1, 1, 'ZZZZ', 'teste', 3, 20001);

insert into tasks (task_id, task_status_id, task_priority_id, task_category_id, title, description, person_id, contract_id)
  overriding system value values (20002, 1, 1, 1, 'ZZZZ', 'teste', 3, 20002);

-- select task_id, description from tasks where task_id = 20001;

-- select * from balances where supply_id = 20001;

-- insert into task_supplies values (20001, 20001, 25);  -- raise exception '25 is larger than available.'
-- insert into task_supplies values (20001, 20001, 1.3); -- raise exception 'Decimal input is not allowed.'
-- insert into task_supplies values (20001, 20001, 1);   -- no error, qty = 1, qty_decimals = false
-- insert into task_supplies values (20001, 20002, 1.3); -- no error, qty_decimals = true
-- insert into task_supplies values (20001, 20002, 1);   -- no error, qty_decimals = true
insert into task_supplies values (20002, 20003, 1);   -- raise exception 'IDs do not match.'

rollback;