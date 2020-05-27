drop function if exists api.receive_task;

create or replace function api.receive_task (
  in args task_events,
  inout id integer
)
  language plpgsql
  as $$
    begin

      update tasks set (
        recipient_id,
        receive_pending
      ) = (
        args.team_id,
        false
      ) where task_id = id;

      insert into task_events values (
        id,
        'receive'::task_event_enum,
        now(),
        get_current_person_id(),
        args.team_id,
        null,
        args.task_status_id,
        null
      );

    end;
  $$
;
