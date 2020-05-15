create or replace function get_mutation_response (
  in mutation_response_row mutation_response_type,
  out mutation_response jsonb
)
  language sql
  as $$
    select to_jsonb(mutation_response_row) as mutation_response;
  $$
;
