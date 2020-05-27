drop function if exists api.insert_task_message;

create or replace function api.insert_task_message (
  in args task_messages,
  inout id integer
)
  language plpgsql
  as $$
    begin
      insert into task_messages values (
        default,
        args.reply_to,
        id,
        args.message,
        get_current_person_id(),
        now(),
        now(),
        true
      );
    end;
  $$
;
