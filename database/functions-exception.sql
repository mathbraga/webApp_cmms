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
        when exception_code = 1 then
          message = format('%s (%s): tarefa sem ativos.', header, exception_code);
        when exception_code = 2 then
          message = format('%s (%s): saldo insuficiente do suprimento.', header, exception_code);
        when exception_code = 3 then
          message = format('%s (%s): quantidade com decimais não permitida para o suprimento.', header, exception_code);
        when exception_code = 4 then
          message = format('%s (%s): contrato da tarefa não corresponde ao contrato dos suprimentos selecionados.', header, exception_code);
        when exception_code = 5 then
          message = format('%s (%s): categoria de ativo inválida.', header, exception_code);
        when exception_code = 6 then
          message = format('%s (%s): árvore de relações de ativos inválida.', header, exception_code);
        else message = header;
      end case;

    end;
  $$
;
