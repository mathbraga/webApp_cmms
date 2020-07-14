drop function if exists api.insert_task_message;

create or replace function api.insert_task_message (
  in message task_messages,
  out id integer
)
  language plpgsql
  as $$
    begin
      insert into task_messages as tm values (
        default,
        message.reply_to,
        message.task_id,
        message.message,
        get_person_id(),
        now(),
        now(),
        true
      ) returning tm.task_id into id;
    end;
  $$
;

comment on function api.insert_task_message is E'
Input fields (* are mandatory):\n
- message.taskId *\n
- message.replyTo\n
- message.message *
';
