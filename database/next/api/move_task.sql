drop function if exists api.move_task;

create or replace function api.move_task (
  in event task_events,
  out id integer
)
  language plpgsql
  as $$
    begin

      update tasks set (
        task_status_id
      ) = (
        event.task_status_id
      ) where task_id = event.task_id;

      insert into task_events values (
        event.task_id,
        'move'::task_event_enum,
        now(),
        get_current_person_id(),
        event.team_id,
        null,
        event.task_status_id,
        event.note
      ) returning task_id into id;

    end;
  $$
;
