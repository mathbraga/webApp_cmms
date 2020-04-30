create or replace function api.insert_task (
  in attributes tasks,
  in assets integer[],
  in supplies integer[],
  in qty numeric[],
  in files_metadata file_metadata[],
  out id integer
)
  language plpgsql
  as $$
    begin
      insert into tasks values (
        default,
        -- attributes.task_status_id,
        attributes.task_priority_id,
        attributes.task_category_id,
        attributes.project_id,
        -- attributes.contract_id,
        -- attributes.team_id,
        attributes.title,
        attributes.description,
        attributes.request_department,
        attributes.request_name,
        attributes.request_phone,
        attributes.request_email,
        attributes.place,
        attributes.progress,
        attributes.date_limit,
        attributes.date_start,
        attributes.date_end
        -- default,
        -- default,
        -- default
      ) returning task_id into id;

      if assets is not null then
        insert into task_assets select id, unnest(assets);
      else
        raise exception '%', get_exception_message(1);
      end if;

      insert into task_files
        select id,
              f.filename,
              f.uuid,
              f.size,
              get_current_person_id(),
              now()
          from unnest(files_metadata) as f;

      insert into task_dispatches values (
        id,
        get_current_person_id(),
        null,
        current_team, -- ????
        null,
        now(),
        'Criação da tarefa.'
      );

      insert into task_status values (
        id,
        now(),
        get_current_person_id(),
        1, -- ????
        'Status inicial.'
      );

    end;
  $$
;
