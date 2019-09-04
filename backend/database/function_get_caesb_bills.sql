drop function if exists get_caesb_bills;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_caesb_bills (
  input_meter   integer,
  input_yyyymm1	integer,
  input_yyyymm2 integer
) RETURNS SETOF caesb_bills
LANGUAGE plpgsql STABLE AS $$
BEGIN
IF input_meter = 299 THEN
  RETURN QUERY SELECT * FROM caesb_bills
  WHERE TRUE AND yyyymm BETWEEN input_yyyymm1 AND input_yyyymm2
  ORDER BY caesb_bills.meter_id, caesb_bills.yyyymm;
ELSE
  RETURN QUERY SELECT * FROM caesb_bills
  WHERE meter_id = input_meter AND yyyymm BETWEEN input_yyyymm1 AND input_yyyymm2
  ORDER BY caesb_bills.meter_id, caesb_bills.yyyymm;
END IF;
END; $$;
-------------------------------------------------------------------------------
select get_caesb_bills(201, 201801, 201812);