create or replace function api.dispatch_task (
  in dispatch task_dispatch,
  out success boolean
)
  language plpgsql
  as $$
    begin
      insert into task_dispatches values (
        dispatch.task_id,
        get_current_person_id(),
        dispatch.sent_by,
        dispatch.sent_to,
        now(),
        null,
        dispatch.note
      );
      success = true;
    end;
  $$
;
