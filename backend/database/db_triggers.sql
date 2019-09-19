drop trigger if exists check_asset_integrity on assets;
drop function if exists check_asset_integrity;
---------------------------------------------------------------------------
create or replace function check_asset_integrity()
returns trigger
language plpgsql
as $$
begin
  -- facility case
  if new.category = 'f' then
    if (select category from assets where asset_id = new.parent) = 'f' then
      return new;
    else
      raise exception  'Parent attribute of the new facility must be a facility';
    end if;
  
    if (select category from assets where asset_id = new.place) = 'f' then
      return new;
    else
      raise exception  'Place attribute of the new facility must be a facility';
    end if;
  end if;

  -- appliance case
  if new.category = 'a' then
    if (select category from assets where asset_id = new.parent) = 'a' then
      return new;
    else
      raise exception  'Parent attribute of the new appliance must be an appliance';
    end if;
    if (select category from assets where asset_id = new.place) = 'a' then
      return new;
    else
      raise exception  'Place attribute of the new appliance must be a facility';
    end if;
    if (new.description = '' or new.description is null) then
      raise exception 'New appliance must have a description';
    end if;
  end if;
end;
$$;

create trigger check_asset_integrity
  before insert or update on assets
  for each row execute function check_asset_integrity();