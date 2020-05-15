create type file_metadata as (
  filename text,
  uuid uuid,
  size bigint
);

create type task_dispatch as (
  task_id integer,
  sent_by integer,
  sent_to integer,
  note text
);

create type dispatch_receive as (
  task_id integer,
  sent_at timestamptz
);

create type task_updated_status as (
  task_id integer,
  task_status_id integer,
  note text
);

create type mutation_response_type as (
  id integer,
  ok boolean,
  error_code integer,
  error_text text
);
