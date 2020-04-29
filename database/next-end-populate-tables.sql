insert into assets overriding system value values (1, 'CASF-000-000', 'Endereçamento do CASF', null, 1, null, null, null);
insert into asset_relations values (1, null, 1);
insert into contracts overriding system value values (1, 'CT00452019', null, 2, '2019-07-11', '2019-07-15', '2019-07-11', '2020-07-10', 'Adtel Tecnologia', 'Marcenaria e serralheria', 'Contratação de empresa para a prestação de serviços contínuos e sob demanda referentes à manutenção preventiva, corretiva e preditiva dos sistemas e equipamentos de marcenaria, serralheria e obras civis do Complexo Arquitetônico do Senado Federal (inclusive Residências Oficiais) e áreas comuns do Congresso Nacional, com a disponibilização de mão de obra qualificada e com suprimento de insumos necessários à execução dos serviços.', 'https://www6g.senado.gov.br/transparencia/licitacoes-e-contratos/contratos/4723');
insert into persons overriding system value values (1, '00000000001', 'hzlopes@senado.leg.br', 'Henrique Zaidan Lopes', '2339', null, null);
insert into persons overriding system value values (2, '00000000002', 'pedrohs@senado.leg.br', 'Pedro Henrique Serafim', '2339', null, null);
insert into private.accounts values (1, crypt('123456', gen_salt('bf', 10)), true, 'administrator');
insert into private.accounts values (2, crypt('123456', gen_salt('bf', 10)), true, 'administrator');
insert into teams overriding system value values (1, 'SEPLAG', 'Equipe do SEPLAG', true);
insert into teams overriding system value values (2, 'Posto 1 - Contrato', 'Atendimento de demandas do Anexo 2', true);
insert into team_persons values (1, 1);
insert into team_persons values (2, 2);
insert into projects overriding system value values (1, 'Reparos no estacionamento do Anexo 1', 'Serviços a serem realizados durante o recesso parlamentar', '2020-01-01', '2020-01-31', true);


