drop function if exists get_ceb_bills;
-------------------------------------------------------------------------------
create or replace function get_ceb_bills (
  input_meter   integer,
  input_yyyymm1 integer,
  input_yyyymm2 integer
) returns setof ceb_bills
language plpgsql stable as $$
begin
if input_meter = 199 then
  return query select * from ceb_bills
  where true and yyyymm between input_yyyymm1 and input_yyyymm2
  order by ceb_bills.meter_id, ceb_bills.yyyymm;
else
  return query select * from ceb_bills
  where meter_id = input_meter and yyyymm between input_yyyymm1 and input_yyyymm2
  order by ceb_bills.meter_id, ceb_bills.yyyymm;
end if;
end; $$;
-------------------------------------------------------------------------------
select get_ceb_bills(101, 201801, 201812);