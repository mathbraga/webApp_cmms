import React, { Component } from 'react';
import validateInput from './utils/validateInput';

export default function withFacilityFormVariables(WrappedComponent) {
  class WithFacilityFormVariables extends Component {
    render() {
      const { mode, state, customGraphQLVariables } = this.props;
      return (
        <WrappedComponent
          mutationVariables={{
            attributes: {
              assetId: mode === 'update' ? Number(customGraphQLVariables.entityId) : null,
              assetSf: validateInput(state.assetSf),
              name: validateInput(state.name),
              description: validateInput(state.description),
              category: 1,
              latitude: validateInput(state.latitude),
              longitude: validateInput(state.longitude),
            },
            tops: [1],
            parents: [1],
          }
          // FOR TESTS (NO NEED TO FILL FORM):
          //   {
          //   attributes: {
          //     assetSf: 'assetSf' + Math.random().toString(),
          //     name: 'name',
          //     description: 'description',
          //     category: 1,
          //   },
          //   tops: [1],
          //   parents: [1],
          // }
        }
          {...this.props}
        />
      );
    }
  }
  return WithFacilityFormVariables;
}
