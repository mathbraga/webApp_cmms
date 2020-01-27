create table assets (
  asset_id integer primary key generated always as identity,
  asset_sf text not null unique,
  name text not null,
  description text,
  category integer not null references assets (asset_id),
  latitude numeric,
  longitude numeric,
  area numeric,
  manufacturer text,
  serialnum text,
  model text,
  price numeric
);

create table asset_relations (
  top_id integer not null references assets (asset_id),
  parent_id integer references assets (asset_id),
  asset_id integer not null references assets (asset_id)
);

create table contracts (
  contract_id integer primary key generated always as identity,
  contract_sf text not null unique,
  parent integer references contracts (contract_id),
  contract_status_id integer not null references contract_statuses (contract_status_id),
  date_sign date,
  date_pub date,
  date_start date,
  date_end date,
  company text not null,
  title text not null,
  description text not null,
  url text -- just one? many?
);

-- create table departments (
--   department_id integer primary key generated always as identity,
--   department_sf text not null,
--   parent integer references departments (department_id),
--   name text not null,
--   is_active boolean not null
-- );

create table persons (
  person_id integer primary key generated always as identity,
  cpf text not null unique check (cpf ~ '^[0-9]{11}$'),
  email text not null unique check (email ~* '^.+@.+\..+$'),
  name text not null,
  phone text not null,
  cellphone text,
  contract_id integer references contracts (contract_id)
);

create table private.accounts (
  person_id integer not null references persons (person_id),
  password_hash text not null,
  is_active boolean not null default true,
  person_role text not null references person_roles (person_role)
);

create table teams (
  team_id integer primary key generated always as identity,
  name text not null unique,
  description text,
  is_active boolean not null default true
);

create table team_persons (
  team_id integer references teams (team_id),
  person_id integer references persons (person_id),
  primary key (team_id, person_id)
);

create table contract_teams (
  contract_id integer not null references contracts (contract_id),
  team_id integer not null references teams (team_id),
  primary key (contract_id, team_id)
);

create table projects (
  project_id integer primary key generated always as identity,
  name text not null unique,
  description text,
  date_start timestamptz,
  date_end timestamptz,
  is_active boolean not null default true
);

create table tasks (
  task_id integer primary key generated always as identity,
  task_status_id integer not null references task_statuses (task_status_id),
  task_priority_id integer not null references task_priorities (task_priority_id),
  task_category_id integer not null references task_categories (task_category_id),
  project_id integer references projects (project_id),
  contract_id integer references contracts (contract_id),
  team_id integer references teams (team_id),
  title text not null,
  description text not null,
  request_department text,
  request_name text,
  request_phone text,
  request_email text,
  place text,
  progress integer check (progress >= 0 and progress <= 100),
  date_limit timestamptz,
  date_start timestamptz,
  date_end timestamptz,
  person_id integer not null references persons (person_id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table task_messages (
  message_id integer primary key generated always as identity,
  task_id integer not null references tasks (task_id),
  message text not null,
  person_id integer not null references persons (person_id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table task_assets (
  task_id integer not null references tasks (task_id),
  asset_id integer not null references assets (asset_id),
  primary key (task_id, asset_id)
);

-- create table task_teams (
--   task_id integer not null references tasks (task_id),
--   team_id integer not null references teams (team_id),
--   primary key (task_id, team_id)
-- );

-- create table asset_departments (
--   asset_id integer not null references assets (asset_id),
--   department_id integer not null references departments (department_id),
--   primary key (asset_id, department_id)
-- );

create table specs (
  spec_id integer primary key generated always as identity,
  spec_sf text not null, -- regex check
  version text not null, -- regex check
  name text not null,
  spec_category_id integer not null references spec_categories (spec_category_id),
  spec_subcategory_id integer not null references spec_subcategories (spec_subcategory_id),
  unit text not null, -- enum or reference to a table??? --> no
  qty_decimals boolean not null, -- function of unit?
  description text,
  materials text,
  services text,
  activities text,
  qualification text,
  notes text,
  criteria text,
  spreadsheets text, -- improve (link to a table? files? jsonb? xml?)
  lifespan text,
  com_ref text, -- improve (new table is necessary?)
  ext_rer text, -- improve (new table is necessary?)
  is_subcont text, -- change this to boolean data type
  catmat text,
  catser text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (spec_sf, version)--,
);

create table supplies (
  supply_id integer primary key generated always as identity,
  supply_sf text not null,
  contract_id integer not null references contracts (contract_id),
  spec_id integer not null references specs (spec_id),
  qty numeric not null,
  bid_price numeric not null,
  full_price numeric,
  unique (contract_id, supply_sf)
);

create table task_supplies (
  task_id integer not null references tasks (task_id),
  supply_id integer not null references supplies (supply_id),
  qty numeric not null,
  primary key (task_id, supply_id)
);

-- create table rules (
--   rule_id integer primary key generated always as identity,
--   rule_sf text not null unique, -- regex
--   category rule_category_type, -- enum or reference to a table
--   title text,
--   description text,
--   url text
-- );

-- create table asset_rules (
--   asset_id integer not null references assets (asset_id),
--   rule_id integer not null references rules (rule_id),
--   primary key (asset_id, rule_id)
-- );

-- create table spec_rules (
--   spec_id integer not null references specs (spec_id),
--   rule_id integer not null references rules (rule_id),
--   primary key (spec_id, rule_id)
-- );

-- create table templates (
--   template_id integer primary key generated always as identity,
--   name text not null unique,
--   description text not null
-- );

-- create table asset_files (
--   asset_id integer not null references assets (asset_id),
--   name text not null,
--   uuid uuid not null,
--   size bigint not null,
--   person_id integer not null references persons (person_id),
--   created_at timestamptz not null default now()
-- );

create table task_files (
  task_id integer not null references tasks (task_id),
  filename text not null,
  uuid uuid not null,
  size bigint not null,
  person_id integer not null references persons (person_id),
  created_at timestamptz not null default now()
);

-- create table rule_files (
--   rule_id integer not null references rules (rule_id),
--   name text not null,
--   uuid uuid not null,
--   size bigint not null,
--   person_id integer not null references persons (person_id),
--   created_at timestamptz not null default now()
-- );

-- create table template_files (
--   template_id integer not null references templates (template_id),
--   name text not null,
--   uuid uuid not null,
--   size bigint not null,
--   person_id integer not null references persons (person_id),
--   created_at timestamptz not null default now()
-- );

create table private.audit_trails (
  person_id integer not null references persons (person_id),
  created_at timestamptz not null,
  operation text not null,
  tablename text not null,
  old_row jsonb,
  new_row jsonb
);
