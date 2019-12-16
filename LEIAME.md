# Problemas existentes

1. Inexistência de banco de dados contendo registros de todos os ativos

1. Inexistência de histórico de manutenção de cada ativo

1. Inexistência de ferramenta central para a fiscalização de contratos, dificultando ou impedindo:
  * a consulta em tempo real dos saldos de manteriais ou serviços contratados;
  * ajustes necessários em futuras contratações;
  * a elaboração de relatórios;
  * a aplicação de acordo de nível de serviço;
  * o cálculo de KPIs;
  * a padronização dos documentos elaborados pela SINFRA.

1. Inexistência de ferramenta interativa para o solicitante de serviço, impedindo o usuário de:
  * conhecer os custos do serviço solicitado;
  * saber status do serviço solicitado (em análise, cancelado, em execução etc.);
  * atestar a conclusão do serviço;
  * avaliar a execução do serviço;
  * 

# Requisitos

1. O sistema deve permitir o cadastro das seguintes entidades:
  * ativo;
  * contrato;
  * usuário;
  * equipe;
  * tarefa;
  * especificação técnica;
  * suprimento (material ou serviço de um contrato);
  * regra (Leis, Decretos, normas técnicas, diretrizes do Senado Federal etc.)

1. Uma tarefa somente pode ser cadastrada se estiver vinculada a um ou mais ativos.


# Arquitetura

O desenvolvimento do sistema deverá fazer uso de ferramentas e bibliotecas modernas,disponibilizadas em código aberto (open source) sempre que possível, permitindo a sua contínua evolução.

## Back-end

O back-end será formado por duas camadas básicas:

  * servidor web; e
  * sistema gerenciador de banco de dados relacional (RDBMS)

As principais funcionalidades da camada de servidor web são: (1) expor a página web ao usuário do sistema (protocolo HTTP ou HTTPS); (2) realizar a lógica de autenticação e geração dos cookies de sessão de usuário; (3) executar rotinas periódicas (ex.: backups e atualizações via APIs); e (4) manter um sistema de diretórios e arquivos vinculados às entidades do banco de dados (ex.: manuais de equipamentos, fotos de edifícios, plantas arquitetônicas etc.).
O framework Express constituirá a base dessa camada. Bibliotecas compatíveis poderão ser
acrescentadas para agregar outras funcionalidades (ex.: Passport para autenticação, Postgraphile como API de acesso ao banco de dados etc.)

As principais funcionalidades do RDBMS são: (1) garantir a atomicidade, consistência, isolamento e durabilidade dos dados inseridos no sistema; e (2) realizar as operações de criação, leitura, atualização e remoção (CRUD) nas tabelas, conforme as permissões definidas para cada usuário (ou grupo de usuários) do sistema.
Será utilizado o banco de dados PostgreSQL.

## Front-end

A interface ao usuário disponibilizada pelo sistema terá a forma de uma página web, que deverá possuir um visual moderno e agradável, com navegação intuitiva e responsividade (ajuste automático à largura da tela do dispositivo utilizado pelo usuário).
O front-end terá como base a estrutura do Create React App.
Os componentes das páginas serão criados com a biblioteca React.
O gerenciamento do histórico de navegação e o roteamento serão realizados com o React-Router.
Outras bibliotecas compatíveis com esta arquitetura poderão ser incluídas.


# Sprints

## Sprint 1: 01/09/2019 a 30/09/2019

Telas para visualização de:

  * lista de todos edifícios
  * detalhes de um edifício
  * lista de todos equipamentos
  * detalhes de um equipamento
  * lista de todas ordens de serviço
  * detalhes de uma tarefa

Formulários para cadastro de:

  * novo edifício
  * novo equipamento
  * nova tarefa

--- 

## Sprint 2: 01/10/2019 a 08/11/2019

Telas para visualização de:

  * lista de todos contratos
  * detalhes de um contrato, com seus respectivos materiais e serviços
  * lista de todos usuários
  * lista de todas equipes
  * lista dos usuários que pertencem a uma equipe
  * lista de todas especificações técnicas
  * detalhes de uma especificação técnica

Formulários para cadastro de:

  * nova especificação técnica
  * novo contrato
  * novo material ou serviço de um contrato

---

## Sprint 3: 09/11/2019 a 09/12/2019

Melhoria dos formulários existentes, para passar a permitir:

  * upload de arquivos ao servidor
  * atualização das informações cadastradas (operação de UPDATE no banco de dados)
