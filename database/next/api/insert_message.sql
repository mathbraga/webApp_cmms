drop function if exists api.insert_message;

create or replace function api.insert_message (
  inout id integer,
  message text
)
  language plpgsql
  as $$
    begin
      insert into task_messages values (
        id,
        message,
        get_current_person_id(),
        now(),
        now(),
        true
      ) returning task_id into id;
    end;
  $$
;
