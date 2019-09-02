CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE ROLE unauth;
CREATE ROLE auth;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO unauth;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO auth;

delete from private.accounts where person_id between 10 and 20;
delete from persons where person_id between 10 and 20;
ALTER SEQUENCE orders_order_id_seq RESTART WITH 10;
ALTER SEQUENCE persons_person_id_seq RESTART WITH 10;

update private.accounts set active = false where person_id = 1;