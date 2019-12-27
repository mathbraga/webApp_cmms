<h1>webSINFRA</h1>

<p>
  Esta aplicação web é o sistema de gestão de manutenção da Secretaria de Infraestrutura do Senado Federal.
</p>

<h2>Arquitetura</h2>

<p>
  O desenvolvimento do sistema deverá fazer uso de ferramentas e bibliotecas modernas,disponibilizadas em código aberto (open source) sempre que possível, permitindo a sua contínua evolução.
</p>

<h3>Banco de Dados</h3>

<p>
  O sistema gerenciador de banco de dados relacional (RDBMS) é o <a href="https://www.postgresql.org/">PostgreSQL</a>.
  São consideradas as seguintes entidades:
</p>

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
  <img src="cmms.jpg"/>
</div>

<h3>Back-end</h3>

<p>
  O servidor web, desenvolvido em <a href="https://nodejs.org/en/">Node.js</a>, é uma camada intermediária entre o bando de dados e a interface do usuário.
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

<h3>Front-end</h3>

<p>
  A interface ao usuário é uma página web, desenvolvida para possuir um visual moderno e agradável, com navegação intuitiva e responsividade (ajuste automático à largura da tela do dispositivo utilizado pelo usuário).
</p>
<p>
  A estrutura desta parte do projeto é baseada na single page application (SPA) gerada com a ferramenta <a href="https://create-react-app.dev/">Create React App</a>.
  Os componentes das páginas são criados com a biblioteca <a href="https://reactjs.org/">React</a> e outras.
  O gerenciamento do histórico de navegação e roteamento são realizados com o <a href="https://reacttraining.com/react-router/web/guides/quick-start">React-Router</a>.
</p>

<h2>Desenvolvedores</h2>

<ul>
  <li><a href="https://github.com/Serafabr">Serafabr</a></li>
  <li><a href="https://github.com/hzlopes">hzlopes</a></li>
  <li><a href="https://github.com/mathbraga">mathbraga</a></li>
</ul>
