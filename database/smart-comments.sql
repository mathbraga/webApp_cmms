-- lookup tables
-- comment on table asset_categories is null;
-- comment on table contract_statuses is null;
-- comment on table order_statuses is null;
-- comment on table order_priorities is null;
-- comment on table order_categories is null;
-- comment on table person_roles is null;
-- comment on table spec_categories is null;
-- comment on table spec_subcategories is null;
-- comment on table rule_categories is null;

-- tables
comment on table assets is null;
comment on table asset_relations is null;
comment on table contracts is null;
-- comment on table departments is null;
comment on table persons is null;
comment on table teams is null;
comment on table team_persons is null;
comment on table contract_teams is null;
comment on table orders is null;
comment on table order_messages is null;
comment on table order_assets is null;
comment on table order_teams is null;
-- comment on table asset_departments is null;
comment on table specs is null;
comment on table supplies is null;
comment on table order_supplies is null;
comment on table rules is E'@omit all,many,read';
comment on table asset_rules is E'@omit all,many,read';
comment on table spec_rules is E'@omit all,many,read';
comment on table templates is E'@omit all,many,read';
comment on table asset_files is E'@omit all,many,read';
comment on table order_files is E'@omit all,many,read';
comment on table rule_files is E'@omit all,many,read';
comment on table template_files is E'@omit all,many,read';

-- functions
comment on function authenticate is E'@omit execute';

-- constraints
comment on constraint assets_pkey on assets is null;
comment on constraint assets_asset_sf_key on assets is null;
comment on constraint asset_relations_pkey on asset_relations is E'@omit';
comment on constraint asset_rules_pkey on asset_rules is E'@omit';
comment on constraint contracts_pkey on contracts is null;
-- comment on constraint contracts_contract_sf on contracts is null;
-- comment on constraint departments_pkey on departments is E'@omit';
comment on constraint persons_pkey on persons is null;
comment on constraint persons_cpf_key on persons is E'@omit';
comment on constraint persons_email_key on persons is E'@omit';
comment on constraint teams_pkey on teams is null;
comment on constraint teams_name_key on teams is E'@omit';
comment on constraint team_persons_pkey on team_persons is E'@omit';
comment on constraint contract_teams_pkey on contract_teams is E'@omit';
comment on constraint orders_pkey on orders is null;
comment on constraint order_messages_pkey on order_messages is E'@omit';
comment on constraint order_assets_pkey on order_assets is E'@omit';
comment on constraint order_teams_pkey on order_teams is E'@omit';
-- comment on constraint asset_departments_pkey on asset_departments is E'@omit';
comment on constraint specs_pkey on specs is null;
comment on constraint specs_spec_sf_version_key on specs is E'@omit';
comment on constraint supplies_pkey on supplies is null;
comment on constraint supplies_contract_id_supply_sf_key on supplies is E'@omit';
comment on constraint order_supplies_pkey on order_supplies is E'@omit';
comment on constraint rules_pkey on rules is null;
comment on constraint asset_rules_pkey on asset_rules is E'@omit';
comment on constraint spec_rules_pkey on spec_rules is E'@omit';
comment on constraint templates_pkey on templates is null;
