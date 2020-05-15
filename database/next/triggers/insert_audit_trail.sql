create or replace function insert_audit_trail ()
  returns trigger
  language plpgsql
  security definer
  as $$
    begin
      insert into private.audit_trails values (
        default,
        now(),
        tg_op::text,
        tg_table_name::text,
        to_jsonb(old),
        to_jsonb(new)
      );
      return null; -- result is ignored since this is an after trigger
    end;
  $$
;
