create view dispatches_of_task as
  with
    cte as (
      select td.task_id,
             p.name,
             tt.name as sent_by,
             ttt.name as sent_to,
             td.sent_at,
             td.received_at,
             td.note
        from task_dispatches as td
        inner join persons as p using (person_id)
        inner join teams as tt using (sent_by)
        inner join teams as ttt using (sent_to)
      order by td.sent_at
    )
  select cte.task_id,
         jsonb_agg(jsonb_build_object(
          'name', cte.name,
          'sentBy', cte.name,
          'sentTo', cte.name,
          'sentAt', cte.sent_at,
          'receivedAt', cte.received_at,
          'note', cte.note
         )) as dispatches
    from cte as cte
  group by cte.task_id
;
