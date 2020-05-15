alter sequence assets_asset_id_seq restart with 10001;
alter sequence contracts_contract_id_seq restart with 10001;
alter sequence persons_person_id_seq restart with 10001;
alter sequence teams_team_id_seq restart with 10001;
alter sequence tasks_task_id_seq restart with 10001;
alter sequence task_messages_message_id_seq restart with 10001;
alter sequence specs_spec_id_seq restart with 10001;
alter sequence supplies_supply_id_seq restart with 10001;

-- EXAMPLE OF SEQUENCE DECREMENT CODE:
-- select setval('assets_asset_id_seq', (select last_value - 1 from assets_asset_id_seq));
