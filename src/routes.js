import React from "react";
import MainPage from "./containers/MainPage";
import { dbTables } from "./aws";

const ConsumptionMonitor = React.lazy(() => import("./containers/ConsumptionMonitor"));
const Dashboard = React.lazy(() => import("./containers/Dashboard"));
const Login = React.lazy(() => import("./containers/Authentication/Login"));
const SignUp = React.lazy(() => import("./containers/Authentication/SignUp"));

// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, component: MainPage },
  { path: "/painel", name: "Painel", component: Dashboard },
  { path: "/login", name: "Login", component: Login },
  { path: "/cadastro", name: "Cadastro", component: SignUp },
  { path: "/energia", name: "Energia elétrica", component: ConsumptionMonitor, options: {tableName: dbTables.energy.tableName, tableNameMeters: dbTables.energy.tableNameMeters, meterType: dbTables.energy.meterType}},
  { path: "/agua", name: "Água", component: ConsumptionMonitor, options: {tableName: dbTables.water.tableName, tableNameMeters: dbTables.water.tableNameMeters, meterType: dbTables.water.meterType}},
];

export default routes;
