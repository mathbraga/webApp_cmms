import { createBrowserHistory } from "history";
// import { routerMiddleware } from "connected-react-router";
import { createStore, applyMiddleware, compose } from "redux";
import thunk from "redux-thunk";
import rootReducer from "./reducers";

// Using devtools AND connected-react-router:

export const history = createBrowserHistory();

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

export default function configureStore(/*preloadedState*/) {
  const store = createStore(
    rootReducer(/*history*/), // root reducer
    /*preloaded state (optional) */
    composeEnhancers(
      applyMiddleware(
        // routerMiddleware(history), // for dispatching history actions
        thunk // ... other middlewares ...
      ),
    ),
  );
  
  // Enabling hot reload for the Redux state:
  if(process.env.NODE_ENV !== "production" && module.hot){
    module.hot.accept("./reducers", () => store.replaceReducer(rootReducer));
  }

  return store;
}