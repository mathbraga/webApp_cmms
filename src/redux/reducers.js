import { combineReducers } from "redux";
import { LOGIN_REQUEST, LOGIN_SUCCESS, LOGIN_FAILURE, LOGOUT_REQUEST, LOGOUT_SUCCESS, LOGOUT_FAILURE } from "./actions";

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
        isFetching: false
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

const rootReducer = combineReducers({
  auth
});

export default rootReducer;