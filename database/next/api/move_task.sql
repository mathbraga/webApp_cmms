drop function if exists api.move_task;

create or replace function api.move_task (
  in attributes task_events,
  out id integer
)
  language plpgsql
  as $$
    begin

      update tasks set (
        task_status_id
      ) = (
        attributes.task_status_id
      ) where task_id = attributes.task_id;

      insert into task_events values (
        attributes.task_id,
        'move'::task_event_enum,
        now(),
        get_current_person_id(),
        attributes.team_id,
        null,
        attributes.task_status_id,
        attributes.note
      ) returning task_id into id;

    end;
  $$
;
