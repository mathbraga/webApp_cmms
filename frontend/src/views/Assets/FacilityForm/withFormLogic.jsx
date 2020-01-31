import React, { Component } from 'react';

export default function WithFormLogic(WrappedComponent) {

  class WithFormLogic extends Component {
    constructor(props) {
      super(props);
      this.state = {
        assetSf: "",
        name: "",
        latitude: "",
        longitude: "",
        area: "",
        parents: [
          { id: "", name: "" }
        ],
      }

      this.handleInputChange = this.handleInputChange.bind(this);
      this.handleParentChange = this.handleParentChange.bind(this);
    }

    handleInputChange(event) {
      const { name, value } = event.target;
      this.setState({
        [name]: value
      });
    }

    handleParentChange(value) {
      this.setState({
        parents: value,
      });
    }

    render() {
      const handleFunctions = {
        handleInputChange: this.handleInputChange,
        handleParentChange: this.handleParentChange,
      }
      return (
        <WrappedComponent
          handleFunctions={handleFunctions}
          state={this.state}
        />
      );
    }
  }

  return WithFormLogic;
}
