drop function if exists get_ceb_bills;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_ceb_bills (
  input_meter   integer,
  input_yyyymm1 integer,
  input_yyyymm2 integer
) RETURNS SETOF ceb_bills
LANGUAGE plpgsql STABLE AS $$
BEGIN
IF input_meter = 199 THEN
  RETURN QUERY SELECT * FROM ceb_bills
  WHERE TRUE AND yyyymm BETWEEN input_yyyymm1 AND input_yyyymm2
  ORDER BY ceb_bills.meter_id, ceb_bills.yyyymm;
ELSE
  RETURN QUERY SELECT * FROM ceb_bills
  WHERE meter_id = input_meter AND yyyymm BETWEEN input_yyyymm1 AND input_yyyymm2
  ORDER BY ceb_bills.meter_id, ceb_bills.yyyymm;
END IF;
END; $$;
-------------------------------------------------------------------------------
select get_ceb_bills(101, 201801, 201812);