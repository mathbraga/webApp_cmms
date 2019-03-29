import React from "react";
import MainPage from "./containers/MainPage";

const Energy = React.lazy(() => import("./containers/Energy"));
const EnergyResultOM = React.lazy(() => import("./containers/Energy/EnergyResultOM"));
const EnergyResultOP = React.lazy(() => import("./containers/Energy/EnergyResultOP"));
const EnergyResultAM = React.lazy(() => import("./containers/Energy/EnergyResultAM"));
const EnergyResultAP = React.lazy(() => import("./containers/Energy/EnergyResultAP"));

const Water = React.lazy(() => import("./containers/Water"));


// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, name: "Início", component: MainPage },
  { path: "/consumo/energia", name: "Energia elétrica", component: Energy },
  { path: "/consumo/energia/resultados/OM", name: "Resultados da pesquisa", component: EnergyResultOM },
  { path: "/consumo/energia/resultados/OP", name: "Resultados da pesquisa", component: EnergyResultOP },
  { path: "/consumo/energia/resultados/AM", name: "Resultados da pesquisa", component: EnergyResultAM },
  { path: "/consumo/energia/resultados/AP", name: "Resultados da pesquisa", component: EnergyResultAP },
  { path: "/consumo/agua", name: "Água e esgoto", component: Water }
];

export default routes;
