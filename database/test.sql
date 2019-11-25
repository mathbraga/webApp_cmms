begin;

drop function if exists insert_test_and_upload;
drop table if exists test_files;

create table test_files (
  test_id integer,
  filename text,
  uuid text,
  size bigint,
  person_id integer,
  created_at timestamptz
);

create or replace function insert_test_and_upload(
  test_attributes tests,
  files_metadata test_files[]
)
returns integer
language plpgsql
as $$
declare
  result integer;
begin
  insert into tests values (default, test_attributes.test_text, test_attributes.contract_id)
  returning test_id into result;
  insert into test_files select 
    result,
    a.filename,
    a.uuid,
    a.size,
    current_setting('auth.data.person_id')::integer,
    now()
  from unnest(files_metadata) as a;
  return result;
end; $$;

set local auth.data.person_id to 1;

select * from insert_test_and_upload(
  (
    70,
    'text',
    1
  )::tests,
  array[
    (
      70,
      'filename1',
      'uuid1',
      12342343,
      null,
      null
    )::test_files,
    (
      70,
      'filename2',
      'uuid2',
      12342343,
      null,
      null
    )::test_files
  ]
);

table test_files;

commit;
