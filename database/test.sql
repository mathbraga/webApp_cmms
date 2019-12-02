begin;

drop view if exists supplies_list;

create view supplies_list as
  select s.supply_id,
         s.supply_sf,
         s.contract_id,
         z.name
         from supplies as s
         inner join specs as z using (spec_id);


commit;