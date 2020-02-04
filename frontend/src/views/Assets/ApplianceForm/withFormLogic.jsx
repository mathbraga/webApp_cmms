import React, { Component } from 'react';

export default function WithFormLogic(WrappedComponent) {

  class WithFormLogic extends Component {
    constructor(props) {
      super(props);
      this.state = {
        assetSf: "",
        name: "",
        description: "",
        manufacturer: "",
        serialnum: "",
        model: "",
        price: "",
        parent: null,
        context: null,
        parents: [],
      }

      this.handleInputChange = this.handleInputChange.bind(this);
      this.handleParentChange = this.handleParentChange.bind(this);
      this.handleContextChange = this.handleContextChange.bind(this);
      this.addNewParent = this.addNewParent.bind(this);
      this.removeParent = this.removeParent.bind(this);
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
        const id = `${parent.taskCategoryId}-${context.taskCategoryId}`;
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

    render() {
      const handleFunctions = {
        handleInputChange: this.handleInputChange,
        handleParentChange: this.handleParentChange,
        handleContextChange: this.handleContextChange,
        addNewParent: this.addNewParent,
        removeParent: this.removeParent,
      }
      return (
        <WrappedComponent
          handleFunctions={handleFunctions}
          state={this.state}
          {...this.props}
        />
      );
    }
  }

  return WithFormLogic;
}
