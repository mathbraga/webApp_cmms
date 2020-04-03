<h1>webSINFRA</h1>

<p>
  webSINFRA é o sistema de gestão de manutenção da Secretaria de Infraestrutura do Senado Federal.
</p>

<h2>Arquitetura</h2>

<p>
  O webSINFRA é desenvolvido como uma <a href="https://en.wikipedia.org/wiki/Web_application">aplicação web</a>, e os diretórios deste repositório (📁database, 📁backend e 📁frontend) correspondem às<a href="https://en.wikipedia.org/wiki/Multitier_architecture"> três camadas</a> de sua arquitetura.
</p>

<h3>📁 database</h3>

EXPLICAÇÕES PARA ADICIONAR:
* types (file_metadata)
* triggers
* exception messages
* asset trees



<p>O sistema gerenciador de banco de dados relacional (RDBMS) é o <a href="https://www.postgresql.org/">PostgreSQL</a>.</p>

<h4>Modelo de dados e tabelas</h4>

<p>As seguintes entidades compoẽm o modelo de dados:</p>
<table>
  <thead>
    <tr>
      <th>Entidade</th>
      <th>Função no sistema</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Task</td>
      <td>Tarefa, que registra uma ação necessária pela SINFRA, geralmente com a utilização de mão-de-obra, material ou serviço de algum contrato.</td>
    </tr>
    <tr>
      <td>Asset</td>
      <td>Ativo (qualquer imóvel listado no manual de endereçamento desenvolvido pela arquitetura) ou equipamento/subsistema de algum dos sistemas cuja manutenção é realizada pela SINFRA (como elevadores, aparelhos de ar-condicionado, geradores, quadros elétricos etc.). As relações entre um ativo e outro servem para indicar a localização de um ativo (em que sala está determinado aparelho?) ou a hierarquia entre eles (tal quadro elétrico é alimentado por qual estação transformadora?).</td>
    </tr>
    <tr>
      <td>Contract</td>
      <td>Contrato (ou projeto de contratação) com fiscalização ou gestão realizadas pela SINFRA.</td>
    </tr>
    <tr>
      <td>Person</td>
      <td>Usuário do CMMS (efetivos, comissionados, terceirizados).</td>
    </tr>
    <tr>
      <td>Spec</td>
      <td>Especificação técnica de um suprimento.</td>
    </tr>
    <tr>
      <td>Supply</td>
      <td>Suprimento (material ou serviço) vinculado a um contrato, com respectivos preço unitário e quantitativo, e que possui uma especificação técnica.</td>
    </tr>
    <tr>
      <td>Team</td>
      <td>Equipe, grupo de usuários do CMMS responsável por alguma ação pendente em uma tarefa.</td>
    </tr>
    <tr>
      <td>Project</td>
      <td>Agrupa várias tarefas para alguma atividade da SINFRA que necessita da utilização de vários contratos e/ou tarefas.</td>
    </tr>
  </tbody>
</table>

<p>
  A imagem abaixo ilustra as principais relações entre as entidades existentes no banco de dados:
</p>
<div align="center">
  <img src="cmms.jpg" alt="Cmms Image"/>
</div>

<p>
  Essas entidades, bem como as relações existentes entre elas, são registradas no banco de dados, conforme definições dadas em: <a href="./database/tables.sql">/database/tables.sql</a>. As relações que somente podem assumir os valores de 1:0 ou 1:1 são mapeadas como atributos de uma entidade (colunas de uma tabela, por exemplo, a coluna project_id da tabela tasks, que indica se uma tarefa pertence a um projeto). As relações que podem assumir os valores 1:N são mapeadas como linhas de uma tabela de associação (por exemplo, a tabela task_assets, que contém os ativos vinculados a cada tarefa).
</p>

<p>
  Relações entre as entidades registradas em tabelas de associação:
</p>

<table>
  <thead>
    <tr>
      <th>Entidade</th>
      <th>Cardinalidade</th>
      <th>Entidade</th>
      <th>Relação</th>
      <th>Detalhes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Asset</td>
      <td>1..*</td>
      <td>Asset</td>
      <td>Define uma relação hierárquica entre os ativos.</td>
    </tr>
    <tr>
      <td>Task</td>
      <td>1..*</td>
      <td>Asset</td>
      <td>Define os ativos que estão vinculados a uma determinada tarefa.</td>
    </tr>
    <tr>
      <td>Task</td>
      <td>0..*</td>
      <td>Supplies</td>
      <td>Define os suprimentos que serão utilizados na execuçao de determinada tarefa.</td>
    </tr>
    <tr>
      <td>Team</td>
      <td>1..*</td>
      <td>Persons</td>
      <td>Define as pessoas que pertencem a uma determinada equipe.</td>
    </tr>
  </tbody>
