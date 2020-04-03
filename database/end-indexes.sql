/*
CREATE [ UNIQUE ] INDEX [ CONCURRENTLY ] [ [ IF NOT EXISTS ] name ] ON [ ONLY ] table_name [ USING method ]
    ( { column_name | ( expression ) } [ COLLATE collation ] [ opclass ] [ ASC | DESC ] [ NULLS { FIRST | LAST } ] [, ...] )
    [ INCLUDE ( column_name [, ...] ) ]
    [ WITH ( storage_parameter = value [, ... ] ) ]
    [ TABLESPACE tablespace_name ]
    [ WHERE predicate ]
*/

-- CONSIDER NEW INDEXES IN THE FOLLOWING TABLES AND COLUMNS:
-- table: task_files / column: task_id (not unique)
-- table: assets / column: category
-- table: asset_relations / column: parent_id? all?
-- table: private.accounts / column: person_id
-- table: supplies / column: spec_id
-- table: specs / column: spec_category_id
-- table: task_supplies / column: supply_id


