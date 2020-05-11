create or replace function api.receive_dispatch (
  in dispatch_receive dispatch_receive,
  out success boolean
)
  language plpgsql
  as $$
    begin
      update task_dispatches as td
        set received_at = now()
        where 
        td.task_id = dispatch_receive.task_id and
        td.sent_at = dispatch_receive.sent_at
      ;
      success = true;
    end;
  $$
;
