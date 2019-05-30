// Action types
export const LOGIN_SUCCESS = "LOGIN_SUCCESS";

// Other constants
// OTHER CONSTANTS DECLARATIONS

// Action creators
export function startSession(userSession){
  return {
    type: LOGIN_SUCCESS,
    userSession: userSession
  }
};
