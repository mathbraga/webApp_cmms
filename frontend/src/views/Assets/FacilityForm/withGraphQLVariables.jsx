import React, { Component } from 'react';
import { fetchGQLEdit, fetchGQLNew } from './utils/dataFetchParameters';
import { mutationGQLEdit, mutationGQLNew } from './utils/mutationParameters';

export default function withGraphQLVariables(WrappedComponent) {
  class WithGraphQLVariables extends Component {
    render() {
      const { match, editMode } = this.props;
      const customGraphQLVariables = {};
      if (match) {
        customGraphQLVariables.assetId = Number(match.params.id);
      }
      return (
        <WrappedComponent
          customGraphQLVariables={customGraphQLVariables}
          customGraphQLString={editMode
            ? fetchGQLEdit
            : fetchGQLNew
          }
          mutationGQL={editMode
            ? mutationGQLEdit
            : mutationGQLNew
          }
          {...this.props}
        />
      );
    }
  }
  return WithGraphQLVariables;
}