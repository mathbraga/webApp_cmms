create or replace function api.modify_asset (
  in attributes assets,
  out result integer
)
  language plpgsql
  as $$
    begin
      update assets as a
        set (
          title,
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
          attributes.title,
          attributes.description,
          attributes.category,
          attributes.latitude,
          attributes.longitude,
          attributes.area,
          attributes.manufacturer,
          attributes.serialnum,
          attributes.model,
          attributes.price
        ) where a.asset_id = asset_attributes.asset_id
      returning a.asset_id into result;
    
      with added_relations as (
        select unnest(tops) as top_id, unnest(parents) as parent_id
        except
        select ar.top_id, ar.parent_id
          from asset_relations as ar
          where ar.asset_id = attributes.asset_id
      )
      insert into asset_relations as ar
        select top_id, parent_id, attributes.asset_id from added_relations;
  
      with recursive removed_relations as (
        select ar.top_id, ar.parent_id
          from asset_relations as ar
        where ar.asset_id = attributes.asset_id
        except
        select unnest(tops) as top_id, unnest(parents) as parent_id
      )
      delete from asset_relations as ar
        where ar.asset_id = attributes.asset_id
              and ar.asset_id in (select asset_id from removed_assets);

    end;
  $$
;

-- create or replace function modify_task (
--   in attributes tasks,
--   in assets_array text[],
--   out result integer
-- )
-- language plpgsql
-- strict
-- as $$
-- begin
--   update tasks as t
--     set (
--       status,
--       priority,
--       category,
--       parent,
--       team_id,
--       progress,
--       title,
--       description,
--       origin_department,
--       origin_person,
--       contact_name,
--       contact_phone,
--       contact_email,
--       place,
--       date_limit,
--       date_start,
--       updated_at
--     ) = (
--       attributes.status,
--       attributes.priority,
--       attributes.category,
--       attributes.parent,
--       attributes.team_id,
--       attributes.progress,
--       attributes.title,
--       attributes.description,
--       attributes.origin_department,
--       attributes.origin_person,
--       attributes.contact_name,
--       attributes.contact_phone,
--       attributes.contact_email,
--       attributes.place,
--       attributes.date_limit,
--       attributes.date_start,
--       default
--     ) where o.task_id = task_attributes.task_id
--     returning o.task_id into result;

--   with added_assets as (
--     select unnest(assets_array) as asset_id
--     except
--     select asset_id
--       from task_assets as ta
--       where ta.task_id = attributes.task_id
--   )
--   insert into task_assets
--     select task_attributes.task_id, asset_id from added_assets;
  
--   with recursive removed_assets as (
--     select asset_id
--       from task_assets as ta
--     where ta.task_id = attributes.task_id
--     except
--     select unnest(assets_array) as asset_id
--   )
--   delete from task_assets as ta
--     where ta.task_id = attributes.task_id
--           and asset_id in (select asset_id from removed_assets);
-- end; $$;

-- create or replace function modify_team (
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
--     where t.team_id = attributes.team_id
--     returning t.team_id into result;

--   with added_persons as (
--     select unnest(persons_array) as person_id
--     except
--     select person_id
--       from team_persons as tp
--       where tp.team_id = attributes.team_id
--   )
--   insert into team_persons
--     select attributes.team_id, person_id from added_persons;
  
--   with recursive removed_persons as (
--     select person_id
--       from team_persons as tp
--     where tp.team_id = attributes.team_id
--     except
--     select unnest(persons_array) as person_id
--   )
--   delete from team_persons
--     where team_id = team_attributes.team_id
--           and person_id in (select person_id from removed_persons);
-- end; $$;

-- create or replace function modify_profile (
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
--   ) where p.person_id = current_setting('auth.data.person_id')::integer
--   returning ;

--   update private.accounts set (
--     password_hash
--   ) = (
--     crypt(new_password, gen_salt('bf', 10))
--   ) where person_id = current_setting('auth.data.person_id')::integer;
-- end; $$;

-- create or replace function modify_person (
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
--   ) where p.person_id = attributes.person_id
--   returning p.person_id into result;

--   update private.accounts set (
--     password_hash,
--     is_active,
--     person_role
--   ) = (
--     crypt(new_password, gen_salt('bf', 10)),
--     new_is_active,
--     new_person_role
--   ) where person_id = attributes.person_id;
-- end; $$;
