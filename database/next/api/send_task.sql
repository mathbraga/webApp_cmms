drop function if exists api.send_task;

create or replace function api.send_task (
  in attributes task_events,
  out id integer
)
  language plpgsql
  as $$
    begin

      update tasks set (
        sender_id,
        recipient_id,
        receive_pending
      ) = (
        attributes.team_id,
        attributes.recipient_id,
        true
      ) where task_id = attributes.task_id;

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

    end;
  $$
;
