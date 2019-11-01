create table assets (
  asset_id integer primary key generated always as identity,
  asset_sf text not null unique,
  name text not null,
  description text,
  category asset_category_type not null, -- enum or reference to a table
  latitude real,
  longitude real,
  area real,
  manufacturer text,
  serialnum text,
  model text,
  price money
);

create table asset_relations (
  top_id integer not null references assets (asset_id), -- enum or reference to a table
  parent_id integer not null references assets (asset_id),
  asset_id integer not null references assets (asset_id),
  primary key (top_id, parent_id, asset_id)
);

create table contracts (
  contract_id integer primary key generated always as identity,
  contract_sf text not null unique,
  parent integer references contracts (contract_id),
  status contract_status_type not null, -- enum or reference to a table
  date_sign date,
  date_pub date,
  date_start date,
  date_end date,
  company text not null,
  title text not null,
  description text not null,
  url text not null -- just one? many?
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
  person_role person_role_type not null
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

create table orders (
  order_id integer primary key generated always as identity,
  status order_status_type not null,
  priority order_priority_type not null,
  category order_category_type not null,
  parent integer references orders (order_id),
  contract_id integer references contracts (contract_id),
  title text not null,
  description text not null,
  department_id text not null, -- references departments (department_id),
  created_by text not null,
  contact_name text not null,
  contact_phone text not null,
  contact_email text not null,
  place text,
  progress integer check (progress >= 0 and progress <= 100),
  date_limit timestamptz,
  date_start timestamptz,
  date_end timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table order_messages (
  message_id integer primary key generated always as identity,
  order_id integer not null references orders (order_id),
  person_id integer not null references persons (person_id),
  message text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table order_assets (
  order_id integer not null references orders (order_id),
  asset_id integer not null references assets (asset_id),
  primary key (order_id, asset_id)
);

create table order_teams (
  order_id integer not null references orders (order_id),
  team_id integer not null references teams (team_id),
  primary key (order_id, team_id)
);

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
  category text not null, -- enum or reference to a table
  subcategory text not null, -- enum or reference to a table
  unit text not null, -- enum or reference to a table??? --> no
  allow_decimals boolean not null, -- function of unit?
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
  unique (spec_sf, version)
);

create table supplies (
  supply_id integer primary key generated always as identity,
  supply_sf text not null,
  contract_id integer not null references contracts (contract_id),
  spec_id integer not null references specs (spec_id),
  qty real not null,
  bid_price money not null,
  full_price money,
  unique (contract_id, supply_sf)
);

create table order_supplies (
  order_id integer not null references orders (order_id),
  supply_id integer not null references supplies (supply_id),
  qty real not null,
  primary key (order_id, supply_id)
);

create table rules (
  rule_id integer primary key generated always as identity,
  rule_sf text not null unique, -- regex
  category rule_category_type, -- enum or reference to a table
  title text,
  description text,
  url text
);

create table asset_rules (
  asset_id integer not null references assets (asset_id),
  rule_id integer not null references rules (rule_id),
  primary key (asset_id, rule_id)
);

create table spec_rules (
  spec_id integer not null references specs (spec_id),
  rule_id integer not null references rules (rule_id),
  primary key (spec_id, rule_id)
);

create table templates (
  template_id integer primary key generated always as identity,
  name text not null unique,
  description text not null
);

create table asset_files (
  asset_id integer not null references assets (asset_id),
  name text not null,
  uuid text not null,
  bytes bigint not null,
  person_id integer not null references persons (person_id),
  created_at timestamptz not null default now()
);

create table order_files (
  order_id integer not null references orders (order_id),
  name text not null,
  uuid text not null,
  bytes bigint not null,
  person_id integer not null references persons (person_id),
  created_at timestamptz not null default now()
);

create table rule_files (
  rule_id integer not null references rules (rule_id),
  name text not null,
  uuid text not null,
  bytes bigint not null,
  person_id integer not null references persons (person_id),
  created_at timestamptz not null default now()
);

create table template_files (
  template_id integer not null references templates (template_id),
  name text not null,
  uuid text not null,
  bytes bigint not null,
  person_id integer not null references persons (person_id),
  created_at timestamptz not null default now()
);

create table private.logs (
  person_id integer not null references persons (person_id),
  created_at timestamptz not null,
  operation text not null,
  tablename text not null,
  old_row jsonb,
  new_row jsonb
);