</table>

<p>
  Para a consistência deste modelo de dados, alguns dos atributos dessas entidades possuem um conjunto limitado de valores possíveis (e.g. o status de uma tarefa somente pode ser 'pendente', 'em execução', 'concluída' etc.), não podendo serem escolhidos livremente pelos usuários (como é o caso, por exemplo, da descrição de uma tarefa).
</p>
<p>
  Esses valores são cadastrados no banco de dados em tabelas próprias, chamadas 'lookup tables' (LUTs), que contêm apenas códigos numéricos (um para cada valor distinto, a serem referenciados por outras tabelas) e seus respectivos textos descritivos (para visualização pelo usuário, no front-end). 
</p>
<p>
  A garantia de que não serão válidas as operações de <code>INSERT</code> ou <code>UPDATE</code> que contenham valores não existentes nas LUTs é imposta por chaves estrangeiras (restrições como "<code>REFERENCES nome_da_LUT (código_da_LUT)</code>", aplicadas nas colunas que deverão ser submetidas a essa checagem).
</p>
<p>
  A adição de novos valores em LUTs não é possível pela interface do usuário. Tal modificação (bem como quaisquer outras alterações no modelo de dados) somente pode ser realizada por um administrador do sistema, em um procedimento denominado '<a href="https://en.wikipedia.org/wiki/Schema_migration">schema migration</a>'.
</p>
<p>As LUTs são as seguintes:</p>
<table>
  <thead>
    <tr>
      <th>Nome da LUT</th>
      <th>Atributo</th>
      <th>Exemplos de valores possíveis</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>contract_statuses</td>
      <td>Status de uma contratação</td>
      <td>Em licitação, em execução, finalizado etc.</td>
    </tr>
    <tr>
      <td>task_statuses</td>
      <td>Status de uma tarefa</td>
      <td>Pendente, cancelada, concluída etc.</td>
    </tr>
    <tr>
      <td>task_priorities</td>
      <td>Prioridade de uma tarefa</td>
      <td>Normal, alta etc.</td>
    </tr>
    <tr>
      <td>task_categories</td>
      <td>Categoria de uma tarefa</td>
      <td>Elétrica, hidrossanitária, civil, ar-condicionado etc.</td>
    </tr>
    <tr>
      <td>person_roles</td>
      <td>Papéis (tipos de usuários, com suas respectivas permissões no sistema)</td>
      <td>administrator, supervisor etc.</td>
    </tr>
    <tr>
      <td>spec_categories</td>
      <td>Categorias de uma especificação técnica (em conformidade com a lista atual de categorias usadas na wiki do Redmine)</td>
      <td>Geral, Serviços de Apoio, Civil etc.</td>
    </tr>
    <tr>
      <td>spec_subcategories</td>
      <td>Subcategorias (vinculadas a uma das possíveis categorias) de uma especificação técnica (também em conformidade com a lista atual de subcategorias usadas na wiki do Redmine)</td>
      <td>Limpeza, Revestimentos, Pinturas, Pisos etc.</td>
    </tr>
  </tbody>
</table>
<p>Há ainda outras tabelas, que fazem parte do schema <code>private</code> (as explicações sobre os schemas são dadas posteriormente neste documento):</p>
<table>
  <thead>
    <tr>
      <th>Nome da tabela</th>
      <th>Conteúdo</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>accounts</code></td>
      <td>Dados referentes a contas dos usuários do sistema (e.g., hash das senhas*, papéis etc.).</td>
    </tr>
    <tr>
      <td><code>audit_trails</code></td>
      <td>Registros de modificações realizadas no banco de dados pelos usuários do sistema (operações de <code>INSERT</code>, <code>UPDATE</code> e <code>DELETE</code>.)</td>
    </tr>
  </tbody>
</table>
<p>
  (*) Observação: o hash das senhas é gerado com uma função de criptografia proveniente da extensão <a href="https://www.postgresql.org/docs/12/pgcrypto.html"><code>pgcrypto</code></a>.
</p>

