create or replace function check_task_supply ()
  returns trigger
  language plpgsql
  as $$
    declare
      qty_ok boolean;
      decimals_ok boolean;
      contract_ok boolean;
    begin

      select ((b.qty_available + coalesce(old.qty, 0) - new.qty) >= 0),
            (z.allow_decimals or scale(new.qty) = 0),
            (t.contract_id = s.contract_id)
            into
            qty_ok,
            decimals_ok,
            contract_ok
        from supplies as s
        inner join specs as z using (spec_id)
        inner join balances as b using (supply_id)
        inner join tasks as t on (t.task_id = new.task_id)
      where s.supply_id = new.supply_id;

      if qty_ok and decimals_ok and contract_ok then
        return new;
      elsif not qty_ok then
        raise exception '%', get_exception_message(2);
      elsif not decimals_ok then
        raise exception '%', get_exception_message(3);
      else
        raise exception '%', get_exception_message(4);
      end if;

    end;
  $$
;
