-- asset categories
create table asset_categories (
  asset_category_id char(1) primary key,
  asset_category_text text not null
);

insert into asset_categories values
  ('a', 'Equipamentos'),
  ('f', 'Edifícios');

comment on table asset_categories is E'@omit create,update,delete';

-- contract statuses
create table contract_statuses (
  contract_status_id char(1) primary key,
  contract_status_text text not null
);

insert into contract_statuses values
  ('l', 'Licitação');
  ('')

comment on table contract_statuses is E'@omit create,update,delete';

-- order statuses
create table order_statuses (
  order_status_id char(1) primary key,
  order_status_text text not null
);

insert into order_statuses values
  ('z', 'Cancelada'),
  ('n', 'Negada'),
  ('p', 'Pendente'),
  ('s', 'Suspensa'),
  ('f', 'Fila de espera'),
  ('e', 'Em execução'),
  ('c', 'Concluída');

comment on table order_statuses is E'@omit create,update,delete';

-- order priorities
create table order_priorities (
  order_priority_id char(1) primary key,
  order_priority_text text not null
);

insert into order_priorities values
  ('b', 'Baixa'),
  ('n', 'Normal'),
  ('a', 'Alta'),
  ('u', 'Urgente');

comment on table order_priorities is E'@omit create,update,delete';

-- order categories
create table order_categories (
  order_category_id char(1) primary key,
  order_category_text text not null
);

insert into order_categories values
  ('a', 'Ar-condicionado'),
  ('e', 'Elétrica'),
  ('l', 'Elevador'),
  ('s', 'Avaliação Estrutural'),
  ('x', 'Exaustor'),
  ('f', 'Forro'),
  ('g', 'Geral'), -- ????
  ('h', 'Hidrossanitário'),
  ('i', 'Infiltração'),
  ('m', 'Marcenaria'),
  ('p', 'Piso'),
  ('r', 'Revestimento'),
  ('j', 'Serralheria'),
  ('z', 'Vedação'),
  ('v', 'Vidraçaria');

comment on table order_categories is E'@omit create,update,delete';

-- person roles
create table person_roles (
 person_role_id char(1) primary key,
 person_role_text text not null
);

insert into person_roles values
  ('a', 'Administrador'),
  ('s', 'Supervisor'),
  ('i', 'Inspetor'),
  ('e', 'Terceirizado'),
  ('v', 'Visitante');

comment on table person_roles is E'@omit create,update,delete';

-- spec categories
create table spec_categories (
  spec_category_id char(1) primary key,
  spec_category_text text not null
);

insert into spec_categories values
  ('g', 'Geral'),
  ('s', 'Serviços de Apoio'),
  ('c', 'Civil'),
  ('h', 'Hidrossanitário'),
  ('e', 'Elétrica'),
  ('a', 'Ar-condicionado'),
  ('m', 'Marcenaria'),
  ('r', 'Rede e Telefonia'),
  ('f', 'Ferramentas e Equipamentos');

comment on table spec_categories is E'@omit create,update,delete';

-- spec subcategories
create table spec_subcategories (
  spec_category_id char(1) not null references spec_categories (spec_category_id),
  spec_subcategory_id char(1) primary key,
  spec_subcategory_text text not null
);

insert into spec_subcategories values
  ('g', 'd', 'Equipe de Dedicação Exclusiva'),
  ('s', 't', 'Serviços Técnicos'),
  ('s', 'p', 'Serviços Preliminares'),
  ('s', 's', 'Segurança do Trabalho'),
  ('s', 'l', 'Limpeza'),
  ('c', 'f', 'Furos'),
  ('c', 'e', 'Estrutural'),
  ('c', 'i', 'Impermeabilização'),
  ('c', 'z', 'Vedações'),
  ('c', 'r', 'Revestimentos'),
  ('c', 'n', 'Pinturas'),
  ('c', 'p', 'Pisos'),
  ('c', 'm', 'Marmores e Granitos'),
  ('c', 'd', 'Divisórias'),
  ('c', 'b', 'Forros'),
  ('c', 'k', 'Carpete'),
  ('c', 'v', 'Vidro Comum'),
  ('c', 'u', 'Espelho'),
  ('c', 't', 'Vidro Temperado'),
  ('c', 'g', 'Persianas'),
  ('c', 'o', 'Película'),
  ('c', 'y', 'Estruturas'),
  ('c', 'a', 'Aditivos'),
  ('c', 'x', 'Acessibilidade'),
  ('c', 'q', 'Equipe de Dedicação Exclusiva'),
  ('c', 'z', 'Vidro - Outros'),
  ('h', 't', 'Tubos'),
  ('h', 'r', 'Registros e Válvulas'),
  ('h', 'c', 'Ralos e caixas'),
  ('h', 'l', 'Louças'),
  ('h', 'm', 'Metais'),
  ('h', 'x', 'Acessibilidade'),
  ('h', 'a', 'Acessórios'),
  ('e', 'i', 'Infraestrutura'),
  ('e', 't', 'Interruptores e Tomadas'),
  ('e', 'i', 'Iluminação'),
  ('e', 'c', 'Condutores'),
  ('e', 'q', 'Quadros'),
  ('a', 'e', 'Equipamentos Terminais e Unitários'),
  ('a', 'x', 'Exaustores'),
  ('a', 'd', 'Dutos'),
  ('a', 'g', 'Difusores E Grelhas'),
  ('a', 'a', 'Acessórios Para Equipamentos Unitários'),
  ('a', 'v', 'Válvulas'),
  ('a', 'i', 'Tubos e isolamento térmico'),
  ('m', 'a', 'Armários'),
  ('m', 'p', 'Portas'),
  ('m', 'f', 'Ferragens'),
  ('m', 'l', 'Materiais Para Lustração'),
  ('m', 'a', 'Acabamento'),
  ('m', 'r', 'Rodízios'),
  ('m', 'p', 'Persianas'),
  ('m', 'c', 'Cortinas'),
  ('m', 'e', 'Colas e Espuma Expansiva'),
  ('m', 'n', 'Laminados'),
  ('m', 'k', 'Compensados'),
  ('m', 'b', 'Madeira Bruta'),
  ('m', 'm', 'Painéis MDF'),
  ('m', 'f', 'Perfis e Chapas em Aço e Ferro'),
  ('m', 't', 'Tubos'),
  ('m', 'z', 'Telas e Arames em Aço'),
  ('m', 'q', 'Consumível'),
  ('m', 'd', 'Equipe de Dedicação Exclusiva'),
  ('r', 'r', 'Rede'),
  ('r', 't', 'Telefonia'),
  ('f', 'g', 'Uso Geral'),
  ('f', 'm', 'Marcenaria'),
  ('f', 's', 'Serralheria'),
  ('f', 'c', 'Civil'),
  ('f', 'u', 'Uniformes'),
  ('f', 'p', 'Equipamentos de Proteção Individual');

comment on table spec_subcategories is E'@omit create,update,delete';

create table rule_categories (
  rule_category_id char(1) primary key,
  rule_category_text text not null
);

insert into rule_categories values
  ('l', 'Leis e Decretos'),
  ('m', 'Normas do Ministério do Trabalho'),
  ('t', 'Acórdãos do TCU'),
  ('n', 'Referências Nacionais'),
  ('i', 'Referências Internacionais'),
  ('a', 'Normas ABNT'),
  ('d', 'Diretrizes do Senado Federal');

comment on table rule_categories is E'@omit create,update,delete';