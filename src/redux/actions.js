// Action types
export const LOGIN_SUCCESS = "LOGIN_SUCCESS";

// Other constants
// OTHER CONSTANTS DECLARATIONS

// Action creators
export function logUserIn(userSession){
  return {
    type: LOGIN_SUCCESS,
    userSession: userSession
  }
};
