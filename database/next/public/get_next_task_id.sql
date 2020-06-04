/*

  This file will be used in case gapless task ids sequence are
  a requirement.

  Implementation inspired by:

  https://stackoverflow.com/questions/9984196/postgresql-gapless-sequences/9985219#9985219

*/
create table task_id_counter (
  last_task_id integer not null
);

insert into task_id_counter values (0);

create or replace function get_next_task_id(
  out next_task_id integer
)
  language plpgsql
  as $$
    begin
      update task_id_counter
        set last_task_id = last_task_id + 1
      returning last_task_id into next_task_id;
    end;
  $$
;
