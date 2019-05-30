import { combineReducers } from "redux";
import { LOGIN_SUCCESS } from "./actions";

function userSession(state = false, action) {
  switch (action.type) {
    case LOGIN_SUCCESS:
      return action.userSession;
    default:
      return state;
  }
}

const rootReducer = combineReducers({
  userSession
});

export default rootReducer;