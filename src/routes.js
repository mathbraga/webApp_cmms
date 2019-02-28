import React from "react";
import MainPage from "./containers/MainPage";

const Energy = React.lazy(() => import("./containers/Energy"));

// https://github.com/ReactTraining/react-router/tree/master/packages/react-router-config
const routes = [
  { path: "/", exact: true, name: "Home", component: MainPage },
  { path: "/consumo/energia", name: "Energia Elétrica", component: Energy },
  { path: "/consumo/agua", name: "Agua e Esgoto" }
];

export default routes;
