drop function if exists custom_create_teste;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION	custom_create_teste (
  input appliances
)
RETURNS text
LANGUAGE plpgsql
AS $$
-- DECLARE	
--   new_appliance_id text;
BEGIN

  INSERT INTO 

end; $$;
-------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select custom_create_teste (
  ('ZY',
  'input_name',
  'ACAT-000-QDR-00308',
  'description',
  'A',
  'MANUFACT',
  'SERIALN',
  'MODEL',
  564564,
  'WARRANTY',
  'CASF-000-000')
);
delete from assets where asset_id = 'ZY';
commit;