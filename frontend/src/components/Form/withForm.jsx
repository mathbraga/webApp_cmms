import React, { Component } from 'react';
import populateStateEditForm from '../EditForm/populateStateEditForm';

export default function withForm(WrappedComponent) {
  class WithForm extends Component {
    constructor(props) {
      super(props);
      this.handleInputChange = this.handleInputChange.bind(this);
      this.handleParentChange = this.handleParentChange.bind(this);
      this.handleContextChange = this.handleContextChange.bind(this);
      this.addNewParent = this.addNewParent.bind(this);
      this.removeParent = this.removeParent.bind(this);
      this.handleSubmit = this.handleSubmit.bind(this);
      const idData = this.props.data.idData && this.props.data.idData.nodes[0];
      const { mode } = this.props;
      this.state = this.props.entityDetails.getInitialFormState(idData, mode);
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
      const formVariables = this.props.entityDetails.getFormVariables(this.state, this.props.mode);
      const mutationVariables = Object.assign({}, this.props.graphQLVariables, formVariables);
      return (
        <WrappedComponent
          handleFunctions={handleFunctions}
          formState={this.state}
          mutationVariables={mutationVariables}
          {...this.props}
        />
      );
    }
  }

  return WithForm;
}
