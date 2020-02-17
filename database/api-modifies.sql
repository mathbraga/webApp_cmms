create or replace function api.modify_asset (
  in id integer,
  in attributes assets,
  in tops integer[],
  in parents integer[],
  out result integer
)
  language plpgsql
  as $$
    begin
      update assets as a
        set (
          asset_sf,
          name,
          description,
          category,
          latitude,
          longitude,
          area,
          manufacturer,
          serialnum,
          model,
          price
        ) = (
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
        ) where a.asset_id = id
      returning a.asset_id into result;
    
      with added_relations as (
        select unnest(tops) as top_id, unnest(parents) as parent_id
        except
        select ar.top_id, ar.parent_id
          from asset_relations as ar
          where ar.asset_id = id
      )
      insert into asset_relations as ar
        select top_id, parent_id, id from added_relations;
  
      with recursive removed_relations as (
        select ar.top_id, ar.parent_id
          from asset_relations as ar
        where ar.asset_id = id
        except
        select unnest(tops) as top_id, unnest(parents) as parent_id
      )
      delete from asset_relations as ar
        where ar.asset_id = id
              and ar.asset_id in (select asset_id from removed_relations);

    end;
  $$
;

create or replace function api.modify_task (
  in id integer,
  in attributes tasks,
  in assets integer[],
  out result integer
)
  language plpgsql
  strict
  as $$
    begin
      update tasks as t
        set (
          task_status_id,
          task_priority_id,
          task_category_id,
          project_id,
          team_id,
          title,
          description,
          -- todo: request fields
          place,
          progress,
          date_limit,
          date_start,
          updated_at
        ) = (
          attributes.task_status_id,
          attributes.task_priority_id,
          attributes.task_category_id,
          attributes.project_id,
          attributes.team_id,
          attributes.title,
          attributes.description,
          -- todo: request fields
          attributes.place,
          attributes.progress,
          attributes.date_limit,
          attributes.date_start,
          default
        ) where t.task_id = id
        returning t.task_id into result;

      with added_assets as (
        select unnest(assets) as asset_id
        except
        select asset_id
          from task_assets as ta
        where ta.task_id = id
      )
      insert into task_assets
        select id, asset_id from added_assets;

      with recursive removed_assets as (
        select asset_id
          from task_assets as ta
        where ta.task_id = id
        except
        select unnest(assets) as asset_id
      )
      delete from task_assets as ta
        where ta.task_id = id
              and asset_id in (select asset_id from removed_assets);
    end;
  $$
;

-- create or replace function modify_team (
--   in id integer,
--   in attributes teams,
--   in persons_array integer[],
--   out result integer
-- )
-- language plpgsql
-- strict
-- as $$
-- begin
--   update teams as t
--     set (
--       name,
--       description,
--       is_active
--     ) = (
--       attributes.name,
--       attributes.description,
--       attributes.is_active
--     )
--     where t.team_id = id
--     returning t.team_id into result;

--   with added_persons as (
--     select unnest(persons_array) as person_id
--     except
--     select person_id
--       from team_persons as tp
--       where tp.team_id = id
--   )
--   insert into team_persons
--     select id, person_id from added_persons;
  
--   with recursive removed_persons as (
--     select person_id
--       from team_persons as tp
--     where tp.team_id = id
--     except
--     select unnest(persons_array) as person_id
--   )
--   delete from team_persons
--     where team_id = id
--           and person_id in (select person_id from removed_persons);
-- end; $$;

-- create or replace function modify_self (
--   in attributes persons,
--   in new_password text,
--   out result integer
-- )
-- language plpgsql
-- security definer
-- as $$
-- begin
--   update persons as p
--   set (
--     cpf,
--     email,
--     full_name,
--     phone,
--     cellphone
--   ) = (
--     attributes.cpf,
--     attributes.email,
--     attributes.full_name,
--     attributes.phone,
--     attributes.cellphone
--   ) where p.person_id = get_current_person_id()
--   returning ;

--   update private.accounts set (
--     password_hash
--   ) = (
--     crypt(new_password, gen_salt('bf', 10))
--   ) where person_id = get_current_person_id();
-- end; $$;

-- create or replace function modify_person (
--   in id integer,
--   in attributes persons,
--   in new_is_active boolean,
--   in new_person_role text,
--   out result
-- )
-- language plpgsql
-- security definer
-- as $$
-- begin
--   update persons as p
--   set (
--     cpf,
--     email,
--     full_name,
--     phone,
--     cellphone,
--     contract_id
--   ) = (
--     attributes.cpf,
--     attributes.email,
--     attributes.full_name,
--     attributes.phone,
--     attributes.cellphone,
--     attributes.contract_id
--   ) where p.person_id = id
--   returning p.person_id into result;

--   update private.accounts set (
--     password_hash,
--     is_active,
--     person_role
--   ) = (
--     crypt(new_password, gen_salt('bf', 10)),
--     new_is_active,
--     new_person_role
--   ) where person_id = id;
-- end; $$;
