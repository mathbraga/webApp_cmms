begin;

drop function if exists insert_with_upload;

drop table if exists test_files;

create table test_files (
  test_id integer,
  file_metadata jsonb,
  person_id integer,
  created_at timestamptz default now()
);

create or replace function insert_with_upload (
  test_attributes tests,
  file_metadata jsonb
)
returns integer
language plpgsql
as $$
declare
  result integer;
begin
  
  insert into tests values (default, test_attributes.test_text, test_attributes.contract_id)
  returning test_id into result;

  insert into test_files values (
    result,
    file_metadata,
    current_setting('auth.data.person_id')::integer,
    now()
  );

  return result;
end; $$;

commit;
