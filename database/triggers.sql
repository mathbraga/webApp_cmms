create trigger log_changes
  after insert or update or delete on tasks
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on task_messages
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on task_assets
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on task_supplies
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on assets
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on asset_departments
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on contracts
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on supplies
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on departments
  for each row execute function create_log();

create trigger check_conclusion
  before insert or update on tasks
  for each row execute function check_conclusion();

create trigger check_new_row
  before insert or update on task_supplies
  for each row execute function check_task_supply();
