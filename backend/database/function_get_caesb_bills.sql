drop function if exists get_caesb_bills;
-------------------------------------------------------------------------------
create or replace function get_caesb_bills (
  input_meter   integer,
  input_yyyymm1	integer,
  input_yyyymm2 integer
) returns setof caesb_bills
language plpgsql stable as $$
begin
if input_meter = 299 then
  return query select * from caesb_bills
  where true and yyyymm between input_yyyymm1 and input_yyyymm2
  order by caesb_bills.meter_id, caesb_bills.yyyymm;
else
  return query select * from caesb_bills
  where meter_id = input_meter and yyyymm between input_yyyymm1 and input_yyyymm2
  order by caesb_bills.meter_id, caesb_bills.yyyymm;
end if;
end; $$;
-------------------------------------------------------------------------------
select get_caesb_bills(201, 201801, 201812);