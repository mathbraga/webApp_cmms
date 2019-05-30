import { combineReducers } from "redux";
import { LOGIN_SUCCESS } from "./actions";

function loginUser(state = false, action) {
  switch (action.type) {
    case LOGIN_SUCCESS:
      return action.userSession;
    default:
      return state;
  }
}

const rootReducer = combineReducers({
  loginUser
});

export default rootReducer;