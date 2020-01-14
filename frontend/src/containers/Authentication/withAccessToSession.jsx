import { connect } from "react-redux";

export function withAccessToSession(WrappedComponent) {

  // Get state from react-redux.
  const mapStateToProps = (storeState) => {
    return ({
      session: storeState.auth.session
    });
  }

  return connect(mapStateToProps)(WrappedComponent);
}