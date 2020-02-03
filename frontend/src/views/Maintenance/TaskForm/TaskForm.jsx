import React, { Component } from 'react';
import AssetCard from '../../../components/Cards/AssetCard';
import withDataFetching from '../../../components/DataFetch';
import CssBaseline from '@material-ui/core/CssBaseline';
import { Button } from '@material-ui/core';
import { withRouter } from 'react-router-dom';
import { compose } from 'redux';
import './TaskForm.css';

import { fetchGQL, fetchVariables } from './utils/dataFetchParameters';
import DescriptionForm from './formParts/DescriptionForm';
import ExecutionForm from './formParts/ExecutionForm';
import AssetForm from './formParts/AssetForm';
import WithFormLogic from './withFormLogic';

class TaskForm extends Component {
  render() {
    const { history, handleFunctions, state } = this.props;
    const data = this.props.data.allTaskFormData.nodes[0];
    return (
      <CssBaseline>
        <AssetCard
          sectionName={'Cadastro de OS'}
          sectionDescription={'Formulário para cadastro de novas ordens de serviço'}
          handleCardButton={() => { history.push("/manutencao/os") }}
          buttonName={'Ordens de Serviço'}
        >
          <div className="input-container">
            <form noValidate autoComplete="off">
              <DescriptionForm
                handleInputChange={handleFunctions.handleInputChange}
                priorityOptions={data.priorityOptions}
                categoryOptions={data.categoryOptions}
                {...state}
              />
              <div style={{ marginTop: "60px" }} />
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
                {...state}
              />
              <div style={{ marginTop: "60px" }} />
              <AssetForm
                assetOptions={data.teamOptions}
                handleAssetChange={handleFunctions.handleAssetChange}
                {...state}
              />
              <div style={{ marginTop: "60px" }} />
              <div style={{ display: "flex", justifyContent: "flex-end" }}>
                <Button variant="contained" color="primary" style={{ marginRight: "10px" }}>
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
      </CssBaseline>
    );
  }
}

export default compose(
  withRouter,
  WithFormLogic,
  withDataFetching(fetchGQL, fetchVariables)
)(TaskForm);