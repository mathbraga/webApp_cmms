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
        attributes.recipient_id,
        null,
        attributes.note
      ) returning task_id into id;

      update tasks as t set (
        sender_id,
        recipient_id,
        is_received
      ) = (
        attributes.team_id,
        attributes.recipient_id,
        false
      ) where t.task_id = attributes.task_id;

    end;
  $$
;
