import React from "react";
import MainPage from "./containers/MainPage";

const ConsumptionMonitor = React.lazy(() => import("./containers/ConsumptionMonitor"));
const Login = React.lazy(() => import("./containers/Authentication/Login"));
const Logout = React.lazy(() => import("./containers/Authentication/Logout"));
const SignUp = React.lazy(() => import("./containers/Authentication/SignUp"));

// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, name: "Início", component: MainPage },
  { path: "/login", name: "Login", component: Login },
  { path: "/logout", name: "Logout", component: Logout },
  { path: "/cadastro", name: "Cadastro", component: SignUp },
  { path: "/consumo/energia", name: "Energia elétrica", component: ConsumptionMonitor, options: {tableName: "CEBteste", tableNameMeters: "CEB-Medidoresteste", meterType: "1"}},
  { path: "/consumo/agua", name: "Água", component: ConsumptionMonitor, options: {tableName: "CAESB", tableNameMeters: "CAESB-Medidores", meterType: "2"} }
];

export default routes;
