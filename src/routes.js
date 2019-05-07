import React from "react";
import MainPage from "./containers/MainPage";

const Energy = React.lazy(() => import("./containers/Energy"));
const EnergyResults = React.lazy(() => import("./containers/Energy/EnergyResults"));
const EnergyResultOM = React.lazy(() => import("./containers/Energy/EnergyResultOM"));
const EnergyResultOP = React.lazy(() => import("./containers/Energy/EnergyResultOP"));
const EnergyResultAM = React.lazy(() => import("./containers/Energy/EnergyResultAM"));
const EnergyResultAP = React.lazy(() => import("./containers/Energy/EnergyResultAP"));

const Water = React.lazy(() => import("./containers/Water"));
const WaterResults = React.lazy(() => import("./containers/Water/WaterResults"));
const WaterResultOM = React.lazy(() => import("./containers/Water/WaterResultOM"));
const WaterResultOP = React.lazy(() => import("./containers/Water/WaterResultOP"));
const WaterResultAM = React.lazy(() => import("./containers/Water/WaterResultAM"));
const WaterResultAP = React.lazy(() => import("./containers/Water/WaterResultAP"));

const Login = React.lazy(() => import("./containers/Login/Login"));
const Logout = React.lazy(() => import("./containers/Logout/Logout"));
const SignUp = React.lazy(() => import("./containers/SignUp/SignUp"));

// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, name: "Início", component: MainPage },
  { path: "/login", name: "Login", component: Login },
  { path: "/logout", name: "Logout", component: Logout },
  { path: "/cadastro", name: "Cadastro", component: SignUp },
  { path: "/consumo/energia", name: "Energia elétrica", component: Energy },
  { path: "/consumo/energia/resultados", name: "Resultados", component: EnergyResults },
  { path: "/consumo/energia/resultados/OM", name: "OM", component: EnergyResultOM },
  { path: "/consumo/energia/resultados/OP", name: "OP", component: EnergyResultOP },
  { path: "/consumo/energia/resultados/AM", name: "AM", component: EnergyResultAM },
  { path: "/consumo/energia/resultados/AP", name: "AP", component: EnergyResultAP },
  { path: "/consumo/agua", name: "Água", component: Water },
  { path: "/consumo/agua/resultados", name: "Resultados", component: WaterResults },
  { path: "/consumo/agua/resultados/OM", name: "OM", component: WaterResultOM },
  { path: "/consumo/agua/resultados/OP", name: "OP", component: WaterResultOP },
  { path: "/consumo/agua/resultados/AM", name: "AM", component: WaterResultAM },
  { path: "/consumo/agua/resultados/AP", name: "AP", component: WaterResultAP }
];

export default routes;
