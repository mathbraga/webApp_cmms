import React, { Component } from 'react';

export default function withGraphQLVariables(WrappedComponent) {
  class WithGraphQLVariables extends Component {
    render() {
      const { match } = this.props;
      const customGraphQLVariables = {
        assetSf: '309C-COB-000'
      }
      return (
        <WrappedComponent
          customGraphQLVariables={customGraphQLVariables}
          {...this.props}
        />
      );
    }
  }
  return WithGraphQLVariables;
}