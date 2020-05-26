drop function if exists api.remove_task_message;

create or replace function api.remove_task_message (
  in attributes task_messages,
  out id integer
)
  language plpgsql
  as $$
    begin
      update task_messages set (
        is_visible
      ) = (
        false
      ) where task_message_id = attributes.task_message_id
      returning task_id into id;
    end;
  $$
;
