import { createBrowserHistory } from "history";
import { routerMiddleware } from "connected-react-router";
import { createStore, applyMiddleware, compose } from "redux";
import thunk from "redux-thunk";
import createRootReducer from "./reducers";

export const history = createBrowserHistory();

// Using ONLY devtools:
const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
// const store = createStore(
//   rootReducer,
//   composeEnhancers(
//     applyMiddleware(thunk)
// ));
// export default store;

// Using devtools AND connected-react-router:
export default function configureStore(/*preloadedState*/) {
  const store = createStore(
    createRootReducer(history), // root reducer with router state
    /*preloadedState,*/
    composeEnhancers(
      applyMiddleware(
        routerMiddleware(history), // for dispatching history actions
        thunk // ... other middlewares ...
      ),
    ),
  );

  return store;
}