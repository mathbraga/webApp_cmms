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
const Materials = React.lazy(() => import("./containers/Contracts/MaterialList"));
const AssetInfo = React.lazy(() => import("./containers/Assets/AssetInfo"));
const FacilitiesForm = React.lazy(() => import("./containers/Assets/FacilitiesForm"));
const EquipmentsForm = React.lazy(() => import("./containers/Assets/EquipmentsForm"));
const OrderForm = React.lazy(() => import("./containers/Maintenance/OrderForm"));
const Error404 = React.lazy(() => import("./containers/MainPage/Error404"));

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
  { path: "/gestao/contratos", exact: true, name: "Ordens de serviços", component: Contracts },
  { path: "/gestao/servicos", exact: true, name: "Ordens de serviços", component: Materials },
  { path: "/erro404", exact: true, name: "Erro 404", component: Error404 }
];

export default routes;
