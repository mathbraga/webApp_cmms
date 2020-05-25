drop function if exists api.remove_message;

create or replace function api.remove_message (
  inout id integer,
  in attributes task_messages
)
  language plpgsql
  as $$
    begin
      update task_messages set (
        is_visible
      ) = (
        false
      ) where
        task_id = id and
        created_at = attributes.created_at
      returning task_id into id;
    end;
  $$
;
