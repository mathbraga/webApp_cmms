drop function if exists api.send_task;

create or replace function api.send_task (
  in event task_events,
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
        event.team_id,
        event.recipient_id,
        true
      ) where task_id = event.task_id;

      insert into task_events values (
        event.task_id,
        'send'::task_event_enum,
        now(),
        get_current_person_id(),
        event.team_id,
        event.recipient_id,
        null,
        event.note
      ) returning task_id into id;

    end;
  $$
;
