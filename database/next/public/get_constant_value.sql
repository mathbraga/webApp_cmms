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
        when 'another_constant_name'  then '2'
      end
    as constant_value;
  $$
;
