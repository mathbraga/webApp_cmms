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
  null
);

select api.insert_task_files(
  1,
  array[
    (
      'texto.txt',
      'de741848-5e90-4c5e-8699-78aca9b37aba',
      1234
    )::file_metadata,
    (
      'texto.txt',
      'ee841848-5e90-4c5e-8699-78aca9b37aba',
      4321
    )::file_metadata
  ]
);

select api.remove_task_file(
  1,
  'ee841848-5e90-4c5e-8699-78aca9b37aba'
);

select api.send_task(
  (
    null,
    1,-- task_id
    null,-- event_name
    null,-- event_time
    null,-- person_id
    1,-- team_id
    2,-- next_team_id
    null,-- task_status_id
    'Para verificação.',-- note
    null,
    null,
    null
  )
);

set local cookie.session.person_id to 2;

select api.receive_task(
  (
    null,
    1,-- task_id
    null,-- event_name
    null,-- event_time
    null,-- person_id
    2,-- team_id
    null,-- next_team_id
    2,-- task_status_id
    null,-- note
    null,
    null,
    null
  )
);

select api.insert_task_note(
  (
    null,
    1,-- task_id
    null,-- event_name
    null,-- event_time
    null,-- person_id
    2,-- team_id
    null,-- next_team_id
    null,-- task_status_id
    'Verificação será comandada por Machado de Assis.',-- note
    null,
    null,
    null
  )
);

select api.move_task(
  (
    null,
    1,-- task_id
    null,-- event_name
    null,-- event_time
    null,-- person_id
    2,-- team_id
    null,-- next_team_id
    3,-- task_status_id
    'Verificação foi concluída com sucesso.',-- note
    null,
    null,
    null
  )
);

select api.send_task(
  (
    null,
    1,-- task_id
    null,-- event_name
    null,-- event_time
    null,-- person_id
    2,-- team_id
    3,-- next_team_id
    null,-- task_status_id
    'Após verificação.',-- note
    null,
    null,
    null
  )
);

select api.cancel_send_task(
  (
    null,
    1,-- task_id
    null,-- event_name
    null,-- event_time
    null,-- person_id
    2,-- team_id
    null,-- next_team_id
    null,-- task_status_id
    null,-- note
    null,
    null,
    null
  )
);

select api.modify_task(
  (
    1,-- task_id
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
    'Subsolo do Edifício Principal',-- place
    null,-- progress
    '2020-12-31',-- date_limit
    '2020-12-01',-- date_start
    null,-- date_end
    null,-- request_id
    null,-- team_id
    null,-- next_team_id
    null-- task_status_id
  ),
  null,-- assets
  null-- files_metadata
);

select api.insert_task_asset(
  1,-- task_id
  7-- asset_id
);

select api.remove_task_asset(
  1,-- task_id
  6-- asset_id
);

select api.insert_task_supply(
  1,-- task_id
  1,-- supply_id
  1-- qty
);

select api.insert_task_supply(
  1,-- task_id
  2,-- supply_id
  1-- qty
);

select api.modify_task_supplies(
  1,-- task_id
  array[
    (
      null,-- task_id
      2,-- supply_id
      2-- qty
    )::task_supplies
  ]
);

select api.send_task(
  (
    null,
    1,-- task_id
    null,-- event_name
    null,-- event_time
    null,-- person_id
    2,-- team_id
    3,-- next_team_id
    null,-- task_status_id
    'Após definição dos suprimentos.',-- note
    null,
    null,
    null
  )
);

set local cookie.session.person_id to 3;

select api.receive_task(
  (
    null,
    1,-- task_id
    null,-- event_name
    null,-- event_time
    null,-- person_id
    3,-- team_id
    null,-- next_team_id
    4,-- task_status_id
    null,-- note
    null,
    null,
    null
  )
);

select api.insert_task_note(
  (
    null,
    1,-- task_id
    null,-- event_name
    null,-- event_time
    null,-- person_id
    3,-- team_id
    null,-- next_team_id
    null,-- task_status_id
    'Aguardando chegada de material.',-- note
    null,
    null,
    null
  )
);

select api.remove_task_note(
  2
);

select api.insert_task_note(
  (
    null,
    1,-- task_id
    null,-- event_name
    null,-- event_time
    null,-- person_id
    3,-- team_id
    null,-- next_team_id
    null,-- task_status_id
    'Aguardando a chegada de material.',-- note
    null,
    null,
    null
  )
);

select api.modify_task_note(
  (
    null,
    1,-- task_id
    null,-- event_name
    null,-- event_time
    null,-- person_id
    3,-- team_id
    null,-- next_team_id
    null,-- task_status_id
    'Aguardando chegada dos materiais.',-- note
    null,
    null,
    null
  )
);
