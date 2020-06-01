drop trigger if exists check_task_event;
drop function if exists check_task_event;

create or replace function check_task_event ()
  returns trigger
  language plpgsql
  as $$
    declare
      last_event_time timestamptz;
      is_event_ok boolean;
    begin

      with last_event as (
        select  te.task_id,
                max(te.event_time) into last_event_time
            from task_events as te
          where te.task_id = new.task_id
        group by te.task_id
      )
      select  case new.event_name
                -- when 'insert' then true
                when 'send' then new.next_team_id is not null
                when 'receive' then new.team_id = te.next_team_id
                when 'cancel' then new.team_id = te.team_id
                when 'move' then new.task_status_id is not null
              end as is_event_ok
          from task_events as te
        where te.task_id = new.task_id and
            te.event_time = last_event_time
      ;

      if
        is_event_ok then return new;
        else
        raise exception '%', get_exception_message(8);
      end if;

    end;
  $$
;

create trigger check_task_event
before insert on task_events
for each row execute procedure check_task_event();
