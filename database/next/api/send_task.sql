drop function if exists api.send_task;

create or replace function api.send_task (
  in attributes task_events,
  out id integer
)
  language plpgsql
  as $$
    begin

      insert into task_events values (
        attributes.task_id,
        'send'::task_event_enum,
        now(),
        get_current_person_id(),
        attributes.team_id,
        attributes.send_to,
        null,
        attributes.note
      ) returning task_id into id;

    end;
  $$
;
