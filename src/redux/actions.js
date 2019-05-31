import loginCognito from "../utils/authentication/loginCognito";
import logoutCognito from "../utils/authentication/logoutCognito";

// Action types
export const LOGIN_REQUEST = "LOGIN_REQUEST";
export const LOGIN_SUCCESS = "LOGIN_SUCCESS";
export const LOGIN_FAILURE = "LOGIN_FAILURE";
export const LOGOUT_REQUEST = "LOGOUT_REQUEST";
export const LOGOUT_SUCCESS = "LOGOUT_SUCCESS";
export const LOGOUT_FAILURE = "LOGOUT_FAILURE";

// Other constants
// OTHER CONSTANTS DECLARATIONS

// Action creators
function loginRequest(){
  return {
    type: LOGIN_REQUEST,
  }
}

function loginSuccess(userSession){
  return {
    type: LOGIN_SUCCESS,
    userSession: userSession
  }
}

function loginFailure(){
  return {
    type: LOGIN_FAILURE,
  }
}

export function login(email, password){
  return dispatch => {
    dispatch(loginRequest());
    return loginCognito(email, password)
    .then(userSession => {
      if(userSession){
        dispatch(loginSuccess(userSession));
      } else {
        dispatch(loginFailure());
      }
    });
  }
}

function logoutRequest(){
  return {
    type: LOGOUT_REQUEST
  }
}

function logoutSuccess(){
  return {
    type: LOGOUT_SUCCESS
  }
}

function logoutFailure(){
  return {
    type: LOGOUT_FAILURE
  }
}

export function logout(){
  return (dispatch, getState) => {
    dispatch(logoutRequest());
    return logoutCognito(getState().userSession.userSession)
    .then(logoutResponse => {
      if(logoutResponse){
        dispatch(logoutSuccess());
      } else {
        dispatch(logoutFailure());
      }
    });
  }
}