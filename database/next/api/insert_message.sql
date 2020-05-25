drop function if exists api.insert_message;

create or replace function api.insert_message (
  inout id integer,
  in attributes task_messages
)
  language plpgsql
  as $$
    begin
      insert into task_messages values (
        id,
        attributes.message,
        get_current_person_id(),
        now(),
        now(),
        true
      ) returning task_id into id;
    end;
  $$
;
