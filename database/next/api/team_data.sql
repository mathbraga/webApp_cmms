create or replace view api.team_data as
  select t.team_id, 
         t.name,
         t.description,
         count(*) as member_count,
         jsonb_agg(jsonb_build_object(
           'personId', p.person_id,
           'name', p.name
         )) as members
    from teams as t
    inner join team_persons as tp using (team_id)
    inner join persons as p using (person_id)
  where t.is_active
  group by t.team_id
;
