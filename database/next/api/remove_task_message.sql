drop function if exists api.remove_task_message;

create or replace function api.remove_task_message (
  in task_message_id integer,
  out id integer
)
  language plpgsql
  as $$
    begin
      update task_messages as tm set (
        is_visible
      ) = (
        false
      ) where tm.task_message_id = task_message_id
      returning tm.task_id into id;
    end;
  $$
;
