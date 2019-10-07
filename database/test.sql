begin;

set auth.data.person_id to 1;

create or replace function insert_contract (
  in contract_attributes contracts,
  in supplies_array supplies[]
)
returns text
language plpgsql
as $$
declare
  new_contract_id text;
begin

  insert into contracts
    select (contract_attributes.*)
    returning contract_id into new_contract_id;

  insert into supplies
    select ((unnest(supplies_array)).*);

  return new_contract_id;

end; $$;

select insert_contract(
  (
    'CT00000000',
    null,
    '2019-01-01',
    '2019-01-01',
    '2019-01-31',
    '2019-12-31',
    'company',
    'description',
    'url'
  )::contracts,
  array[
    (
      'CT00000000',
      'M1',
      null,
      1000,
      false,
      'un.',
      77.88,
      80.99
    )::supplies
    ,
    (
      'CT00000000',
      'M2',
      null,
      2000,
      true,
      'm²',
      7.88,
      8.99
    )::supplies
  ]
);

table contracts;

table supplies;

rollback;
