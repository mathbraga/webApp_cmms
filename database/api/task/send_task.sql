drop function if exists api.send_task;

create or replace function api.send_task (
  in event task_events,
  out id integer
)
  language plpgsql
  as $$
    begin

      insert into task_events values (
        event.task_id,
        'send'::task_event_enum,
        now(),
        get_person_id(),
        event.team_id,
        event.next_team_id,
        null,
        event.note
      ) returning task_id into id;

      update tasks set (
        team_id,
        next_team_id
      ) = (
        event.team_id,
        event.next_team_id
      ) where task_id = event.task_id;

    end;
  $$
;
