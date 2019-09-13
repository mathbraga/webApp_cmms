drop table if exists private.logs;
drop trigger if exists log_changes on assets;
drop trigger if exists log_changes on orders;
-----------------------------------------------------------------
CREATE TABLE private.logs (
  person_id         integer      NOT NULL,
  stamp             timestamp    NOT NULL,
  operation         text         NOT NULL,
  tablename         text         NOT NULL,
  old_row           text,
  new_row           text
);
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_logs ()
RETURNS TRIGGER AS $$
BEGIN

  INSERT INTO private.logs VALUES (
    current_setting('auth.data.person_id')::integer,
    now(),
    TG_OP,
    TG_TABLE_NAME::text,
    OLD::text,
    NEW::text
  );

  RETURN NULL; -- result is ignored since this is an AFTER trigger

END;
$$
SECURITY DEFINER
LANGUAGE plpgsql;
-----------------------------------------------------------------
CREATE TRIGGER log_changes
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW EXECUTE FUNCTION create_logs();
-----------------------------------------------------------------
CREATE TRIGGER log_changes
AFTER INSERT OR UPDATE OR DELETE ON orders_messages
FOR EACH ROW EXECUTE FUNCTION create_logs();
-----------------------------------------------------------------
CREATE TRIGGER log_changes
AFTER INSERT OR UPDATE OR DELETE ON orders_assets
FOR EACH ROW EXECUTE FUNCTION create_logs();
-----------------------------------------------------------------
CREATE TRIGGER log_changes
AFTER INSERT OR UPDATE OR DELETE ON assets
FOR EACH ROW EXECUTE FUNCTION create_logs();
-----------------------------------------------------------------
CREATE TRIGGER log_changes
AFTER INSERT OR UPDATE OR DELETE ON assets_departments;
FOR EACH ROW EXECUTE FUNCTION create_logs();
-----------------------------------------------------------------
CREATE TRIGGER log_changes
AFTER INSERT OR UPDATE OR DELETE ON contracts
FOR EACH ROW EXECUTE FUNCTION create_logs();
-----------------------------------------------------------------
CREATE TRIGGER log_changes
AFTER INSERT OR UPDATE OR DELETE ON departments
FOR EACH ROW EXECUTE FUNCTION create_logs();
-----------------------------------------------------------------
CREATE TRIGGER log_changes
AFTER INSERT OR UPDATE OR DELETE ON persons
FOR EACH ROW EXECUTE FUNCTION create_logs();
-----------------------------------------------------------------
CREATE TRIGGER log_changes
AFTER INSERT OR UPDATE OR DELETE ON private.accounts
FOR EACH ROW EXECUTE FUNCTION create_logs();
-----------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
delete from assets where category is null;
commit;