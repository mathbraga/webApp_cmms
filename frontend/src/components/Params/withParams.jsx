import React, { Component } from 'react';

export default function withParams(WrappedComponent) {
  class WithParams extends Component {
    render() {
      const { match, mode, entityDetails } = this.props;
      
      const queryGQL = entityDetails.GQLs[mode].query;
      const queryVariables = {
        id: Number(match.params.id),
      };

      const mutationGQL = entityDetails.GQLs[mode].mutation;
      const mutationVariables = {
        id: Number(match.params.id),
      };

      return (
        <WrappedComponent
          queryGQL={queryGQL}
          queryVariables={queryVariables}
          mutationGQL={mutationGQL}
          mutationVariables={mutationVariables}
          {...this.props}
        />
      );
    }
  }
  return WithParams;
}