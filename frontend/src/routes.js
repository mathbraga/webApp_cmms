import React from "react";
import MainPage from "./containers/MainPage";
import paths from "./paths";

const ConsumptionMonitor = React.lazy(() => import("./containers/ConsumptionMonitor"));
const Dashboard = React.lazy(() => import("./containers/Dashboard"));
const Login = React.lazy(() => import("./containers/Authentication/Login"));
const Error404 = React.lazy(() => import("./containers/MainPage/Error404"));
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

// OLD ROUTES
// const RegisterUser = React.lazy(() => import("./containers/Authentication/RegisterUser"));
const Profile = React.lazy(() => import("./containers/Authentication/Profile"));
const Assets = React.lazy(() => import("./containers/Assets"));
const WorkOrders = React.lazy(() => import("./containers/Maintenance/WorkOrders"));
const WorkOrderView = React.lazy(() => import("./containers/Maintenance/WorkOrderView"));
const ContractView = React.lazy(() => import("./containers/Contracts/ContractView"));
const SpecView = React.lazy(() => import("./containers/Contracts/SpecView"));
const AssetInfo = React.lazy(() => import("./containers/Assets/AssetInfo"));
const FacilitiesForm = React.lazy(() => import("./containers/Assets/FacilitiesForm"));
const EquipmentsForm = React.lazy(() => import("./containers/Assets/EquipmentsForm"));
const OrderForm = React.lazy(() => import("./containers/Maintenance/OrderForm"));
const GroupView = React.lazy(() => import("./containers/Teams/GroupView"));
const PersonView = React.lazy(() => import("./containers/Teams/PersonView"));

// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: paths.HOME, exact: true, component: MainPage },
  { path: paths.DASHBOARD, name: "Painel", component: Dashboard },
  { path: "/login", name: "Login", component: Login },
  // { path: "/cadastro", name: "Cadastro", component: RegisterUser },
  { path: "/perfil", name: "Perfil", component: Profile },
  { path: "/energia", name: "Energia elétrica", component: ConsumptionMonitor },
  { path: "/agua", name: "Água", component: ConsumptionMonitor },
  { path: "/ativos/edificio/view/:id", exact: false, name: "Edifício", component: Facility },
  { path: "/ativos/equipamento/view/:id", exact: false, name: "Equipamento", component: Appliance },
  { path: "/ativos/edificios", exact: true, name: "Ativos", component: Facilities },
  { path: "/ativos/equipamentos", exact: true, name: "Ativos", component: Appliances },
  { path: "/ativos/edificios/novo", exact: true, name: "Novo Edificio", component: FacilitiesForm },
  { path: "/ativos/equipamentos/novo", exact: true, name: "Novo Equipamento", component: EquipmentsForm },
  { path: "/manutencao/os", exact: true, name: "Ordens de serviços", component: Tasks },
  { path: "/manutencao/os/nova", exact: true, name: "Nova OS", component: OrderForm },
  { path: "/manutencao/os/view/:id", exact: false, name: "OS", component: Task },
  { path: "/gestao/contratos", exact: true, name: "Contratos", component: Contracts },
  { path: "/gestao/contratos/view/:id", exact: false, name: "Contrato", component: Contract },
  { path: "/gestao/servicos", exact: true, name: "Servicos", component: Specs },
  { path: "/gestao/servicos/view/:id", exact: false, name: "Servico", component: Spec },
  { path: "/equipes/grupos", exact: true, name: "Servicos", component: Teams },
  { path: "/equipes/grupo/view/:id", exact: false, name: "Servico", component: GroupView },
  { path: "/equipes/pessoas", exact: true, name: "Servicos", component: Persons },
  { path: "/equipes/pessoa/view/:id", exact: false, name: "Servico", component: PersonView },
  { path: "/erro404", exact: true, name: "Erro 404", component: Error404 },
];

export default routes;
