create table contracts (
  contract_id text primary key,
  parent text references contracts (contract_id),
  date_sign date not null,
  date_pub date,
  date_start date not null,
  date_end date,
  company_name text not null,
  title text not null,
  description text not null,
  url text not null
);

insert into contracts values ('CT00452019', null, '2019-07-11', '2019-07-15', '2019-07-11', '2020-07-10', 'Adtel Tecnologia', 'Marcenaria e serralheria', 'Contrata��o de empresa para a presta��o de servi�os cont�nuos e sob demanda referentes � manuten��o preventiva, corretiva e preditiva dos sistemas e equipamentos de marcenaria, serralheria e obras civis do Complexo Arquitet�nico do Senado Federal (inclusive Resid�ncias Oficiais) e �reas comuns do Congresso Nacional, com a disponibiliza��o de m�o de obra qualificada e com suprimento de insumos necess�rios � execu��o dos servi�os.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/4723');
insert into contracts values ('CT00662019', null, '2019-09-25', '2019-09-26', '2019-09-25', '2020-09-24', 'JR Com�rcio e Vidros Ltda.', 'Vidros', 'Contrata��o de empresa especializada para o fornecimento, instala��o, remanejamento, remo��o e transporte de pain�is de vidros temperados, vidros laminados e vidros comuns, incluindo portas, esquadrias, pain�is, espelhos, baguetes e ferragens, assim como a presta��o de servi�os de manuten��o de vidros comuns, com substitui��o de massa e silicone; de portas, esquadrias e pain�is de vidros temperados, � medida que houver necessidade, no Complexo Arquitet�nico e nas Resid�ncias Oficiais do SENADO FEDERAL, durante o per�odo de 12 (doze) meses consecutivos.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/4751');
insert into contracts values ('CT00812017', null, '2017-10-19', '2017-10-25', '2017-10-19', '2020-10-18', 'RCS Tecnologia Ltda.', 'Manuten��o civil', 'Contrata��o de empresa especializada para a presta��o de servi�os continuados de manuten��o preventiva e corretiva dos sistemas de revestimentos, veda��es, forros, pinturas e pavimenta��o vi�ria no Complexo Arquitet�nico do SENADO FEDERAL, durante o per�odo de 36 (trinta e seis) meses consecutivos.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/4213');
insert into contracts values ('RP00072019', null, '2019-01-24', '2019-01-25', '2019-01-24', '2020-01-23', 'Connector Engenharia Ltda.', 'Insumos e servi�os de engenharia', 'Contrata��o de empresa para fornecimento de insumos e servi�os comuns de engenharia para reformas e obras no Complexo Arquitet�nico do Senado Federal e nas �reas comuns do Congresso Nacional', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/atas-de-registro-de-preco/1584');

