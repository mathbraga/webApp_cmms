import loginCognito from "../utils/authentication/loginCognito";
import logoutCognito from "../utils/authentication/logoutCognito";
import handleSearch from "../utils/consumptionMonitor/handleSearch";

// Action types
export const LOGIN_REQUEST = "LOGIN_REQUEST";
export const LOGIN_SUCCESS = "LOGIN_SUCCESS";
export const LOGIN_FAILURE = "LOGIN_FAILURE";
export const LOGOUT_REQUEST = "LOGOUT_REQUEST";
export const LOGOUT_SUCCESS = "LOGOUT_SUCCESS";
export const LOGOUT_FAILURE = "LOGOUT_FAILURE";
export const QUERY_REQUEST = "QUERY_REQUEST";
export const QUERY_SUCCESS = "QUERY_SUCCESS";
export const QUERY_FAILURE = "QUERY_FAILURE";
export const QUERY_RESET = "QUERY_RESET";
export const SAVE_SEARCH_RESULT_ENERGY = "SAVE_SEARCH_RESULT_ENERGY";
export const SAVE_SEARCH_RESULT_WATER = "SAVE_SEARCH_RESULT_WATER";
export const CLEAN_CACHE = "CLEAN_CACHE";

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
    session: userSession
  }
}

function loginFailure(){
  return {
    type: LOGIN_FAILURE,
  }
}

export function login(email, password, history){
  return dispatch => {
    dispatch(loginRequest());
    return loginCognito(email, password)
    .then(session => {
      if(session){
        dispatch(loginSuccess(session));
        history.push("/painel");
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

function cleanCache(){
  return {
    type: CLEAN_CACHE
  }
}

export function logout(history){
  return (dispatch, getState) => {
    dispatch(logoutRequest());
    return logoutCognito(getState().auth.session)
    .then(logoutResponse => {
      if(logoutResponse){
        dispatch(logoutSuccess());
        dispatch(cleanCache());
        history.push("/login");
      } else {
        dispatch(logoutFailure());
      }
    });
  }
}

function queryRequest(){
  return {
    type: QUERY_REQUEST
  }
}

function querySuccess(resultObject){
  return {
    type: QUERY_SUCCESS,
    resultObject: resultObject
  }
}

function queryFailure(message){
  return {
    type: QUERY_FAILURE,
    message: message
  }
}

export function queryReset(){
  return {
    type: QUERY_RESET
  }
}

export function query(awsData, state){
  return (dispatch => {
    dispatch(queryRequest());
    return handleSearch(awsData, state)
    .then(resultObject => {
      dispatch(querySuccess(resultObject));
    })
    .catch(message => {
      dispatch(queryFailure(message));
    });
  });
}

function cacheEnergy(state){
  return {
    type: SAVE_SEARCH_RESULT_ENERGY,
    energy: state
  }
}

function cacheWater(state){
  return {
    type: SAVE_SEARCH_RESULT_WATER,
    water: state
  }
}

export function saveSearchResult(state, monitor){
  return (dispatch => {
    if(monitor === "energy"){
      return dispatch(cacheEnergy(state))
    } else if(monitor === "water"){
      return dispatch(cacheWater(state))
    }
  });
}
