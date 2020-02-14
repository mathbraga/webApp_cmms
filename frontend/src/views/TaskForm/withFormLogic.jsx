import React, { Component } from 'react';

export default function WithFormLogic(WrappedComponent) {

  class WithFormLogic extends Component {
    constructor(props) {
      super(props);
      this.state = {
        title: "",
        place: "",
        description: "",
        priority: 2,
        category: null,
        initialDate: null,
        limitDate: null,
        status: 3,
        contract: null,
        team: null,
        project: null,
        assets: [],
      }

      this.handleInputChange = this.handleInputChange.bind(this);
      this.handleContractChange = this.handleContractChange.bind(this);
      this.handleTeamChange = this.handleTeamChange.bind(this);
      this.handleProjectChange = this.handleProjectChange.bind(this);
      this.handleAssetChange = this.handleAssetChange.bind(this);
      this.handleInitialDateInputChange = this.handleInitialDateInputChange.bind(this);
      this.handleLimitDateInputChange = this.handleLimitDateInputChange.bind(this);
    }

    handleInputChange(event) {
      const { name, value } = event.target;
      this.setState({
        [name]: value
      });
    }

    handleContractChange(event, newValue) {
      this.setState({
        contract: newValue
      });
    }

    handleTeamChange(event, newValue) {
      this.setState({
        team: newValue
      });
    }

    handleProjectChange(event, newValue) {
      this.setState({
        project: newValue
      });
    }

    handleAssetChange(event, newValue) {
      this.setState((prevState) => ({
        assets: newValue,
      }));
    }

    handleInitialDateInputChange(date) {
      this.setState({
        initialDate: date,
      });
    }

    handleLimitDateInputChange(date) {
      this.setState({
        limitDate: date,
      });
    }

    render() {
      const handleFunctions = {
        handleInputChange: this.handleInputChange,
        handleContractChange: this.handleContractChange,
        handleTeamChange: this.handleTeamChange,
        handleProjectChange: this.handleProjectChange,
        handleAssetChange: this.handleAssetChange,
        handleInitialDateInputChange: this.handleInitialDateInputChange,
        handleLimitDateInputChange: this.handleLimitDateInputChange,
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
