create or replace function api.udate_task_status (
  in task_updated_status task_updated_status,
  out success boolean
)
  language plpgsql
  as $$
    begin
      insert into task_status values (
        task_updated_status.task_id,
        now(),
        get_current_person_id(),
        task_updated_status.task_status_id,
        task_updated_status.note
      );
      success = true;
    end;
  $$
;
