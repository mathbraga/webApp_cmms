create or replace function insert_asset (
  in attributes assets,
  out result integer
)
  language plpgsql
  as $$
    begin
      insert into appliances values (
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
      ) returning asset_id into result;
    end;
  $$
;

create or replace function insert_person (
  in attributes persons,
  in input_person_role text,
  out result integer
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
      ) returning person_id into result;
      
      insert into private.accounts values (
        result,
        crypt('123456', gen_salt('bf', 10)),
        true,
        input_person_role
      );
    end;
  $$
;

create or replace function insert_task (
  in attributes tasks,
  in assets integer[],
  in supplies integer[],
  in qty real[],
  in files_metadata file_metadata[],
  out result integer
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
        current_setting('auth.data.person_Id')::integer,
        default,
        default
      ) returning task_id into result;

      if assets is not null then
        insert into task_assets select result, unnest(assets);
      else
        raise exception 'There must be at least one asset in a task!';
      end if;

      if supplies is not null then
        insert into task_supplies select result, unnest(supplies), unnest(qty);
      end if;

      insert into task_files
        select result,
              f.filename,
              f.uuid,
              f.size,
              current_setting('auth.data.person_id')::integer,
              now()
          from unnest(files_metadata) as f;

    end;
  $$
;

create or replace function insert_team (
  in attributes teams,
  in persons_array integer[],
  out result integer
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
      ) returning team_id into result;

      insert into team_persons select result, unnest(persons_array);

    end;
  $$
;

-- create or replace function insert_contract (
--   in contract_attributes contracts,
--   in supplies_array supplies[]
-- )
-- returns text
-- language plpgsql
-- as $$
-- declare
--   new_contract_id text;
-- begin

--   insert into contracts
--     select (contract_attributes.*)
--     returning contract_id into new_contract_id;

--   insert into supplies
--     select ((unnest(supplies_array)).*);

--   return new_contract_id;

-- end; $$;
