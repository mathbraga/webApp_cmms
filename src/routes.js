import React from "react";
import MainPage from "./containers/MainPage";

const ConsumptionMonitor = React.lazy(() => import("./containers/ConsumptionMonitor"));
const Dashboard = React.lazy(() => import("./containers/Dashboard"));
const Login = React.lazy(() => import("./containers/Authentication/Login"));
const SignUp = React.lazy(() => import("./containers/Authentication/SignUp"));
const Assets = React.lazy(() => import("./containers/Assets"));

// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, component: MainPage },
  { path: "/painel", name: "Painel", component: Dashboard },
  { path: "/login", name: "Login", component: Login },
  { path: "/cadastro", name: "Cadastro", component: SignUp },
  { path: "/energia", name: "Energia elétrica", component: ConsumptionMonitor },
  { path: "/agua", name: "Água", component: ConsumptionMonitor },
  { path: "/ativos", name: "Ativos", component: Assets },
  // { path: "/ativos/todos", name: "Todos ativos", component: Assets, options: {filter: "all"} },
  // { path: "/ativos/edificios", name: "Edifícios e áreas", component: Assets, options: {filter: "facility"} },
  // { path: "/ativos/equipamentos", name: "Equipamentos", component: Assets, options: {filter: "equipment"} },
  // { path: "/ativos/ferramentas", name: "Ferramentas", component: Assets, options: {filter: "tool"} },
  // { path: "/ativos/materiais", name: "Materiais", component: Assets, options: {filter: "supply"} }
];

export default routes;
