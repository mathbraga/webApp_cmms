drop function if exists api.modify_task_message;

create or replace function api.modify_task_message (
  in message task_messages,
  out id integer
)
  language plpgsql
  as $$
    begin
      update task_messages as tm set (
        message,
        updated_at
      ) = row(
        message.message,
        now()
      ) where tm.task_message_id = message.task_message_id
      returning tm.task_id into id;
    end;
  $$
;
