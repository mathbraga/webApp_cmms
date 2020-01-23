import React from "react";
import MainPage from "./containers/MainPage";

const Dashboard = React.lazy(() => import("./containers/Dashboard"));
const Login = React.lazy(() => import("./containers/Authentication/Login"));
const Profile = React.lazy(() => import("./containers/Authentication/Profile"));
const Facilities = React.lazy(() => import("./containers/Assets/Facilities/Facilities"));
const Facility = React.lazy(() => import("./containers/Assets/Facility/Facility"));
const Appliances = React.lazy(() => import("./containers/Assets/Appliances/Appliances"));
const Appliance = React.lazy(() => import("./containers/Assets/Appliance/Appliance"));
const Tasks = React.lazy(() => import("./containers/Maintenance/Tasks/Tasks"));
const Task = React.lazy(() => import("./containers/Maintenance/Task/Task"));
const Contracts = React.lazy(() => import("./containers/ContractManagement/Contracts/Contracts"));
const Contract = React.lazy(() => import("./containers/ContractManagement/Contract/Contract"));
const Specs = React.lazy(() => import("./containers/ContractManagement/Specifications/Specifications"));
const Spec = React.lazy(() => import("./containers/ContractManagement/Specification/Specification"));
const Teams = React.lazy(() => import("./containers/HumanResources/Teams/Teams"));
const Persons = React.lazy(() => import("./containers/HumanResources/Persons/Persons"));

const NoView = <h1>NoView!</h1>

// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: '/', exact: true, name: "Página Principal", component: MainPage },
  { path: '/painel', name: "Painel", component: Dashboard },
  { path: "/login", name: "Login", component: Login },
  { path: "/perfil", name: "Perfil", component: Profile },
  { path: "/ativos/edificios", exact: true, name: "Edifícios", component: Facilities },
  { path: "/ativos/edificio/view/:id", exact: false, name: "Edifício", component: Facility },
  { path: "/ativos/edificios/novo", exact: true, name: "Novo Edificio", component: NoView },
  { path: "/ativos/equipamentos", exact: true, name: "Equipamentos", component: Appliances },
  { path: "/ativos/equipamento/view/:id", exact: false, name: "Equipamento", component: Appliance },
  { path: "/ativos/equipamentos/novo", exact: true, name: "Novo Equipamento", component: NoView },
  { path: "/manutencao/os", exact: true, name: "Ordens de serviços", component: Tasks },
  { path: "/manutencao/os/view/:id", exact: false, name: "Ordem de Serviço", component: Task },
  { path: "/manutencao/os/nova", exact: true, name: "Nova OS", component: NoView },
  { path: "/gestao/contratos", exact: true, name: "Contratos", component: Contracts },
  { path: "/gestao/contratos/view/:id", exact: false, name: "Contrato", component: Contract },
  { path: "/gestao/servicos", exact: true, name: "Servicos", component: Specs },
  { path: "/gestao/servicos/view/:id", exact: false, name: "Servico", component: Spec },
  { path: "/equipes/grupos", exact: true, name: "Grupos", component: Teams },
  { path: "/equipes/grupo/view/:id", exact: false, name: "Grupo", component: NoView },
  { path: "/equipes/pessoas", exact: true, name: "Pessoas", component: Persons },
  { path: "/equipes/pessoa/view/:id", exact: false, name: "Pessoa", component: NoView },
];

export default routes;
