drop function if exists api.remove_task_message;

create or replace function api.remove_task_message (
  in task_message_id integer,
  out id integer
)
  language plpgsql
  as $$
    declare
      tmid integer;
    begin
      tmid = task_message_id;
      update task_messages as tm set (
        is_visible
      ) = row(
        false
      ) where tm.task_message_id = tmid
      returning tm.task_id into id;
    end;
  $$
;

comment on function api.move_task is E'
Input fields (* are mandatory):\n
- taskMessageId *
';
