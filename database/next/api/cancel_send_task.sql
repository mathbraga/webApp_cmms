drop function if exists api.cancel_send_task;

create or replace function api.cancel_send_task (
  in args task_events,
  out id integer
)
  language plpgsql
  as $$
    begin

      update tasks set (
        recipient_id,
        receive_pending
      ) = (
        row(sender_id), -- swap current sender_id and recipient_id values
        false
      ) where task_id = args.task_id;

      insert into task_events values (
        args.task_id,
        'cancel'::task_event_enum,
        now(),
        get_current_person_id(),
        args.team_id,
        null,
        null,
        null
      ) returning task_id into id;

    end;
  $$
;
