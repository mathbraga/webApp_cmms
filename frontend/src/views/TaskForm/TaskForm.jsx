import React, { Component } from 'react';
import AssetCard from '../../components/Cards/AssetCard';
import { Button } from '@material-ui/core';
import { compose } from 'redux';
import './TaskForm.css';
import FormGroup from '../../components/Forms/FormGroup';
import DescriptionForm from './formParts/DescriptionForm';
import ExecutionForm from './formParts/ExecutionForm';
import AssetForm from './formParts/AssetForm';
import props from './props';
import { withProps, withGraphQL, withQuery, withForm, withMutation } from '../../hocs';
import paths from '../../paths';

class TaskForm extends Component {
  render() {
    const { history, handleFunctions, formState, mutate } = this.props;
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
            <div style={{ display: "flex", justifyContent: "flex-end" }}>
              <Button
                variant="contained"
                color="primary"
                style={{ marginRight: "10px" }}
                onClick={mutate}
              >
                Cadastrar
              </Button>
              <Button variant="contained" style={{ marginRight: "10px" }}>
                Limpar
              </Button>
              <Button variant="contained" color="secondary">
                Cancelar
              </Button>
            </div>
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