import React from "react";
import MainPage from "./containers/MainPage";

const Energy = React.lazy(() => import("./containers/Energy"));
const EnergyResults = React.lazy(() => import("./containers/Energy/EnergyResults"));
const EnergyResultOM = React.lazy(() => import("./containers/Energy/EnergyResultOM"));
const EnergyResultOP = React.lazy(() => import("./containers/Energy/EnergyResultOP"));
const EnergyResultAM = React.lazy(() => import("./containers/Energy/EnergyResultAM"));
const EnergyResultAP = React.lazy(() => import("./containers/Energy/EnergyResultAP"));

const LoginPage = React.lazy(() => import("./containers/Login/LoginPage"));
const SignUpPage = React.lazy(() => import("./containers/SignUp/SignUpPage"));



// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, name: "Início", component: MainPage },
  { path: "/login", name: "Login", component: LoginPage },
  { path: "/signup", name: "Sign up", component: SignUpPage },
  { path: "/consumo/energia", name: "Energia elétrica", component: Energy },
  { path: "/consumo/energia/resultados", name: "Resultados", component: EnergyResults },
  { path: "/consumo/energia/resultados/OM", name: "OM", component: EnergyResultOM },
  { path: "/consumo/energia/resultados/OP", name: "OP", component: EnergyResultOP },
  { path: "/consumo/energia/resultados/AM", name: "AM", component: EnergyResultAM },
  { path: "/consumo/energia/resultados/AP", name: "AP", component: EnergyResultAP },
];

export default routes;
