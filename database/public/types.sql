create type file_metadata as (
  filename text,
  uuid uuid,
  size bigint
);

create type mutation_response_type as (
  id integer,
  ok boolean,
  error_code integer,
  error_text text
);

create type task_event_enum as enum (
  'insert',
  'send',
  'receive',
  'cancel',
  'move'
);
