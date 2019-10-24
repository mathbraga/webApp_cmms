import React from "react";
import MainPage from "./containers/MainPage";

const ConsumptionMonitor = React.lazy(() => import("./containers/ConsumptionMonitor"));
const Dashboard = React.lazy(() => import("./containers/Dashboard"));
const Login = React.lazy(() => import("./containers/Authentication/Login"));
const RegisterUser = React.lazy(() => import("./containers/Authentication/RegisterUser"));
const Profile = React.lazy(() => import("./containers/Authentication/Profile"));
const Assets = React.lazy(() => import("./containers/Assets"));
const WorkOrders = React.lazy(() => import("./containers/Maintenance/WorkOrders"));
const NewWorkOrderForm = React.lazy(() => import("./containers/Maintenance/NewWorkOrderForm"));
const WorkOrderView = React.lazy(() => import("./containers/Maintenance/WorkOrderView"));
const Contracts = React.lazy(() => import("./containers/Contracts/ContractList"));
const ContractView = React.lazy(() => import("./containers/Contracts/ContractView"));
const Materials = React.lazy(() => import("./containers/Contracts/MaterialList"));
const MaterialView = React.lazy(() => import("./containers/Contracts/MaterialView"));
const AssetInfo = React.lazy(() => import("./containers/Assets/AssetInfo"));
const FacilitiesForm = React.lazy(() => import("./containers/Assets/FacilitiesForm"));
const EquipmentsForm = React.lazy(() => import("./containers/Assets/EquipmentsForm"));
const OrderForm = React.lazy(() => import("./containers/Maintenance/OrderForm"));
const Error404 = React.lazy(() => import("./containers/MainPage/Error404"));
const Groups = React.lazy(() => import("./containers/Teams/GroupList"));
const GroupView = React.lazy(() => import("./containers/Teams/GroupView"));
const Persons = React.lazy(() => import("./containers/Teams/PersonList"));
const PersonView = React.lazy(() => import("./containers/Teams/PersonView"));

// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, component: MainPage },
  { path: "/painel", name: "Painel", component: Dashboard },
  { path: "/login", name: "Login", component: Login },
  { path: "/cadastro", name: "Cadastro", component: RegisterUser },
  { path: "/perfil", name: "Perfil", component: Profile },
  // { path: "/energia", name: "Energia elétrica", component: ConsumptionMonitor },
  // { path: "/agua", name: "Água", component: ConsumptionMonitor },
  { path: "/ativos/view/:id", exact: false, name: "Ativo", component: AssetInfo },
  { path: "/ativos/edificios", exact: true, name: "Ativos", component: Assets },
  { path: "/ativos/equipamentos", exact: true, name: "Ativos", component: Assets },
  { path: "/ativos/edificios/novo", exact: true, name: "Novo Edificio", component: FacilitiesForm },
  { path: "/ativos/equipamentos/novo", exact: true, name: "Novo Equipamento", component: EquipmentsForm },
  { path: "/manutencao/os", exact: true, name: "Ordens de serviços", component: WorkOrders },
  { path: "/manutencao/os/nova", exact: true, name: "Nova OS", component: OrderForm },
  { path: "/manutencao/os/view/:id", exact: false, name: "OS", component: WorkOrderView },
  { path: "/gestao/contratos", exact: true, name: "Contratos", component: Contracts },
  { path: "/gestao/contratos/view/:id", exact: false, name: "Contrato", component: ContractView },
  { path: "/gestao/servicos", exact: true, name: "Servicos", component: Materials },
  { path: "/gestao/servicos/view/:id", exact: false, name: "Servico", component: MaterialView },
  { path: "/equipes/grupos", exact: true, name: "Servicos", component: Groups },
  { path: "/equipes/grupo/view/:id", exact: false, name: "Servico", component: GroupView },
  { path: "/equipes/pessoas", exact: true, name: "Servicos", component: Persons },
  { path: "/equipes/pessoa/view/:id", exact: false, name: "Servico", component: PersonView },
  { path: "/erro404", exact: true, name: "Erro 404", component: Error404 }
];

export default routes;