<p>
  Convenções e estratégias utilizadas:
</p>

<ol>
  <li>Índices e chaves primárias
    <p>Todas as entidades possuem um atributo de 'identidade', definido automaticamente pelo RDBMS como um número inteiro sequencial (e.g.: coluna <code>asset_id</code> da tabela <code>assets</code>). Tais atributos são as chaves primárias de suas respectivas tabelas e, por isso, indexados. A indexação permite que uma query que busca uma entidade específica do banco de dados retorne resultados mais rapidamente (essas queries são as que ocorrem, por exemplo, quando um usuário usa o sistema para visualizar uma determinada tarefa). A convenção para os nomes dessas colunas é utilizar a terminação <code>_id</code></p>
    <p>A exceção desta regra é a tabela de papéis (grupos), <b>person_roles</b>, em que que a chave primária é a própria palavra que define o papel. Esta exceção é justificada pelo fato de que o comando <code>CREATE ROLE</code> não aceita números como nome do papel (o nome do papel deve ser uma palavra com caracteres alfanuméricos iniciada por uma letra).</p>
    <p>Algumas entidades possuem um outro atributo de identidade, correspondente a uma coluna definida com a restrição <code>UNIQUE</code>. Os valores a serem inseridos nessas colunas devem ser códigos amigáveis, que, ao contrário dos números sequenciais, fazem sentido para a aplicação e seus usuários. Exemplo: coluna <code>asset_sf</code> na tabela <code>assets</code>. A convenção para os nomes dessas colunas é utilizar a terminação <code>_sf</code> (de Senado Federal).</p>
    <p>O uso de dois identificadores dá flexibilidade ao modelo de dados, pois, dessa maneira, o usuário pode alterar livremente os códigos <code>_sf</code> das entidades, com a única restrição de que escolha um código distinto dos códigos já existentes. Já a alteração das chaves primárias, operação proibida pelo RDBMS, torna-se desnecessária para os fins da aplicação.</p>
    <p>EXPLICAÇÃO DE CHAVES COM MÚLTIPLAS COLUNAS</p>
  </li>
  <li>Schemas
    <p>São utilizados 3 schemas ("namespaces"): (1) public, (2) private e (3) api.</p>
    <p>
      O schema <strong>public</strong> é o default utilizado pelo PostgreSQL e onde estão a maioria dos objetos do banco de dados (tabelas das entidades, views, types e funções auxiliares).
    </p>
    <p>
      O schema <strong>private</strong> contém dados que somente podem ser acessados pelos administradores (tabela com hash de senhas e 'roles' dos usuários, tabela com logs/audit trails etc.).
    </p>
    <p>
      O schema <strong>api</strong> é a interface exposta (via PostGraphile, em GraphQL) aos usuários da aplicação, contendo os objetos (views e funções) que traduzem as funcionalidades e requisitos definidos para o sistema. Exemplos:
      <table>
        <thead>
          <tr>
            <th>Funcionalidade / User story</th>
            <th>Objeto do schema api</th>
            <th>Tipo da operação em GraphQL</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>O usuário deseja visualizar todas as informações referentes a uma determinada tarefa</td>
            <td>View <code>api.task_data</code>, que compila, com <code>JOIN</code>s e views e funções auxiliares, todos os dados de uma tarefa e todas entidades a ela relacionadas (ativos, suprimentos etc.)</td>
            <td>Query</td>
          </tr>
          <tr>
            <td>O usuário deseja poder cadastrar um novo contrato e seus respectivos materiais e serviços</td>
            <td>Função <code>api.insert_contract</code>, cujos inputs são fornecidos pelo usuário (via formulário da UI) e executa os <code>INSERT</code>s necessários nas tabelas de contratos e suprimentos</td>
            <td>Mutation</td>
          </tr>
        </tbody>
      </table>
    </p>
  </li>
  <li>Funções
    <ul>
      <li>Nomes das funções: padronizar e diferenciar em relação</li>
      <li>Operações realizadas pelas funções: correspondem às operações disponibilizadas na interface ao usuário</li>
      <li>Business rules e checagens necessárias para integridade dos dados triggers</li>
    </ul>
  </li>
</ol>

<p>
  Algumas das funções:
</p>

