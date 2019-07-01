import React from "react";
import MainPage from "./containers/MainPage";

const ConsumptionMonitor = React.lazy(() => import("./containers/ConsumptionMonitor"));
const Dashboard = React.lazy(() => import("./containers/Dashboard"));
const Login = React.lazy(() => import("./containers/Authentication/Login"));
const SignUp = React.lazy(() => import("./containers/Authentication/SignUp"));
const Assets = React.lazy(() => import("./containers/Assets"));
const WorkRequests = React.lazy(() => import("./containers/Maintenance/WorkRequests"));
const NewWorkRequestForm = React.lazy(() => import("./containers/Maintenance/NewWorkRequestForm"));
const WorkOrders = React.lazy(() => import("./containers/Maintenance/WorkOrders"));
const NewWorkOrderForm = React.lazy(() => import("./containers/Maintenance/NewWorkOrderForm"));
const WorkOrderView = React.lazy(() => import("./containers/Maintenance/WorkOrderView"));
const AssetView = React.lazy(() => import("./containers/Maintenance/AssetView"));
const LocalView = React.lazy(() => import("./containers/Maintenance/LocalView"));

// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, component: MainPage },
  { path: "/painel", name: "Painel", component: Dashboard },
  { path: "/login", name: "Login", component: Login },
  { path: "/cadastro", name: "Cadastro", component: SignUp },
  { path: "/energia", name: "Energia elétrica", component: ConsumptionMonitor },
  { path: "/agua", name: "Água", component: ConsumptionMonitor },
  { path: "/ativos", exact: true, name: "Ativos", component: Assets },
  { path: "/manutencao/solicitacoes", exact: true, name: "Solicitações", component: WorkRequests },
  { path: "/manutencao/solicitacoes/nova", exact: true, name: "Nova solicitação", component: NewWorkRequestForm },
  { path: "/manutencao/os", exact: true, name: "Ordens de serviços", component: WorkOrders },
  { path: "/manutencao/os/nova", exact: true, name: "Nova OS", component: NewWorkOrderForm },
  { path: "/manutencao/os/view/:id", exact: false, name: "OS", component: WorkOrderView },
  { path: "/ativos/view/:id", exact: false, name: "Ativo", component: AssetView },
  { path: "/local/view/:id", exact: false, name: "Local", component: LocalView }
];

export default routes;
