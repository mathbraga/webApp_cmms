-- lookup tables
comment on table asset_categories is E'@omit';
comment on table contract_statuses is E'@omit';
comment on table task_statuses is E'@omit';
comment on table task_priorities is E'@omit';
comment on table task_categories is E'@omit';
comment on table person_roles is E'@omit';
comment on table spec_categories is E'@omit';
comment on table spec_subcategories is E'@omit';

-- tables
comment on table assets is E'@omit';
comment on table asset_relations is E'@omit';
comment on table contracts is E'@omit';
comment on table contract_teams is E'@omit';
comment on table persons is E'@omit';
comment on table projects is E'@omit';
comment on table specs is E'@omit';
comment on table supplies is E'@omit';
comment on table tasks is E'@omit';
comment on table task_assets is E'@omit';
comment on table task_messages is E'@omit';
comment on table task_supplies is E'@omit';
comment on table task_files is E'@omit';
comment on table team_persons is E'@omit';
comment on table teams is E'@omit';

-- views
comment on view supplies_list is E'@omit';
comment on view assets_of_task is E'@omit';
comment on view supplies_of_task is E'@omit';
comment on view files_of_task is E'@omit';

-- functions
comment on function authenticate is E'@omit execute';

-- constraints
comment on constraint assets_pkey on assets is E'@omit';
comment on constraint assets_asset_sf_key on assets is E'@omit';
comment on constraint contracts_pkey on contracts is E'@omit';
comment on constraint contracts_contract_sf_key on contracts is E'@omit';
comment on constraint persons_cpf_key on persons is E'@omit';
comment on constraint persons_email_key on persons is E'@omit';
comment on constraint projects_pkey on projects is E'@omit';
comment on constraint projects_name_key on projects is E'@omit';
comment on constraint teams_name_key on teams is E'@omit';
comment on constraint team_persons_pkey on team_persons is E'@omit';
comment on constraint task_messages_pkey on task_messages is E'@omit';
comment on constraint task_assets_pkey on task_assets is E'@omit';
comment on constraint specs_spec_sf_version_key on specs is E'@omit';
comment on constraint supplies_contract_id_supply_sf_key on supplies is E'@omit';
comment on constraint task_supplies_pkey on task_supplies is E'@omit';
