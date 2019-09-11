drop trigger if exists check_asset_integrity on assets;
drop function if exists check_asset_integrity;
---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_asset_integrity()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- Facility case
  IF NEW.category = 'F' THEN
    IF (SELECT category FROM assets WHERE asset_id = NEW.parent) = 'F' THEN
      RETURN NEW;
    ELSE
      RAISE EXCEPTION  'Parent attribute of the new facility must be a facility';
    END IF;
    IF (SELECT category FROM assets WHERE asset_id = NEW.place) = 'F' THEN
      RETURN NEW;
    ELSE
      RAISE EXCEPTION  'Place attribute of the new facility must be a facility';
    END IF;
  END IF;

  -- Appliance case
  IF NEW.category = 'A' THEN
    IF (SELECT category FROM assets WHERE asset_id = NEW.parent) = 'F' THEN
      RETURN NEW;
    ELSE
      RAISE EXCEPTION  'Parent attribute of the new appliance must be an appliance';
    END IF;
    IF (SELECT category FROM assets WHERE asset_id = NEW.place) = 'A' THEN
      RETURN NEW;
    ELSE
      RAISE EXCEPTION  'Place attribute of the new appliance must be a facility';
    END IF;
  END IF;
END;
$$;

CREATE TRIGGER check_asset_integrity
  BEFORE INSERT OR UPDATE ON assets
  FOR EACH ROW EXECUTE FUNCTION check_asset_integrity();