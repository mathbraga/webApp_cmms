create index on asset_relations (parent_id);
create index on task_files (task_id);
create index on task_events (task_id);
-- create index on task_messages (task_id);
-- Ideas for more indexes:
-- create index on supplies (spec_id);
-- create index on task_supplies (supply_id);
-- create index on task_assets (asset_id);
