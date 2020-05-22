drop function if exists get_constant_value;

create or replace function get_constant_value(
  in constant_name text,
  out constant_value text
)
  language sql
  as $$
    select
      case constant_name
        when 'task_initial_status'    then '1'
        when 'task_canceled_status'   then '6'
        when 'task_finished_status'   then '7'
      end
    as constant_value;
  $$
;
