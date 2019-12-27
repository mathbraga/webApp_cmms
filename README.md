<h1>webSINFRA</h1>

<p>This web application is the computerized management system (CMMS) for the maintenance department of the Federal Senate of Brazil.</p>

<h2>Desenvolvedores</h2>
<ul>
  <li><a href="https://github.com/Serafabr">Serafabr</a></li>
  <li><a href="https://github.com/hzlopes">hzlopes</a></li>
  <li><a href="https://github.com/mathbraga">mathbraga</a></li>
</ul>

<h2>Arquitetura</h2>

<p>O desenvolvimento do sistema deverá fazer uso de ferramentas e bibliotecas modernas,disponibilizadas em código aberto (open source) sempre que possível, permitindo a sua contínua evolução.</p>


<h2>Back-end</h2>

<p>O back-end será formado por duas camadas básicas:</p>
  <ul>
    <li>servidor web; e</li>
    <li>sistema gerenciador de banco de dados relacional (RDBMS)</li>
  </ul>

<p>
  As principais funcionalidades da camada de servidor web são: (1) expor a página web ao usuário do sistema (protocolo HTTP ou HTTPS); (2) realizar a lógica de autenticação e geração dos cookies de sessão de usuário; (3) executar rotinas periódicas (ex.: backups e atualizações via APIs); e (4) manter um sistema de diretórios e arquivos vinculados às entidades do banco de dados (ex.: manuais de equipamentos, fotos de edifícios, plantas arquitetônicas etc.).
  O framework Express constituirá a base dessa camada. Bibliotecas compatíveis poderão ser
  acrescentadas para agregar outras funcionalidades (ex.: Passport para autenticação, Postgraphile como API de acesso ao banco de dados etc.)
</p>

<p>
  As principais funcionalidades do RDBMS são: (1) garantir a atomicidade, consistência, isolamento e durabilidade dos dados inseridos no sistema; e (2) realizar as operações de criação, leitura, atualização e remoção (CRUD) nas tabelas, conforme as permissões definidas para cada usuário (ou grupo de usuários) do sistema.
  Será utilizado o banco de dados PostgreSQL.
</p>

<h2>Front-end</h2>

<p>
A interface ao usuário disponibilizada pelo sistema terá a forma de uma página web, que deverá possuir um visual moderno e agradável, com navegação intuitiva e responsividade (ajuste automático à largura da tela do dispositivo utilizado pelo usuário).
O front-end terá como base a estrutura do Create React App.
Os componentes das páginas serão criados com a biblioteca React.
O gerenciamento do histórico de navegação e o roteamento serão realizados com o React-Router.
Outras bibliotecas compatíveis com esta arquitetura poderão ser incluídas.
</p>

<h1>Tabela de entidades no banco de dados</h1>

<table>
  <thead>
    <tr>
      <th>Entidade no banco de dados</th>
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

<h2>Grafo das relações entre as entidades</h2> 

<p>A imagem abaixo mostra as principais relações entre as entidades existentes no banco de dados.</p>
<div align="center">
  <img src="cmms.jpg"/>
</div>