alter table task_messages enable row level security;

create policy x on task_messages
  as permissive
  for select
  to public
  using (true)
;

create policy y on task_messages
  as permissive
  for update
  to public
  using (person_id = get_person_id())
;
