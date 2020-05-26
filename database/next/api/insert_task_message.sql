drop function if exists api.insert_task_message;

create or replace function api.insert_task_message (
  in attributes task_messages,
  out id integer
)
  language plpgsql
  as $$
    begin
      insert into task_messages values (
        default,
        attributes.reply_to,
        attributes.task_id,
        attributes.message,
        get_current_person_id(),
        now(),
        now(),
        true
      ) returning task_id into id;
    end;
  $$
;
