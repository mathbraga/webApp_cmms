drop function if exists custom_create_appliance;
-------------------------------------------------------------------------------
create or replace function	custom_create_appliance (
  appliance_attributes         appliances,
  departments_array  text[]
)
returns text
language plpgsql
as $$
declare	
  new_appliance_id text;
  dept text;
begin

insert into	appliances values (appliance_attributes.*)
  returning asset_id into new_appliance_id;

if departments_array is not null then
  foreach	dept in array departments_array::text[] loop
    insert into	assets_departments (
      asset_id,
      department_id
    ) values (	
      new_appliance_id,
      dept
    );
  end loop;
end if;

return new_appliance_id;

end; $$;
-------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select custom_create_appliance (
  ('zzksfdkddddkzz',
  'acat-000-qdr-00308',
  'name',
  'description',
  'a',
  'manufacturer',
  'serialnum',
  'model',
  65465,
  'warranty',
  'casf-000-000'),
  null
);
commit;