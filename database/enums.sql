create type asset_category_type as enum (
  'F',
  'A'
);

create type contract_status_type as enum (
  'LIC',
  'EXE',
  'ENC'
);

create type task_status_type as enum (
  'CAN',
  'NEG',
  'PEN',
  'SUS',
  'FIL',
  'EXE',
  'CON'
);

create type task_priority_type as enum (
  'BAI',
  'NOR',
  'ALT',
  'URG'
);

create type task_category_type as enum (
  'ARC',
  'ELE',
  'ELV',
  'EST',
  'EXA',
  'FOR',
  'GRL',
  'HID',
  'INF',
  'MAR',
  'PIS',
  'REV',
  'SER',
  'VED',
  'VID'
);

create type person_role_type as enum (
  'administrator',
  'supervisor',
  'inspector',
  'employee',
  'visitor'
);

create type spec_category_type as enum (
  'g', -- 'Geral'
  's', -- 'Serviços de Apoio'
  'c', -- 'Civil'
  'h', -- 'Hidrossanitário'
  'e', -- 'Elétrica'
  'a', -- 'Ar Condicionado'
  'm', -- 'Marcenaria e Serralheria'
  'r', -- 'Rede e Telefonia'
  'f'  -- 'Ferramentas e Equipamentos'
);

create type spec_subcategory_type as enum (
  -- 'Geral'
  'g-01', 'Equipe de Dedicação Exclusiva'

  -- 'Serviços de Apoio'
  's-01', -- 'Serviços Técnicos'
  's-02', -- 'Serviços Preliminares'
  's-03', -- 'Segurança do Trabalho'
  's-04', -- 'Limpeza'

  -- 'Civil'
  'c-01', -- 'Furos'
  'c-02', -- 'Estrutural'
  'c-03', -- 'Impermeabilização'
  'c-04', -- 'Vedações'
  'c-05', -- 'Revestimentos'
  'c-06', -- 'Pinturas'
  'c-07', -- 'Pisos'
  'c-08', -- 'Marmores e Granitos'
  'c-09', -- 'Divisórias'
  'c-10', -- 'Forros'
  'c-11', -- 'Carpete'
  'c-12', -- 'Vidro Comum'
  'c-13', -- 'Espelho'
  'c-14', -- 'Vidro Temperado'
  'c-15', -- 'Persianas'
  'c-16', -- 'Película'
  'c-17', -- 'Estruturas'
  'c-18', -- 'Aditivos'
  'c-19', -- 'Acessibilidade'
  'c-20', -- 'Equipe de Dedicação Exclusiva'
  'c-21', -- 'Vidro - Outros'

  -- 'Hidrossanitário'
  'h-01', -- 'Tubos'
  'h-02', -- 'Registros e Válvulas'
  'h-03', -- 'Ralos e caixas'
  'h-04', -- 'Louças'
  'h-05', -- 'Metais'
  'h-06', -- 'Acessibilidade'
  'h-07', -- 'Acessórios'

  -- 'Elétrica'
  'e-01', -- 'Infraestrutura'
  'e-02', -- 'Interruptores e Tomadas'
  'e-03', -- 'Iluminação'
  'e-04', -- 'Condutores'
  'e-05', -- 'Quadros'

  -- 'Ar Condicionado'
  'a-01', -- 'Equipamentos Terminais e Unitários'
  'a-02', -- 'Exaustores'
  'a-03', -- 'Dutos'
  'a-04', -- 'Difusores E Grelhas'
  'a-05', -- 'Acessórios Para Equipamentos Unitários'
  'a-06', -- 'Válvulas'
  'a-07', -- 'Tubos e isolamento térmico'

  -- 'Marcenaria e Serralheria'
  'm-01', -- 'Armários'
  'm-02', -- 'Portas'
  'm-03', -- 'Ferragens'
  'm-04', -- 'Materiais Para Lustração'
  'm-05', -- 'Acabamento'
  'm-06', -- 'Rodízios'
  'm-07', -- 'Persianas'
  'm-08', -- 'Cortinas'
  'm-09', -- 'Colas e Espuma Expansiva'
  'm-10', -- 'Laminados'
  'm-11', -- 'Compensados'
  'm-12', -- 'Madeira Bruta'
  'm-13', -- 'Painéis MDF'
  'm-14', -- 'Perfis e Chapas em Aço e Ferro'
  'm-15', -- 'Tubos'
  'm-16', -- 'Telas e Arames em Aço'
  'm-17', -- 'Consumível'
  'm-18', -- 'Equipe de Dedicação Exclusiva'

  -- 'Rede e Telefonia'
  'r-01', -- 'Rede'
  'r-02', -- 'Telefonia'

  -- 'Ferramentas e Equipamentos'
  'f-01', -- 'Uso Geral'
  'f-02', -- 'Marcenaria'
  'f-03', -- 'Serralheria'
  'f-04', -- 'Civil'
  'f-05', -- 'Uniformes'
  'f-06'  -- 'Equipamentos de Proteção Individual'
);

create type rule_category_type as enum (
  'LEI', -- leis e decretos
  'NMT', -- normas do ministério do trabalho
  'TCU', -- acórdãos do tcu
  'NAC', -- referências nacionais
  'INT', -- referências internacionais
  'ABN', -- normas abnt
  'DSF'  -- diretrizes do senado federal
);