begin;

create or replace function get_exception_message (
  in exception_code integer,
  out message text
)
  language plpgsql
  as $$
    declare
      header text;
    begin

      header = 'CMMS ERROR';

      case
        when exception_code = 1 then message = format('%s (%s): mensagem', header, exception_code);
      end case;

    end;
  $$
;

select get_exception_message(1);


rollback;