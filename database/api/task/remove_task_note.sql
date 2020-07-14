drop function if exists api.remove_task_note;

create or replace function api.remove_task_note (
  in task_event_id integer,
  out id integer
)
  language plpgsql
  as $$
    declare
      tmid integer;
    begin
      teid = task_event_id;
      update task_events as te set (
        is_visible
      ) = row(
        false
      ) where te.task_message_id = teid
      returning te.task_id into id;
    end;
  $$
;

-- comment on function api.move_task is E'
-- Input fields (* are mandatory):\n
-- - taskMessageId *
-- ';
