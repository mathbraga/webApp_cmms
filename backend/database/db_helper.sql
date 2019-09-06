CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- bypass de RLS ---> SOMENTE PARA ADMINS!
ALTER ROLE role_name WITH BYPASSRLS;

CREATE ROLE unauth;
CREATE ROLE auth;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO unauth;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO auth;

---- tudo:
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO unauth;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO unauth;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO auth;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO unauth;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO auth;

delete from private.accounts where person_id between 10 and 20;
delete from persons where person_id between 10 and 20;
ALTER SEQUENCE orders_order_id_seq RESTART WITH 10;
ALTER SEQUENCE persons_person_id_seq RESTART WITH 10;

update private.accounts set active = false where person_id = 1;

select register_user(
  'hzlopes@gmail.com',
  'henrique',
  'lopes',
  '234324342',
  'SEPLAG',
  '',
  'E',
  '123456'
);

create or replace function maispessoa () returns integer
LANGUAGE plpgsql AS $$
declare
  result integer;
BEGIN
  INSERT INTO persons VALUES (
    CURRENT_SETTING('auth.data.user_id')::integer + 660,
    'emailexemplo@bol.com.br',
    'nome',
    'surname',
    '432234',
    'SINFRA',
    null,
    'E'
  ) returning person_id into result;
  return result;
END; $$;