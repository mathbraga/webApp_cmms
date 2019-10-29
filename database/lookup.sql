-- asset categories
create table asset_categories (
  asset_category_id integer primary key,
  asset_category_text text not null
);

insert into asset_categories values
  (1, 'Equipamentos'),
  (2, 'Edifícios');

comment on table asset_categories is E'@omit create,update,delete';

-- contract statuses
create table contract_statuses (
  contract_status_id integer primary key,
  contract_status_text text not null
);

insert into contract_statuses values
  (1, 'Em licitação'),
  (2, 'Vigente'),
  (3, 'Encerrado');

comment on table contract_statuses is E'@omit create,update,delete';

-- order statuses
create table order_statuses (
  order_status_id integer primary key,
  order_status_text text not null
);

insert into order_statuses values
  (1, 'Cancelada'),
  (2, 'Negada'),
  (3, 'Pendente'),
  (4, 'Suspensa'),
  (5, 'Fila de espera'),
  (6, 'Em execução'),
  (7, 'Concluída');

comment on table order_statuses is E'@omit create,update,delete';

-- order priorities
create table order_priorities (
  order_priority_id integer primary key,
  order_priority_text text not null
);

insert into order_priorities values
  (1, 'Baixa'),
  (2, 'Normal'),
  (3, 'Alta'),
  (4, 'Urgente');

comment on table order_priorities is E'@omit create,update,delete';

-- order categories
create table order_categories (
  order_category_id integer primary key,
  order_category_text text not null
);

insert into order_categories values
  (1, 'Ar-condicionado'),
  (2, 'Elétrica'),
  (3, 'Elevador'),
  (4, 'Avaliação Estrutural'),
  (5, 'Exaustor'),
  (6, 'Forro'),
  (7, 'Geral'), -- ????
  (8, 'Hidrossanitário'),
  (9, 'Infiltração'),
  (10, 'Marcenaria'),
  (11, 'Piso'),
  (12, 'Revestimento'),
  (13, 'Serralheria'),
  (14, 'Vedação'),
  (15, 'Vidraçaria');

comment on table order_categories is E'@omit create,update,delete';

-- person roles
create table person_roles (
 person_role_id text primary key,
);

insert into person_roles values
  ('administrator'),
  ('supervisor'),
  ('inspector'),
  ('employee'),
  ('visitor');

comment on table person_roles is E'@omit create,update,delete';

-- spec categories
create table spec_categories (
  spec_category_id integer primary key,
  spec_category_text text not null
);

insert into spec_categories values
  (1, 'Geral'),
  (2, 'Serviços de Apoio'),
  (3, 'Civil'),
  (4, 'Hidrossanitário'),
  (5, 'Elétrica'),
  (6, 'Ar-condicionado'),
  (7, 'Marcenaria'),
  (8, 'Rede e Telefonia'),
  (9, 'Ferramentas e Equipamentos');

comment on table spec_categories is E'@omit create,update,delete';

-- spec subcategories
create table spec_subcategories (
  spec_category_id integer not null references spec_categories (spec_category_id),
  spec_subcategory_id integer primary key,
  spec_subcategory_text text not null
);

insert into spec_subcategories values
  (1, 1, 'Equipe de Dedicação Exclusiva'),
  (1, 2, 'Serviços Técnicos'),
  (1, 3, 'Serviços Preliminares'),
  (1, 4, 'Segurança do Trabalho'),
  (1, 5, 'Limpeza'),
  (2, 6, 'Furos'),
  (2, 7, 'Estrutural'),
  (2, 8, 'Impermeabilização'),
  (2, 9, 'Vedações'),
  (2, 10, 'Revestimentos'),
  (2, 12, 'Pinturas'),
  (2, 13, 'Pisos'),
  (2, 14, 'Marmores e Granitos'),
  (2, 15, 'Divisórias'),
  (2, 16, 'Forros'),
  (2, 17, 'Carpete'),
  (2, 18, 'Vidro Comum'),
  (2, 19, 'Espelho'),
  (2, 20, 'Vidro Temperado'),
  (2, 21, 'Persianas'),
  (2, 22, 'Película'),
  (2, 23, 'Estruturas'),
  (2, 24, 'Aditivos'),
  (2, 25, 'Acessibilidade'),
  (2, 26, 'Equipe de Dedicação Exclusiva'),
  (2, 27, 'Vidro - Outros'),
  (3, 28, 'Tubos'),
  (3, 29, 'Registros e Válvulas'),
  (3, 30, 'Ralos e caixas'),
  (3, 31, 'Louças'),
  (3, 32, 'Metais'),
  (3, 33, 'Acessibilidade'),
  (3, 34, 'Acessórios'),
  (4, 35, 'Infraestrutura'),
  (4, 36, 'Interruptores e Tomadas'),
  (4, 37, 'Iluminação'),
  (4, 38, 'Condutores'),
  (4, 39, 'Quadros'),
  (5, 40, 'Equipamentos Terminais e Unitários'),
  (5, 41, 'Exaustores'),
  (5, 42, 'Dutos'),
  (5, 43, 'Difusores E Grelhas'),
  (5, 44, 'Acessórios Para Equipamentos Unitários'),
  (5, 45, 'Válvulas'),
  (5, 46, 'Tubos e isolamento térmico'),
  (6, 47, 'Armários'),
  (6, 48, 'Portas'),
  (6, 49, 'Ferragens'),
  (6, 50, 'Materiais Para Lustração'),
  (6, 51, 'Acabamento'),
  (6, 52, 'Rodízios'),
  (6, 53, 'Persianas'),
  (6, 54, 'Cortinas'),
  (6, 55, 'Colas e Espuma Expansiva'),
  (6, 56, 'Laminados'),
  (6, 57, 'Compensados'),
  (6, 58, 'Madeira Bruta'),
  (6, 59, 'Painéis MDF'),
  (6, 60, 'Perfis e Chapas em Aço e Ferro'),
  (6, 61, 'Tubos'),
  (6, 62, 'Telas e Arames em Aço'),
  (6, 63, 'Consumível'),
  (6, 64, 'Equipe de Dedicação Exclusiva'),
  (7, 65, 'Rede'),
  (7, 66, 'Telefonia'),
  (8, 67, 'Uso Geral'),
  (8, 68, 'Marcenaria'),
  (8, 69, 'Serralheria'),
  (8, 70, 'Civil'),
  (8, 71, 'Uniformes'),
  (8, 72, 'Equipamentos de Proteção Individual');

comment on table spec_subcategories is E'@omit create,update,delete';

create table rule_categories (
  rule_category_id integer primary key,
  rule_category_text text not null
);

insert into rule_categories values
  (1, 'Leis e Decretos'),
  (2, 'Normas do Ministério do Trabalho'),
  (3, 'Acórdãos do TCU'),
  (4, 'Referências Nacionais'),
  (5, 'Referências Internacionais'),
  (6, 'Normas ABNT'),
  (7, 'Diretrizes do Senado Federal');

comment on table rule_categories is E'@omit create,update,delete';