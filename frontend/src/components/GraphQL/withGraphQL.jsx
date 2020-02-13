import React, { Component } from 'react';

export default function withGraphQL(WrappedComponent) {
  class WithGraphQL extends Component {
    render() {
      const { match, mode, entityDetails } = this.props;
      
      const queryGQL = entityDetails.GQLs[mode].query;
      const mutationGQL = entityDetails.GQLs[mode].mutation;
      const graphQLVariables = {
        id: Number(match.params.id),
      };

      return (
        <WrappedComponent
          queryGQL={queryGQL}
          mutationGQL={mutationGQL}
          graphQLVariables={graphQLVariables}
          {...this.props}
        />
      );
    }
  }
  return WithGraphQL;
}