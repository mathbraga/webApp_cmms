begin;
----------------------------------------------------
create or replace function modify_facility (
  facility_id text,
  facility_attributes facilities,
  departments_array text[]
)
returns text
language plpgsql
as $$
begin
  update assets as a
    set (
      parent,
      place,
      name,
      description,
      category,
      latitude,
      longitude,
      area
    ) = (
      facility_attributes.parent,
      facility_attributes.place,
      facility_attributes.name,
      facility_attributes.description,
      facility_attributes.category,
      facility_attributes.latitude,
      facility_attributes.longitude,
      facility_attributes.area
    ) where a.asset_id = facility_id;

  delete from asset_departments where asset_id = facility_id;

  if departments_array is not null then
    insert into asset_departments select facility_id, unnest(departments_array);
  end if;

  return facility_id;

end; $$;
----------------------------------------------------
set local auth.data.person_id to 1;
select modify_facility(
  'CASF-000-000',
  (
    'CASF-000-000',
    'BL15-000-000',
    'BL15-000-000',
    'Novo nome',
    'nova descr',
    'F',
    null,
    null,
    9999999
  ),
  ARRAY['SINFRA', 'SADCON']
);
select * from facilities where asset_id = 'CASF-000-000';
----------------------------------------------------
rollback;
select * from facilities where asset_id = 'CASF-000-000';