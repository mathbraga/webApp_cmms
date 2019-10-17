create table supplies (
  contract_id text not null references contracts (contract_id),
  supply_id text not null,
  spec_id text not null references specs (spec_id),
  qty_initial real not null,
  is_qty_real boolean not null,
  unit text not null,
  bid_price money not null,
  full_price money,
  primary key (contract_id, supply_id)
);