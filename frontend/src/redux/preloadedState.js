// Define preloaded state.
// This object has precedence over default state defined in the reducers functions.

export const preloadedState = {
  auth: {
    email: window.localStorage.getItem('session') || false,
    isFetching: false,
    loginError: false
  },
  // consumptionMonitorCache: 
  // ... other reducers ...
};