<table>
  <thead>
    <tr>
      <th>Nome da função</th>
      <th>Descrição</th>
      <th>Momento da execução</th>
      <th>Operações realizadas</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        insert_task
      </td>
      <td>
        Função que cria uma tarefa.
      </td>
      <td>
        Quando o usuário envia os dados inseridos no formulário de cadastro de uma nova tarefa.
      </td>
      <td>
        Cria novas linhas nas tabelas que são afetadas (tasks e outras a ela relacionadas, por exemplo, task_assets e task_supplies).
      </td>
    </tr>
    <tr>
      <td>
        modify_task
      </td>
      <td>
        Função que altera uma tarefa.
      </td>
      <td>
        Quando o usuário envia os dados inseridos no formulário de edição de uma tarefa previamente criada.
      </td>
      <td>
        Atualiza linhas das tabelas que são afetadas (tasks e outras a ela relacionadas, por exemplo, task_assets e task_supplies).
      </td>
    </tr>
    <tr>
      <td>
        check_task_supply
      </td>
      <td>
        Trigger que verifica se o suprimento pode ser vinculado a uma tarefa.
      </td>
      <td>
        Antes da inserção (ou atualização) de uma linha na tabela task_supplies.
      </td>
      <td>
        Somente permite a inserção (ou atualização) da tabela task_supplies caso as três verificações sejam realizadas com sucesso: (1) existe saldo suficiente para o suprimento; (2) os valores decimais da quantidade selecionada para o suprimento não estão em desacordo com a sua especificação técnica (há suprimentos que somente permitem valores inteiros); e (3) o contrato vinculado à tarefa é o mesmo que contém o suprimento em questão.
      </td>
    </tr>
    <tr>
      <td>
        log_change
      </td>
      <td>
        Trigger que registra uma modificação no banco de dados.
      </td>
      <td>
        Após a inserção (ou atualização) de qualquer linha de qualquer tabela do banco de dados.
      </td>
      <td>
        Registra: (1) a id do usuário que realizou a modificação; (2) data e hora da modificação; (3) operação realizada (INSERT, UPDATE ou DELETE); (4) nome da tabela modificada; (5) valores antigos da linha modificada, caso exista, em formato JSON; e (6) valores novos da linha modificada, caso exista, em formato JSON.
      </td>
    </tr>
  </tbody>
</table>
<p>
  Os testes das rotinas que permitem os usuários realizarem alterações no banco de dados 
  (por exemplo, criação ou atualização de uma tarefa) e seus respectivos triggers de checagem são encontrados em <a href="./backend/tests">/backend/tests.</a>
</p>

<h4>Conexão, autenticação, roles (papéis) e Row-Level Security (RLS)</h4>

<p>
  Detalhes sobre conexão, autenticação e gerenciamento de sessões são tratados no back-end (ver adiante neste documento).
</p>
<p>
  No que diz respeito ao banco de dados, o processo de autenticação usa a função (<code>api.authenticate</code>), que basicamente compara o hash da senha informada no login com o hash da senha registrado na tabela <code>private.accounts</code>. Em caso de correção das informações fornecidas, a função retorna uma string com o formato <code>x-role</code>, em que <code>x</code> é o número do usuário cadastrado no sistema (<code>person_id</code> nas tabelas <code>persons</code> e <code>private.accounts</code>) e <code>role</code> é o respectivo papel (<code>person_role</code> na tabela <code>private.accounts</code>). O back-end é responsável por colocar a string num cookie e passá-lo ao cliente. A partir deste momento, as transações feitas pelo usuário logado carregam sempre esse cookie em suas requisições HTTP. O PostGraphile passa as informações contidas no cookie para o RDBMS por meio da função <a href="https://www.graphile.org/postgraphile/usage-library/#pgsettings-function"><code>pgSettings</code></a>. Durante as transações realizadas durante a sessão do usuário em questão, <code>x</code> e <code>role</code> são acessíveis, respectivamente, pela função <code>get_current_person_id()</code> e pela função (built-in) <code>current_role</code> (ou <code>current_user</code>).
</p>
<p>
  A distribuição de permissões entre os grupos de usuários (roles)é dada conforme a tabela a seguir:
</p>
<table>
  <thead>
    <tr>
      <th>Permissão</th>
      <th>administrator</th>
      <th>supervisor</th>
      <th>inspector</th>
      <th>employee</th>
      <th>visitor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td></td>
      <td>:heavy_check_mark:</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>    <tr>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>




<h3>📁 backend</h3>

