import { combineReducers } from "redux";
import { LOGIN_SUCCESS, LOGIN_FAILURE, LOGOUT } from "./actions";

function userSession(state = false, action) {
  switch (action.type) {

    case LOGIN_SUCCESS:
      return action.userSession;

    case LOGIN_FAILURE:
      return action.userSession;

    case LOGOUT:
      return action.userSession;

    default:
      return state;
  }
}

const rootReducer = combineReducers({
  userSession
});

export default rootReducer;