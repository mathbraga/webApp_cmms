create index on asset_relations (parent_id);
create index on task_files (task_id);
create index on task_messages (task_id);
create index on task_dispatch_logs (task_id);
create index on task_status_logs (task_id);
-- Ideas for more indexes:
-- table: supplies / column: spec_id
-- table: task_supplies / column: supply_id
-- table: task_assets / column: asset_id
