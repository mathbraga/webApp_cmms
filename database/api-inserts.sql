create or replace function api.insert_asset (
  in attributes assets,
  in tops integer[],
  in parents integer[],
  out id integer
)
  language plpgsql
  as $$
    begin

      insert into assets values (
        default,
        attributes.asset_sf,
        attributes.name,
        attributes.description,
        attributes.category,
        attributes.latitude,
        attributes.longitude,
        attributes.area,
        attributes.manufacturer,
        attributes.serialnum,
        attributes.model,
        attributes.price
      ) returning asset_id into id;

      insert into asset_relations values (
        unnest(tops),
        unnest(parents),
        id
      );

      -- insert into asset_files
      --   select id,
      --          f.filename,
      --          f.uuid,
      --          f.size,
      --          default,
      --          now()
      --     from unnest(files_metadata) as f;

    end;
  $$
;

create or replace function api.insert_person (
  in attributes persons,
  in input_person_role text,
  out id integer
)
  language plpgsql
  strict
  security definer
  as $$
    begin
      insert into persons values (
        default,
        attributes.cpf,
        attributes.email,
        attributes.name,
        attributes.phone,
        attributes.cellphone,
        attributes.contract_id
      ) returning person_id into id;
      
      insert into private.accounts values (
        id,
        crypt('123456', gen_salt('bf', 10)),
        true,
        input_person_role
      );
    end;
  $$
;

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
        attributes.task_status_id,
        attributes.task_priority_id,
        attributes.task_category_id,
        attributes.project_id,
        attributes.contract_id,
        attributes.team_id,
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
        attributes.date_end,
        default,
        default,
        default
      ) returning task_id into id;

      if assets is not null then
        insert into task_assets select id, unnest(assets);
      else
        raise exception '%', get_exception_message(1);
      end if;

      -- if supplies is not null then
      --   insert into task_supplies select id, unnest(supplies), unnest(qty);
      -- end if;

      insert into task_files
        select id,
              f.filename,
              f.uuid,
              f.size,
              default,
              now()
          from unnest(files_metadata) as f;

    end;
  $$
;

create or replace function api.insert_team (
  in attributes teams,
  in persons_array integer[],
  out id integer
)
  language plpgsql
  strict
  as $$
    begin

      insert into teams values (
        default,
        attributes.name,
        attributes.description,
        true
      ) returning team_id into id;

      insert into team_persons select id, unnest(persons_array);

    end;
  $$
;
