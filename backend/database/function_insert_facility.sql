drop function if exists insert_facility;
-------------------------------------------------------------------------------
create or replace function insert_facility (
  facility_attributes facilities,
  departments_array text[]
)
returns text
language plpgsql
as $$
declare 
  new_facility_id text;
  dept text;
begin

insert into facilities values (facility_attributes.*)
  returning asset_id into new_facility_id;

if departments_array is not null then
  foreach dept in array departments_array::text[] loop
    insert into assets_departments (
      asset_id,
      department_id
    ) values ( 
      new_facility_id,
      dept
    );
  end loop;
end if;

return new_facility_id;

end; $$;
-------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select insert_facility (
  (
    'rttr',
    'CASF-000-000',
    'input_name',
    'input_description',
    'F',
    999,
    9,
    9
  ),
    ARRAY['SEMAC', 'SEPLAG']
);
commit;