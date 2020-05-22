drop function if exists api.receive_task;

create or replace function api.receive_task (
  in attributes task_events,
  out id integer
)
  language plpgsql
  as $$
    begin

      update tasks set (team_id) = (attributes.team_id);

      insert into task_events values (
        attributes.task_id,
        'receive'::task_event_enum,
        now(),
        get_current_person_id(),
        attributes.team_id,
        null,
        attributes.task_status_id,
        null,
      ) returning task_id into id;

      update tasks as t set (
        is_received
      ) = (
        true
      ) where t.task_id = attributes.task_id;

    end;
  $$
;
