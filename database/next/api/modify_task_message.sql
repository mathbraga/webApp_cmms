drop function if exists api.modify_task_message;

create or replace function api.modify_task_message (
  in attributes task_messages,
  out id integer
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
      ) where task_message_id = attributes.task_message_id
      returning task_id into id;
    end;
  $$
;
