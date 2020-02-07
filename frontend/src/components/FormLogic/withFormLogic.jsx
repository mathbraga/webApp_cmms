import React, { Component } from 'react';
import populateStateEditForm from '../EditForm/populateStateEditForm';
import { baseState, addNewCustomStates } from './utils/stateEditMode';


export default function withFormLogic(WrappedComponent) {
  class WithFormLogic extends Component {
    constructor(props) {
      super(props);
      const itemData = this.props.data.allFacilityData && this.props.data.allFacilityData.nodes[0];
      const { editMode } = this.props;

      this.state = populateStateEditForm(baseState, itemData, editMode, addNewCustomStates);

      this.handleInputChange = this.handleInputChange.bind(this);
      this.handleParentChange = this.handleParentChange.bind(this);
      this.handleContextChange = this.handleContextChange.bind(this);
      this.addNewParent = this.addNewParent.bind(this);
      this.removeParent = this.removeParent.bind(this);
      this.handleSubmit = this.handleSubmit.bind(this);
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
        const id = `${parent.assetId}-${context.assetId}`;
        if (parent && context) {
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
          state={this.state}
          mutationVariables={{
            attributes: {
              assetSf: 'assetSf' + Math.random().toString(),
              name: 'name',
              description: 'description',
              category: 1,
            },
            tops: [1],
            parents: [1],
          }}
          {...this.props}
        />
      );
    }
  }

  return WithFormLogic;
}
