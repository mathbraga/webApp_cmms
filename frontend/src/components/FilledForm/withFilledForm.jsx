import React, { Component } from 'react';
import populateStateEditForm from '../EditForm/populateStateEditForm';

export default function withFilledForm(WrappedComponent) {
  class FilledForm extends Component {
    constructor(props) {
      super(props);
      const itemData = this.props.data.entityData && this.props.data.entityData.nodes[0];
      const { mode } = this.props;
      const { baseState, addNewCustomStates } = this.props.entityDetails
      this.state = populateStateEditForm(baseState, itemData, mode, addNewCustomStates);
    }

    render() {
      return (
        <WrappedComponent
          state={this.state}
          {...this.props}
        />
      );
    }
  }

  return FilledForm;
}
