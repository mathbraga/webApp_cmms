import React, { Component } from 'react';
import AssetCard from '../../components/Cards/AssetCard';
import { compose } from 'redux';
import './TaskForm.css';
import FormGroup from '../../components/Forms/FormGroup';
import ButtonsContainer from '../../components/Forms/ButtonsContainer';
import DescriptionForm from './formParts/DescriptionForm';
import ExecutionForm from './formParts/ExecutionForm';
import AssetForm from './formParts/AssetForm';
import DropArea from '../../components/DropArea/DropArea';
import props from './props';
import { withProps, withGraphQL, withQuery, withForm, withMutation } from '../../hocs';
import paths from '../../paths';

class TaskForm extends Component {
  render() {
    const { history, handleFunctions, formState, mutate, files } = this.props;
    const data = this.props.data.formData.nodes[0];
    return (
      <AssetCard
        sectionName={'Cadastro de OS'}
        sectionDescription={'Formulário para cadastro de novas ordens de serviço'}
        handleCardButton={() => { history.push(paths.task.all) }}
        buttonName={'Ordens de Serviço'}
      >
        <div className="input-container">
          <form noValidate autoComplete="off">
            <FormGroup sectionTitle="Descrição do Serviço">
              <DescriptionForm
                handleInputChange={handleFunctions.handleInputChange}
                priorityOptions={data.priorityOptions}
                categoryOptions={data.categoryOptions}
                {...formState}
              />
            </FormGroup>
            <FormGroup sectionTitle="Execução">
              <ExecutionForm
                handleInitialDateInputChange={handleFunctions.handleInitialDateInputChange}
                handleLimitDateInputChange={handleFunctions.handleLimitDateInputChange}
                handleInputChange={handleFunctions.handleInputChange}
                handleContractChange={handleFunctions.handleContractChange}
                handleTeamChange={handleFunctions.handleTeamChange}
                handleProjectChange={handleFunctions.handleProjectChange}
                statusOptions={data.statusOptions}
                projectOptions={data.projectOptions}
                teamOptions={data.teamOptions}
                contractOptions={data.contractOptions}
                {...formState}
              />
            </FormGroup>
            <FormGroup sectionTitle="Cadastro de Ativos">
              <AssetForm
                assetOptions={data.assetOptions}
                handleAssetChange={handleFunctions.handleAssetChange}
                {...formState}
              />
            </FormGroup>
            <div style={{ marginTop: "60px" }} />
            <DropArea
              handleDropFiles={handleFunctions.handleDropFiles}
              handleRemoveFiles={handleFunctions.handleRemoveFiles}
              files={formState.files}
            />
            <ButtonsContainer 
              mutate={mutate}
            />
          </form>
        </div>
      </AssetCard>
    );
  }
}

export default compose(
  withProps(props),
  withGraphQL,
  withQuery,
  withForm,
  withMutation
)(TaskForm);