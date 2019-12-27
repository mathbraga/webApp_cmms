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
