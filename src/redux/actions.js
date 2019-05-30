// Action types
export const LOGIN_SUCCESS = "LOGIN_SUCCESS";
export const LOGIN_FAILURE = "LOGIN_FAILURE";
export const LOGOUT = "LOGOUT";

// Other constants
// OTHER CONSTANTS DECLARATIONS

// Action creators
export function startSession(userSession){
  return {
    type: LOGIN_SUCCESS,
    userSession: userSession
  }
};

export function endSession(){
  return {
    type: LOGOUT,
    userSession: false
  }
};
