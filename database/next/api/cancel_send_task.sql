drop function if exists api.cancel_send_task;

create or replace function api.cancel_send_task (
  in event task_events,
  out id integer
)
  language plpgsql
  as $$
    begin

      update tasks set (
        next_team_id
      ) = row(
        null
      ) where task_id = event.task_id;

      insert into task_events values (
        event.task_id,
        'cancel'::task_event_enum,
        now(),
        get_current_person_id(),
        event.team_id,
        null,
        null,
        null
      ) returning task_id into id;

    end;
  $$
;