insert into tasks overriding system value values (
  1,
  1,
  1,
  null,
  'title',
  'description',
  null,
  null,
  null,
  null,
  'place',
  0,
  '2020-12-31',
  '2020-12-01',
  null
);
insert into task_assets values (1, 1);
insert into specs overriding system value values (1, $$SF-00001$$, $$v02$$, $$Engenheiro(a) /Arquiteto(a) júnior$$, 2, 2, $$hh$$, true, $$Disponibilização de engenheiro(a)/arquiteto(a) júnior para realização de levantamentos de materiais, execução de medições e vistoria diária das obras
Esse(a) profissional deverá:
1) Assumir direta e pessoalmente a responsabilidade pela execução dos serviços de engenharia/arquitetura realizados dentro de sua especialidade (arquitetura, civil, elétrica ou mecânica) e subscrever todos os Relatórios de Medição (RM), devendo, durante a vigência contratual, instruir, conferir e garantir a qualidade técnica das intervenções Contratadas.
2) Permanecer sempre à disposição para atender a Fiscalização por meio de telefone e de reuniões presenciais, para esclarecimentos e assistência rotineiros sobre o andamento dos serviços e sobre eventuais dúvidas técnicas que possam surgir.
3) Encarregar-se diretamente da observância das normas técnicas aplicáveis e das especificações do edital e todos os seus anexos. 
4) Controlar e manter atualizados o Cronograma Físico da Obra, Estrutura Analítica do Projeto – EAP (com Curva S), Relatório Diário de Obras (RDO), Tabela de Recursos, Formulário de Solicitação de Mudança, supervisionar segurança e aspectos ambientais da obra. Caso a Fiscalização solicite alteração nos documentos, a Contratada deverá fazê-la no prazo de 3 (três) dias úteis. A apropriação das horas de Engenheiro(a)/Arquiteto(a) será definida pela Fiscalização do Senado Federal.$$, null, null, $$Esse(a) profissional será responsável inclusive pela(o):
1)Supervisão, coordenação e Fiscalização do bom andamento dos serviços da Contratada;
2)Supervisão de todas as atividades de almoxarifado, devendo assegurar o fluxo adequado de materiais e mão de obra para conclusão a tempo dos serviços contratados. 
3)Definição, avaliação e modificar as rotinas de trabalho dos operários, determinando e supervisionando as ações ordinárias e emergenciais corretivas
4)Fiscalização do uso e distribuição das ferramentas, materiais, uniformes e EPI/EPC;
5)Fiscalização da disciplina, apresentação pessoal e frequência dos funcionários da Contratada;
6)Fiscalização do atendimento pelos funcionários da Contratada às normas técnicas, legais e administrativas;
7)Conhecimento e leitura de pranchas gráficas de arquitetura e de instalações prediais; e
8)Conhecimento das leis trabalhistas aplicáveis às categorias funcionais previstas neste certame.$$, $$A qualificação e experiência mínimas exigidas do(a) Engenheiro(a)/Arquiteto(a) Júnior será:
1)Graduação superior plena nas áreas de Arquitetura e Urbanismo ou Engenharia (Civil, Elétrica ou Mecânica ou habilitações equivalentes, nos termos da Resolução, e conforme solicitação do Senado Federal e serviço a ser executado), com diploma de curso reconhecido pelo MEC, conforme indicação pelo Senado Federal;
2)Registro Profissional junto ao CREA ou CAU, como Engenheiro(a) ou Arquiteto(a);
3)Seis (6) meses de experiência como Engenheiro(a) ou Arquiteto(a), comprovada em carteira de trabalho ou por certidões de acervo técnico emitidas pelo CREA ou CAU; e
4)Cursos NR 10 – Curso básico (carga horária de 40 horas), NR 33 – Curso da Modalidade Trabalhador Autorizado, e NR 35 – Curso Básico, com programa definidos pelo Ministério do Trabalho e Emprego - MTE. Os certificados de conclusão desses 3 (três) cursos para esse(a) profissional poderão ser apresentados em até 30 (trinta) dias contados do início dos serviços.
A Contratada deve comprovar o vínculo do(a) Engenheiro(a)/Arquiteto(a) Júnior ao seu quadro de funcionários(as) através de contrato social em que conste o(a) profissional como sócio(a) da Contratada; carteira de trabalho (CTPS), ficha de registro de empregado ou contrato de prestação de serviço, em que conste a Contratada como contratante.$$, null, $$Critérios de acionamento: O(a) Engenheiro(a)/Arquiteto(a) Júnior deve ter suas atividades vinculadas às intervenções Contratadas no âmbito desse Registro de Preços, sendo vedada sua atuação em quaisquer outras atividades no Senado Federal dissociadas desse Registro de Preços.
Critério de medição: As horas trabalhadas do(a) Engenheiro(a)/Arquiteto(a) júnior serão pagas conforme o avanço no cronograma físico-financeiro da obra no período entre a medição apresentada e a última medição paga. 
Exemplo: Se, entre as medições, a obra avançou 10% no cronograma físico-financeiro (desconsideradas as horas de Engenheiro(a)/Arquiteto(a) Júnior e de Mestre de Obras), poderão ser pagos 10% do total de horas Contratadas para Engenheiro(a)/Arquiteto(a) júnior, limitados ao total de horas totais Contratadas. 
O total de horas trabalhadas pagas não poderá exceder o total de horas de trabalho Contratadas. 
O avanço do cronograma físico-financeiro não constitui garantia de pagamento das horas de Engenheiro(a)/Arquiteto(a) júnior. Para fazer jus ao pagamento, a Contratada deve manter esses(as) profissionais presentes na(s) obra(s) para as quais foram designados(as), desempenhando o trabalho para o qual foram contratados(as).
Unidade de Medição: por hora de serviço.$$, null, null, null, $$Não$$, null, null);



insert into supplies overriding system value values (1, 'M1', 1, 1, 1000, 10, 11);

insert into task_supplies values (1, 1, 1);

insert into task_files values (1, 'filename', 'c6235813-3ba4-3801-ae84-e0a6ebb7d138', 234234, 1, now());


insert into task_dispatches values ();

insert into task_status values ();


