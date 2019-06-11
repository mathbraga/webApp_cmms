// import "react-app-polyfill/ie9"; // For IE 9, 10, 11 support
import "babel-polyfill";
import "react-app-polyfill/ie11";
import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import * as serviceWorker from "./serviceWorker";
import { Provider } from "react-redux";
import configureStore, { history } from "./redux/store";

const store = configureStore(/* preloaded state (optional) */);

const renderApp = () => ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById("root")
);

// Enabling hot reload for React components inside App:
if(process.env.NODE_ENV !== "production" && module.hot){
  module.hot.accept("./App", renderApp);
}

renderApp();


// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: http://bit.ly/CRA-PWA
serviceWorker.unregister();
