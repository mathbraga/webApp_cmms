import React, { Component } from 'react';

function withSearchLogic(WrappedComponent) {
  class WithSearchLogic extends Component {
    render() {
      return (
        <WrappedComponent
          {...this.props}
        />
      );
    }
  }

  return WithSearchLogic;
}

export default withSearchLogic;