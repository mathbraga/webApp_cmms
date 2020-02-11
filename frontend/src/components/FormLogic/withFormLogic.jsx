import React, { Component } from 'react';
import populateStateEditForm from '../EditForm/populateStateEditForm';

export default function withFormLogic(WrappedComponent) {
  class WithFormLogic extends Component {
    constructor(props) {
      super(props);
      this.handleInputChange = this.handleInputChange.bind(this);
      this.handleParentChange = this.handleParentChange.bind(this);
      this.handleContextChange = this.handleContextChange.bind(this);
      this.addNewParent = this.addNewParent.bind(this);
      this.removeParent = this.removeParent.bind(this);
      this.handleSubmit = this.handleSubmit.bind(this);
      const itemData = this.props.data.entityData && this.props.data.entityData.nodes[0];
      const { mode } = this.props;
      const { baseState, addNewCustomStates } = this.props.entityDetails
      this.state = populateStateEditForm(baseState, itemData, mode, addNewCustomStates);
      // this.getMutationVariables = this.getMutationVariables.bind(this);
    }

    handleInputChange(event) {
      const { name, value } = event.target;
      this.setState({
        [name]: value
      });
    }

    handleParentChange(event, newValue) {
      this.setState({ parent: newValue, });
    }

    handleContextChange(event, newValue) {
      this.setState({ context: newValue, });
    }

    addNewParent() {
      this.setState((prevState) => {
        const { parent, context } = prevState;
        if (parent && context) {
          const id = `${parent.assetId}-${context.assetId}`;
          return ({
            parents: [
              ...prevState.parents,
              { parent, context, id }
            ],
            parent: null,
            context: null,
          });
        }
      });
    }

    removeParent(removeId) {
      this.setState((prevState) => {
        const parents = prevState.parents.filter(item => (item.id != removeId))
        return ({ parents });
      });
    }

    handleSubmit(mutateFunction) {
      mutateFunction();
    }

    render() {
      const handleFunctions = {
        handleInputChange: this.handleInputChange,
        handleParentChange: this.handleParentChange,
        handleContextChange: this.handleContextChange,
        addNewParent: this.addNewParent,
        removeParent: this.removeParent,
        handleSubmit: this.handleSubmit,
      }
      return (
        <WrappedComponent
          handleFunctions={handleFunctions}
          formInputs={this.state}
          {...this.props}
        />
      );
    }
  }

  return WithFormLogic;
}
