import React, { Component } from 'react';

export default function withSwitch(WrappedComponent) {
  class WithSwitch extends Component {
    render() {
      const { match, mode, entityDetails } = this.props;
      const customGraphQLVariables = {};
      mode === 'update'
        ? customGraphQLVariables[entityDetails.idField] = Number(match.params.id)
        : customGraphQLVariables[entityDetails.idField] = null;
      const queryGQL = entityDetails.GQLs[mode].query;
      const mutationGQL = entityDetails.GQLs[mode].mutation;

      return (
        <WrappedComponent
          customGraphQLVariables={customGraphQLVariables}
          queryGQL={queryGQL}
          mutationGQL={mutationGQL}
          {...this.props}
        />
      );
    }
  }
  return WithSwitch;
}