create table rlstest (f1 int);
alter table rlstest enable row level security;
insert into rlstest values (1), (2), (3);
create policy unauth_policy on rlstest for select to unauth using (true);
create policy auth_policy on rlstest for all to auth using (true) with check (true);
create policy graphiql on rlstest for all to postgres using (true) with check (true);
alter table rlstest add column tipo text;


create table rlstest2 as 
    select * from rlstest where tipo = 'p';
    


row-level security

0) set all access privileges (grant or revoke commands)
1) enable / disable rls for the table (can be used if a policy exists or not --> does not delete existing policies)
2) create / drop policy (using --> select, update, delete ;  with check --> insert, update)
3) if "for all" ==> 
4) default policy is deny.