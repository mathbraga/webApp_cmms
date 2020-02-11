import React, { Component } from 'react';
import validateInput from './utils/validateInput';

export default function withFacilityFormVariables(WrappedComponent) {
  class WithFacilityFormVariables extends Component {
    render() {
      const { mode, formInputs, customGraphQLVariables } = this.props;
      return (
        <WrappedComponent
          mutationVariables={{
            attributes: {
              // assetId: mode === 'update' ? Number(customGraphQLVariables.entityId) : null,
              assetSf: validateInput(formInputs.assetSf),
              name: validateInput(formInputs.name),
              description: validateInput(formInputs.description),
              category: 1,
              latitude: validateInput(formInputs.latitude),
              longitude: validateInput(formInputs.longitude),
            },
            tops: formInputs.parents.length > 0 ? formInputs.parents.map(parent => parent.context.assetId) : null,
            parents: formInputs.parents.length > 0 ? formInputs.parents.map(parent => parent.parent.assetId) :  null,
          }}
          {...this.props}
        />
      );
    }
  }
  return WithFacilityFormVariables;
}
