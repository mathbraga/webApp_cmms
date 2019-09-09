CREATE OR REPLACE FUNCTION check_appliance_place()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF (SELECT category FROM assets WHERE asset_id = NEW.place) = 'F' THEN
    RETURN NEW;
  ELSE
    RAISE EXCEPTION  'Place attribute of the appliance must be a facility';
  END IF;
END;
$$;


CREATE TRIGGER check_appliance_place
  BEFORE INSERT OR UPDATE ON assets
  FOR EACH ROW EXECUTE FUNCTION check_appliance_place();


INSERT INTO assets VALUES ('ZZZZ-000-ZZZ-9999', 'BL14-MEZ-041', 'Nome do equipamento', 'Descricao do ativo', 'E', 0, 0, 0, 'Fabricante', '-', 'CARRIER - 42LS', '0', 'Garantia', 'BL02-000-000');
