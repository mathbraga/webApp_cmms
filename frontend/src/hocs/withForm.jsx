import React, { Component } from 'react';
import getFiles from '../utils/getFiles';

export default function withForm(WrappedComponent) {
  class WithForm extends Component {
    constructor(props) {
      super(props);
      this.innerRef = React.createRef();
      this.handleInputChange = this.handleInputChange.bind(this);
      this.handleParentChange = this.handleParentChange.bind(this);
      this.handleContextChange = this.handleContextChange.bind(this);
      this.addNewParent = this.addNewParent.bind(this);
      this.removeParent = this.removeParent.bind(this);
      this.handleContractChange = this.handleContractChange.bind(this);
      this.handleTeamChange = this.handleTeamChange.bind(this);
      this.handleProjectChange = this.handleProjectChange.bind(this);
      this.handleAssetChange = this.handleAssetChange.bind(this);
      this.handleInitialDateInputChange = this.handleInitialDateInputChange.bind(this);
      this.handleLimitDateInputChange = this.handleLimitDateInputChange.bind(this);
      this.handleSubmit = this.handleSubmit.bind(this);
      this.handleDropFiles = (files) => {
        this.setState({files})
      };
      const idData = this.props.data.idData && this.props.data.idData.nodes[0];
      const { mode } = this.props;
      this.state = {
        ...this.props.getInitialFormState(idData, mode),
        files: [],
      };
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
        handleContractChange: this.handleContractChange,
        handleTeamChange: this.handleTeamChange,
        handleProjectChange: this.handleProjectChange,
        handleAssetChange: this.handleAssetChange,
        handleInitialDateInputChange: this.handleInitialDateInputChange,
        handleLimitDateInputChange: this.handleLimitDateInputChange,
        handleDropFiles: this.handleDropFiles,
        handleSubmit: this.handleSubmit,
      }
      const formState = this.state;
      const formVariables = this.props.getFormVariables(formState);
      const filesListItems = this.state.files.map(file => (
        <li key={file.name}>
          {file.name} - {file.size} bytes
        </li>
      ));
      const filesAndMetadata = getFiles(this.state.files);
      
      const mutationVariables = Object.assign(
        {},
        this.props.graphQLVariables,
        formVariables,
        filesAndMetadata,
      );
      return (
        <WrappedComponent
          handleFunctions={handleFunctions}
          formState={formState}
          mutationVariables={mutationVariables}
          files={filesListItems}
          {...this.props}
        />
      );
    }
  }

  return WithForm;
}
