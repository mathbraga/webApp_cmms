create view api.task_data as
  select t.*,
         tp.task_priority_text,
         tc.task_category_text,
        --  build_contract_json(t.contract_id) as contract,
         a.assets,
        --  s.supplies,
         d.dispatches,
         f.files
    from tasks as t
    inner join task_priorities as tp using (task_priority_id)
    inner join task_categories as tc using (task_category_id)
    -- task dispatches
    -- task status
    -- project json
    inner join assets_of_task as a using (task_id)
    inner join dispatches_of_task as d using (task_id)
    left join supplies_of_task as s using (task_id)
    left join files_of_task as f using (task_id)
;
