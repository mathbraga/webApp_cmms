import logoutCognito from "../utils/authentication/logoutCognito";

// Action types
export const LOGIN_SUCCESS = "LOGIN_SUCCESS";
export const LOGIN_FAILURE = "LOGIN_FAILURE";
export const LOGOUT_SUCCESS = "LOGOUT_SUCCESS";
export const LOGOUT_FAILURE = "LOGOUT_FAILURE";

// Other constants
// OTHER CONSTANTS DECLARATIONS

// Action creators
export function startSession(email, password){
  return {
    type: LOGIN_SUCCESS,
    userSession: true
  }
};

export function endSession(){
  return {
    type: LOGOUT_SUCCESS,
    userSession: false
  }
};
