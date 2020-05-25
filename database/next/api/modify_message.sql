drop function if exists api.modify_message;

create or replace function api.modify_message (
  inout id,
  in message
)
  language plpgsql
  as $$
    begin
      update task_messages set (
        message,
        updated_at
      ) = (
        message,
        now()
      ) where
        task_id = id and
        created_at = attributes.created_at
      returning task_id into id;
    end;
  $$
;
