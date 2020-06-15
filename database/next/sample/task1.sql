set local cookie.session.person_id to 1;

select api.insert_task(
  (
    null,-- task_id
    null,-- created_at
    null,-- updated_at
    null,-- created_by
    null,-- updated_by
    1,-- task_priority_id
    1,-- task_category_id
    1,-- contract_id
    null,-- project_id
    'Manutenção no subsolo do Edifício Principal',-- title
    'Troca de eletrodutos e lâmpadas queimadas',-- description
    'Subsolo do Ed. Principal',-- place
    null,-- progress
    '2020-12-31',-- date_limit
    null,-- date_start
    null,-- date_end
    null,-- request_id
    1,-- team_id
    null,-- next_team_id
    null-- task_status_id
  ),
  array[4,5,6],
  null,
);

select api.insert_task_files(
    
);

select api.remove_task_file();

select api.send_task();

set local cookie.session.person_id to 2;

select api.receive_task();

select api.insert_task_message();

select api.move_task();

select api.send_task();

select api.cancel_send_task();

select api.modify_task();

select api.insert_task_asset();

select api.remove_task_asset();

select api.insert_task_supply();

select api.insert_task_supply();

select api.modify_task_supplies();

select api.send_task();

set local cookie.session.person_id to 3;

select api.receive_task();

select api.insert_task_message();

select api.remove_task_message();

select api.insert_task_message();

select api.modify_task_message();
