drop function if exists api.receive_task;

create or replace function api.receive_task (
  in event task_events,
  out id integer
)
  language plpgsql
  as $$
    begin

      update tasks set (
        team_id,
        next_team_id
      ) = (
        event.team_id,
        null
      ) where task_id = event.task_id;

      insert into task_events values (
        event.task_id,
        'receive'::task_event_enum,
        now(),
        get_current_person_id(),
        event.team_id,
        null,
        event.task_status_id,
        null
      ) returning task_id into id;

    end;
  $$
;
