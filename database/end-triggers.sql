-- audit trails
create trigger insert_audit_trail
  after insert or update or delete on assets
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on asset_relations
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on contracts
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on persons
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on private.accounts
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on teams
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on team_persons
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on contract_teams
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on projects
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on tasks
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on task_messages
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on task_assets
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on specs
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on supplies
  for each row execute procedure insert_audit_trail();

create trigger insert_audit_trail
  after insert or update or delete on task_files
  for each row execute procedure insert_audit_trail();

-- check asset category
create trigger check_asset_category
  before insert or update on assets
  for each row execute procedure check_asset_category();

-- check asset relation
create trigger check_asset_relation
  before insert or update on asset_relations
  for each row execute procedure check_asset_relation();

-- check task supply
create trigger check_task_supply
  before insert or update on task_supplies
  for each row execute procedure check_task_supply();

-- check task conclusion
-- create trigger check_conclusion
--   before insert or update on tasks
--   for each row execute procedure check_conclusion();
