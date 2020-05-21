drop function if exists api.cancel_send_task;

create or replace function api.cancel_send_task (
  in attributes task_events,
  out id integer
)
  language plpgsql
  as $$
    begin

      insert into task_events values (
        attributes.task_id,
        'cancel'::task_event_enum,
        now(),
        get_current_person_id(),
        attributes.team_id,
        null,
        null,
        null
      ) returning task_id into id;

    end;
  $$
;
