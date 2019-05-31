import { combineReducers } from "redux";
import { LOGIN_REQUEST, LOGIN_SUCCESS, LOGIN_FAILURE, LOGOUT_REQUEST, LOGOUT_SUCCESS, LOGOUT_FAILURE } from "./actions";

function userSession(
  state = {
    userSession: false,
    isFetching: false
  }, action) {

  switch (action.type) {

    case LOGIN_REQUEST:
      return Object.assign({}, state, {
        isFetching: true
      });

    case LOGIN_SUCCESS:
      return Object.assign({}, state, {
        userSession: action.userSession,
        isFetching: false
      });

    case LOGIN_FAILURE:
      return Object.assign({}, state, {
        isFetching: false
      });

    case LOGOUT_REQUEST:
      return Object.assign({}, state, {
        isFetching: true
      });
    
    case LOGOUT_SUCCESS:
      return Object.assign({}, state, {
        userSession: false,
        isFetching: false
      });

    case LOGOUT_FAILURE:
      return Object.assign({}, state, {
        isFetching: false
      });

    default:
      return state;
  }
}

const rootReducer = combineReducers({
  userSession
});

export default rootReducer;