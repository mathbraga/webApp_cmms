drop function if exists api.modify_task_message;

create or replace function api.modify_task_message (
  in args task_messages,
  inout id integer
)
  language plpgsql
  as $$
    begin
      update task_messages set (
        message,
        updated_at
      ) = (
        args.message,
        now()
      ) where task_message_id = attributes.task_message_id;
    end;
  $$
;
