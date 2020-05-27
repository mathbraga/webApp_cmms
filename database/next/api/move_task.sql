drop function if exists api.move_task;

create or replace function api.move_task (
  in args task_events,
  inout id integer
)
  language plpgsql
  as $$
    begin

      update tasks set (
        task_status_id
      ) = (
        args.task_status_id
      ) where task_id = id;

      insert into task_events values (
        id,
        'move'::task_event_enum,
        now(),
        get_current_person_id(),
        args.team_id,
        null,
        args.task_status_id,
        args.note
      );

    end;
  $$
;
