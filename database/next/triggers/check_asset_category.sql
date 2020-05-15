create or replace function check_asset_category ()
  returns trigger
  language plpgsql
  as $$
    begin
      if (select parent_id from asset_relations where asset_id = new.category) is null then
        return new;
      else
        raise exception '%', get_exception_message(5);
      end if;
    end;
  $$
;
