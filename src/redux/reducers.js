import { combineReducers } from "redux";
// import { connectRouter } from "connected-react-router";
import { LOGIN_REQUEST, LOGIN_SUCCESS, LOGIN_FAILURE, LOGOUT_REQUEST, LOGOUT_SUCCESS, LOGOUT_FAILURE, QUERY_REQUEST, QUERY_SUCCESS, QUERY_FAILURE, QUERY_RESET } from "./actions";

function auth(
  state = {
    session: false,
    isFetching: false,
    loginError: false
  }, action) {

  switch (action.type) {

    case LOGIN_REQUEST:
      return Object.assign({}, state, {
        isFetching: true,
        loginError: false
      });

    case LOGIN_SUCCESS:
      return Object.assign({}, state, {
        session: action.session,
        isFetching: false,
        loginError: false
      });

    case LOGIN_FAILURE:
      return Object.assign({}, state, {
        isFetching: false,
        loginError: true
      });

    case LOGOUT_REQUEST:
      return Object.assign({}, state, {
        isFetching: true
      });
    
    case LOGOUT_SUCCESS:
      return Object.assign({}, state, {
        session: false,
        isFetching: false
      });

    case LOGOUT_FAILURE:
      return Object.assign({}, state, {
        isFetching: false,
        logoutError: true
      });

    default:
      return state;
  }
}

function energy(state = {
  resultObject: {},
  isFetching: false,
  queryError: false,
  errorMessage: "",
  showResult: false
}, action) {
  switch(action.type){
    case QUERY_REQUEST:
      return Object.assign({}, state, {
        isFetching: true,
        queryError: false,
        message: "Consultando banco de dados...",
        showResult: false
      });
    case QUERY_SUCCESS: 
      return Object.assign({}, state, {
        resultObject: action.resultObject,
        isFetching: false,
        queryError: false,
        message: "",
        showResult: true
      });
    case QUERY_FAILURE:
      return Object.assign({}, state, {
        isFetching: false,
        queryError: true,
        message: action.message,
        showResult: false
      });
    case QUERY_RESET:
      return Object.assign({}, state, {
        resultObject: {},
        isFetching: false,
        queryError: false,
        message: "",
        showResult: false
      });
    default: 
        return state;
  }
}

// With connected-react-router:
const rootReducer = (/*history*/) => combineReducers({
  // router: connectRouter(history),
  auth
  // energy
});

export default rootReducer;