begin;

create table teams (
  team_id integer primary key generated always as identity,
  team_name text not null,
  contract_id text references contracts (contract_id)
);

create table team_persons (
  team_id integer references teams (team_id),
  person_id integer references persons (person_id),
  primary key (team_id, person_id)
);

-- modify orders table (add team_id column instead of contract_id)

rollback;