drop table if exists private.cmms_db_logs;
drop trigger if exists assets_log on assets;
drop trigger if exists orders_log on orders;
-----------------------------------------------------------------
CREATE TABLE private.cmms_db_logs (
  person_id         integer      NOT NULL,
  stamp             timestamp    NOT NULL,
  operation         char(1)      NOT NULL,
  asset_row         assets,
  order_row         orders
);
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION process_cmms_db_logs()
RETURNS TRIGGER AS $$
DECLARE
 tablename text;
BEGIN
  
  tablename = TG_TABLE_NAME;

  IF (tablename = 'assets') THEN
    IF (TG_OP = 'DELETE') THEN
      INSERT INTO private.cmms_db_logs VALUES (current_setting('auth.data.person_id')::integer, now(), 'D', OLD, null);
    ELSIF (TG_OP = 'UPDATE') THEN
      INSERT INTO private.cmms_db_logs VALUES (current_setting('auth.data.person_id')::integer, now(), 'U', NEW, null);
    ELSIF (TG_OP = 'INSERT') THEN
      INSERT INTO private.cmms_db_logs VALUES (current_setting('auth.data.person_id')::integer, now(), 'I', NEW, null);
    END IF;

  ELSIF (tablename = 'orders') THEN
    IF (TG_OP = 'DELETE') THEN
      INSERT INTO private.cmms_db_logs VALUES (current_setting('auth.data.person_id')::integer, now(), 'D', null, OLD);
    ELSIF (TG_OP = 'UPDATE') THEN
      INSERT INTO private.cmms_db_logs VALUES (current_setting('auth.data.person_id')::integer, now(), 'U', null, NEW);
    ELSIF (TG_OP = 'INSERT') THEN
      INSERT INTO private.cmms_db_logs VALUES (current_setting('auth.data.person_id')::integer, now(), 'I', null, NEW);
    END IF;
  END IF;

RETURN NULL; -- result is ignored since this is an AFTER trigger
END;
$$
LANGUAGE plpgsql;
-----------------------------------------------------------------
CREATE TRIGGER assets_log
AFTER INSERT OR UPDATE OR DELETE ON assets
FOR EACH ROW EXECUTE FUNCTION process_cmms_db_logs();

CREATE TRIGGER orders_log
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW EXECUTE FUNCTION process_cmms_db_logs();


begin;
set local auth.data.person_id to 1;
insert into assets values ('ZZZ', 'CASF-000-000', 'c', 'd', 'F', null, null, null, null, null, null, null, null, null);
commit;