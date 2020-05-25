drop function if exists api.modify_message;

create or replace function api.modify_message (
  inout id integer,
  in attributes task_messages
)
  language plpgsql
  as $$
    begin
      update task_messages set (
        message,
        updated_at
      ) = (
        attributes.message,
        now()
      ) where
        task_id = id and
        created_at = attributes.created_at
      returning task_id into id;
    end;
  $$
;
