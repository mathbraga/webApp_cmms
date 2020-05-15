create or replace function check_asset_relation ()
  returns trigger
  language plpgsql
  as $$
    begin

      if new.parent_id is not null then
        if (select bool_and(parent_id is null) from asset_relations where asset_id = new.top_id) then
          return new;
        else
          raise exception '%', get_exception_message(6);
        end if;
      else
        raise exception '%', get_exception_message(7);
      end if;

    end;
  $$
;
