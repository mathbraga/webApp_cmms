drop function if exists api.finish_task;

create or replace function api.finish_task (
  in attributes task_events,
  out id integer
)
  language plpgsql
  as $$
    begin

      insert into task_events values (
        attributes.task_id,
        'move'::task_event_enum,
        now(),
        get_current_person_id(),
        attributes.team_id,
        null,
        get_constant_value('task_finished_status')::integer,
        attributes.note
      ) returning task_id into id;

      update tasks as t set (
        task_status_id
      ) = (
        get_constant_value('task_finished_status')::integer
      ) where t.task_id = attributes.task_id;

    end;
  $$
;
