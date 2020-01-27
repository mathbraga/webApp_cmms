begin;


create table complete_paths (paths text, level int);

/* build all paths based on asset_relations table including 
incomplete paths that still have children to be added */
with recursive path_relations(paths, level) as (
    select a.top_id || '.' || a.parent_id || '.' || a.asset_id, 3
        from asset_relations as a
        where a.parent_id is not null

    union

    select pr.paths || '.' || ar.asset_id, pr.level + 1
        from path_relations as pr
        inner join asset_relations as ar
        on split_part(pr.paths, '.', pr.level) :: int = ar.parent_id
)insert into complete_paths (paths, level) (select paths, level from path_relations);

/* select from each path the last element that have occurences 
on parent_id column from asset_relations table (ids that have children), 
these ids are further used to verify which paths should be removed from 
complete_paths. */
select split_part(cp.paths, '.', cp.level) as remove_ids into ids_of_interest
    from complete_paths as cp
    inner join asset_relations as ar
    on split_part(cp.paths, '.', cp.level) :: int = ar.parent_id
    group by remove_ids;

/* remove from complete_paths any path that has children further on */
delete from complete_paths as cp
    using ids_of_interest
    where split_part(cp.paths, '.', cp.level) = remove_ids;

select * from complete_paths;

rollback;