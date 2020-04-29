create type task_dispatch as (
  task_id integer,
  sent_by integer,
  sent_to integer,
  note text
);
