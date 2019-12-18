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

-- views

-- functions
comment on function authenticate is E'@omit execute';

-- constraints
comment on constraint persons_cpf_key on persons is E'@omit';
comment on constraint persons_email_key on persons is E'@omit';
comment on constraint teams_name_key on teams is E'@omit';
comment on constraint team_persons_pkey on team_persons is E'@omit';
comment on constraint task_messages_pkey on task_messages is E'@omit';
comment on constraint task_assets_pkey on task_assets is E'@omit';
comment on constraint specs_spec_sf_version_key on specs is E'@omit';
comment on constraint supplies_contract_id_supply_sf_key on supplies is E'@omit';
comment on constraint task_supplies_pkey on task_supplies is E'@omit';