<p>
  O servidor web, desenvolvido em <a href="https://nodejs.org/en/">Node.js</a>, é uma camada intermediária entre o banco de dados e a interface do usuário.
  Suas principais funcionalidades são:
</p>
<ul>
  <li>
    expor a página web ao usuário do sistema (protocolo HTTP ou HTTPS);
  </li>
  <li>
    realizar a lógica de autenticação e geração dos cookies de sessão de usuário;
  </li>
  <li>
    executar rotinas periódicas (ex.: backups);
  </li>
  <li>
    manter um sistema de diretórios e arquivos vinculados às entidades do banco de dado (ex.: manuais de equipamentos, fotos de edifícios, plantas arquitetônicas para uma tarefa etc.)
  </li>
</ul>
<p>
  Algumas das bibliotecas utilizadas e suas respectivas funções no sistema:
</p>
<ul>
  <li>
    <a href="http://expressjs.com/">Express</a>, como framework web para Node.js;
  </li>
  <li>
    <a href="http://www.passportjs.org/">Passport</a>, para autenticação de usuários;
  </li>
  <li>
    <a href="https://www.npmjs.com/package/cookie-session">Cookie-Session</a>, para gerar e gerenciar cookies de sessão de usuários;
  </li>
  <li>
    <a href="https://www.graphile.org/">PostGraphile</a>, como API para queries e mutations em GraphQL ao banco de dados;
  </li>
  <li>
    <a href="https://www.npmjs.com/package/morgan">Morgan</a>, para log de requisições HTTP;
  </li>
  <li>
    <a href="https://www.npmjs.com/package/cron">Cron</a>, para agendar rotinas periódicas necessárias ao back-end;
  </li>
  <li>
    <a href="https://www.npmjs.com/package/graphql-upload">GraphQL-Upload</a>, para leitura de arquivos enviados em uploads;
  </li>
  <li>
    <a href="https://node-postgres.com/">Node-Postgres</a>, como interface de acesso ao banco de dados.
  </li>
</ul>

<p>
  No diretório <a href="./backend/tests">/backend/tests</a> são testadas as funções que modificam uma (ou mais) tabela(s) do banco de dados (isto é, que contenham os comandos INSERT, UPDATE ou DELETE), e que são expostas aos usuários do sistema (isto é, as mutations que no front-end serão usadas pelo Apollo-Client). Em alguns casos, a execução de tais funções ativam a execução de alguns triggers de checagem (por exemplo, um trigger que verifica se a quantidade de determinado material que está sendo vinculado a uma tarefa é superior à disponível). Nos casos em que tais triggers impedem a operação, uma exceção é lançada (‘raise exception’), retornando uma mensagem de erro. Os testes elaborados verificam:
  <ul>
    <li>
      (1)	os casos normais (a modificação no banco de dados e o envio da respectiva resposta ao usuário são realizados com sucesso); e
    </li>
    <li>
      (2)	os casos em que um trigger de checagem impede a modificação no banco de dados (uma mensagem de erro adequada é retornada para o usuário).
    </li>
  </ul>
</p>

<h3>📁 frontend</h3>

<p>
  A interface ao usuário é uma página web, desenvolvida com um visual moderno e agradável, navegação intuitiva e responsividade (ajuste automático à largura da tela do dispositivo utilizado pelo usuário).
</p>
<p>
  A base inicial do código-fonte deste diretório corresponde à single page application (SPA) gerada por meio do <a href="https://create-react-app.dev/">Create React App</a>.
</p>
<p>
  Os componentes das páginas são criados em <a href="https://reactjs.org/">React</a> e outras bibliotecas compatíveis.
</p>
<p>
  O gerenciamento do histórico de navegação e roteamento são realizados com o <a href="https://reacttraining.com/react-router/web/guides/quick-start">React-Router</a>.
</p>
<p>
  <em>Queries</em> e <em>mutations</em> em GraphQL, via APIs da biblioteca <a href="https://www.apollographql.com/docs/react/">Apollo-Client</a>, são usadas para <em>data fetching</em> e criação/atualização de entidades do banco de dados (tarefas, ativos, contratos, especificações técnicas etc.).
</p>

<h2>Desenvolvedores</h2>

<ul>
  <li><a href="https://github.com/Serafabr">Serafabr</a></li>
  <li><a href="https://github.com/hzlopes">hzlopes</a></li>
  <li><a href="https://github.com/mathbraga">mathbraga</a></li>
</ul>
