drop function if exists api.send_task;

create or replace function api.send_task (
  in args task_events,
  inout id integer
)
  language plpgsql
  as $$
    begin

      update tasks set (
        sender_id,
        recipient_id,
        receive_pending
      ) = (
        args.team_id,
        args.recipient_id,
        true
      ) where task_id = id;

      insert into task_events values (
        id,
        'send'::task_event_enum,
        now(),
        get_current_person_id(),
        args.team_id,
        args.recipient_id,
        null,
        args.note
      );

    end;
  $$
;
