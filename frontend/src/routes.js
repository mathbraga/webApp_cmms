import React from "react";
import MainPage from "./containers/MainPage";

const ConsumptionMonitor = React.lazy(() => import("./containers/ConsumptionMonitor"));
const Dashboard = React.lazy(() => import("./containers/Dashboard"));
const Login = React.lazy(() => import("./containers/Authentication/Login"));
const RegisterUser = React.lazy(() => import("./containers/Authentication/RegisterUser"));
const Assets = React.lazy(() => import("./containers/Assets"));
const WorkOrders = React.lazy(() => import("./containers/Maintenance/WorkOrders"));
const NewWorkOrderForm = React.lazy(() => import("./containers/Maintenance/NewWorkOrderForm"));
const WorkOrderView = React.lazy(() => import("./containers/Maintenance/WorkOrderView"));
const AssetInfo = React.lazy(() => import("./containers/Assets/AssetInfo"));
const Error404 = React.lazy(() => import("./containers/MainPage/Error404"));

// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, component: MainPage },
  { path: "/painel", name: "Painel", component: Dashboard },
  { path: "/login", name: "Login", component: Login },
  { path: "/cadastro", name: "Cadastro", component: RegisterUser },
  { path: "/energia", name: "Energia elétrica", component: ConsumptionMonitor },
  { path: "/agua", name: "Água", component: ConsumptionMonitor },
  { path: "/ativos/view/:id", exact: false, name: "Ativo", component: AssetInfo },
  { path: "/ativos/edificios", name: "Ativos", component: Assets },
  { path: "/ativos/equipamentos", name: "Ativos", component: Assets },
  { path: "/manutencao/os", exact: true, name: "Ordens de serviços", component: WorkOrders },
  { path: "/manutencao/os/nova", exact: true, name: "Nova OS", component: NewWorkOrderForm },
  { path: "/manutencao/os/view/:id", exact: false, name: "OS", component: WorkOrderView },
  { path: "/erro404", exact: true, name: "Erro 404", component: Error404 },
];

export default routes;
