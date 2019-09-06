CREATE TABLE rlstest (f1 int);
ALTER TABLE rlstest ENABLE ROW LEVEL SECURITY;
INSERT INTO rlstest VALUES (1), (2), (3);
CREATE POLICY unauth_policy ON rlstest FOR SELECT TO unauth USING (true);
CREATE POLICY auth_policy ON rlstest FOR ALL TO auth USING (true) WITH CHECK (true);
CREATE POLICY graphiql ON rlstest FOR ALL TO postgres USING (true) WITH CHECK (true);
ALTER TABLE rlstest ADD COLUMN tipo text;


create table rlstest2 as 
    select * from rlstest where tipo = 'P';
    


ROW-LEVEL SECURITY

0) Set all access privileges (grant or revoke commands)
1) Enable / disable RLS for the table (can be used if a policy exists or not --> does not delete existing policies)
2) Create / drop policy (USING --> select, update, delete ;  WITH CHECK --> insert, update)
3) If "FOR ALL" ==> 
4) default policy is deny.