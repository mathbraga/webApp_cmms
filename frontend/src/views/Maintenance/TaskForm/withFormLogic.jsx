import React, { Component } from 'react';
import populateStateEditForm from '../../../components/EditForm/populateStateEditForm';
import { baseState } from './utils/stateEditMode';

export default function WithFormLogic(WrappedComponent) {

  class WithFormLogic extends Component {
    constructor(props) {
      super(props);
      const itemData = this.props.data.allTaskData && this.props.data.allTaskData.nodes[0];
      const { editMode } = this.props;

      this.state = populateStateEditForm(baseState, itemData, editMode);

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
          {...this.props}
        />
      );
    }
  }

  return WithFormLogic;
}
