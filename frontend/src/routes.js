import React from "react";
import MainPage from "./views/MainPage";
import paths from './paths';

const Dashboard = React.lazy(() => import("./views/Dashboard"));
const Login = React.lazy(() => import("./views/Authentication/Login"));
const Profile = React.lazy(() => import("./views/Authentication/Profile"));
const Facilities = React.lazy(() => import("./views/Assets/Facilities/Facilities"));
const Facility = React.lazy(() => import("./views/Assets/Facility/Facility"));
const FacilityForm = React.lazy(() => import("./views/Assets/FacilityForm/FacilityForm"));
const Appliances = React.lazy(() => import("./views/Assets/Appliances/Appliances"));
const Appliance = React.lazy(() => import("./views/Assets/Appliance/Appliance"));
const ApplianceForm = React.lazy(() => import("./views/Assets/ApplianceForm/ApplianceForm"));
const Tasks = React.lazy(() => import("./views/Maintenance/Tasks/Tasks"));
const Task = React.lazy(() => import("./views/Maintenance/Task/Task"));
const TaskForm = React.lazy(() => import("./views/Maintenance/TaskForm/TaskForm"));
const Contracts = React.lazy(() => import("./views/Contracts/Contracts/Contracts"));
const Contract = React.lazy(() => import("./views/Contracts/Contract/Contract"));
const Specs = React.lazy(() => import("./views/Contracts/Specifications/Specifications"));
const Spec = React.lazy(() => import("./views/Contracts/Specification/Specification"));
const Teams = React.lazy(() => import("./views/Teams/Teams/Teams"));
const Persons = React.lazy(() => import("./views/Teams/Persons/Persons"));
const NoView = <h1>NoView!</h1>

const routes = [
  { path: '/', exact: true, name: "Página Principal", component: MainPage },
  { path: '/painel', name: "Painel", component: Dashboard },
  { path: "/login", name: "Login", component: Login },
  { path: "/perfil", name: "Perfil", component: Profile },

  { path: paths.facility.all, exact: true, name: "Edifícios", component: Facilities },
  { path: paths.facility.one, exact: true, name: "Edifício", component: Facility },
  { path: paths.facility.update, exact: true, name: "Edifício", component: FacilityForm, props: { mode: 'update' } },
  { path: paths.facility.create, exact: true, name: "Novo Edificio", component: FacilityForm, props: { mode: 'create' } },
 
  { path: "/ativos/equipamentos", exact: true, name: "Equipamentos", component: Appliances },
  { path: "/ativos/equipamento/view/:id", exact: false, name: "Equipamento", component: Appliance },
  { path: "/ativos/equipamento/edit/:id", exact: false, name: "Equipamento", component: ApplianceForm, props: { editMode: true } },
  { path: "/ativos/equipamentos/novo", exact: true, name: "Novo Equipamento", component: ApplianceForm },

  { path: "/manutencao/os", exact: true, name: "Ordens de serviços", component: Tasks },
  { path: "/manutencao/os/view/:id", exact: false, name: "Ordem de Serviço", component: Task },
  { path: "/manutencao/os/edit/:id", exact: false, name: "Ordem de Serviço", component: NoView },
  { path: "/manutencao/os/nova", exact: true, name: "Nova OS", component: TaskForm },

  { path: "/gestao/contratos", exact: true, name: "Contratos", component: Contracts },
  { path: "/gestao/contratos/view/:id", exact: false, name: "Contrato", component: Contract },
  { path: "/gestao/contratos/edit/:id", exact: false, name: "Contrato", component: NoView },
  { path: "/gestao/servicos", exact: true, name: "Servicos", component: Specs },
  { path: "/gestao/servicos/view/:id", exact: false, name: "Servico", component: Spec },
  
  { path: "/equipes/grupos", exact: true, name: "Grupos", component: Teams },
  { path: "/equipes/grupo/view/:id", exact: false, name: "Grupo", component: NoView },
  { path: "/equipes/grupo/edit/:id", exact: false, name: "Grupo", component: NoView },
  { path: "/equipes/pessoas", exact: true, name: "Pessoas", component: Persons },
  { path: "/equipes/pessoa/view/:id", exact: false, name: "Pessoa", component: NoView },
  { path: "/equipes/pessoa/edit/:id", exact: false, name: "Pessoa", component: NoView },
];

export default routes;
