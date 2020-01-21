import React, { Component } from 'react';

export default function withGraphQLVariables(WrappedComponent) {
  class WithGraphQLVariables extends Component {
    render() {
      const { match } = this.props;
      const customGraphQLVariables = {
        assetSf: 'CIVL-HD-0001'
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