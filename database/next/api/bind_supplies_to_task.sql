drop function if exists api.bind_supplies_to_task;

create or replace function api.bind_supplies_to_task (
  inout id integer,
  in supplies integer[],
  in quantities integer[]
)
  language plpgsql
  as $$
    begin
      insert into task_supplies as ts
        values (
          id,
          unnest(supplies),
          unnest(quantities)
        )
        on conflict on constraint task_supplies_pkey
        do update set (
          qty
        ) = (
          
        );
    end;
  $$
;
