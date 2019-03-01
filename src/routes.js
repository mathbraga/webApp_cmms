import React from "react";
import MainPage from "./containers/MainPage";

const Energy = React.lazy(() => import("./containers/Energy"));
const Water = React.lazy(() => import("./containers/Water"));


// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, name: "Início", component: MainPage },
  { path: "/consumo/energia", name: "Energia elétrica", component: Energy },
  { path: "/consumo/agua", name: "Agua e esgoto", component: Water }
];

export default routes;
