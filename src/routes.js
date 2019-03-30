import React from "react";
import MainPage from "./containers/MainPage";

const Energy = React.lazy(() => import("./containers/Energy"));
const EnergyResults = React.lazy(() => import("./containers/Energy/EnergyResults"));
const EnergyResultOM = React.lazy(() => import("./containers/Energy/EnergyResultOM"));
const EnergyResultOP = React.lazy(() => import("./containers/Energy/EnergyResultOP"));
const EnergyResultAM = React.lazy(() => import("./containers/Energy/EnergyResultAM"));
const EnergyResultAP = React.lazy(() => import("./containers/Energy/EnergyResultAP"));

const Water = React.lazy(() => import("./containers/Water"));


// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, name: "Início", component: MainPage },
  { path: "/consumo/energia", exact: true, name: "Energia elétrica", component: Energy },
  { path: "/consumo/energia/resultados", exact: true, name: "Resultados", component: EnergyResults },
  { path: "/consumo/energia/resultados/OM", exact: true, name: "OM", component: EnergyResultOM },
  { path: "/consumo/energia/resultados/OP", exact: true, name: "OP", component: EnergyResultOP },
  { path: "/consumo/energia/resultados/AM", exact: true, name: "AM", component: EnergyResultAM },
  { path: "/consumo/energia/resultados/AP", exact: true, name: "AP", component: EnergyResultAP },
  { path: "/consumo/agua", exact: true, name: "Água e esgoto", component: Water }
];

export default routes;
