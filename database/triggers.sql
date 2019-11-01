create trigger log_changes
  after insert or update or delete on orders
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on order_messages
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on order_assets
  for each row execute function create_log();

create trigger log_changes
  after insert or update or delete on order_supplies
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
  before insert or update on orders
  for each row execute function check_conclusion();

create trigger check_supply_qty
  before insert or update on order_supplies
  for each row execute function check_supply_qty();
