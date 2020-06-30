drop trigger if exists check_task_message on task_messages;
drop function if exists check_task_message;

create or replace function check_task_message ()
  returns trigger
  language plpgsql
  as $$
    declare
      is_same_person_id boolean;
    begin
      is_same_person_id = old.person_id = new.person_id;
      if is_same_person_id then
        return new;
      else
        raise exception '%', get_exception_message(9);
      end if;
    end;
  $$
;

create trigger check_task_message
before update on task_messages
for each row execute procedure check_task_message();
