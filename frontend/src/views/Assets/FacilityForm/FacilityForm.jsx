import React, { Component } from 'react';
import AssetCard from '../../../components/Cards/AssetCard';
import withDataFetching from '../../../components/DataFetch';
import CssBaseline from '@material-ui/core/CssBaseline';
import { Button } from '@material-ui/core';
import { withRouter } from 'react-router-dom';
import { compose } from 'redux';
import './FacilityForm.css';

import DescriptionForm from './formParts/DescriptionForm';
import LocationForm from './formParts/LocationForm';
import ParentForm from './formParts/ParentForm';
import WithFormLogic from './withFormLogic';
import withGraphQLVariables from './withGraphQLVariables';

class FacilityForm extends Component {
  render() {
    const { history, handleFunctions, state, editMode } = this.props;
    const formData = this.props.data.allAssetFormData.nodes[0];
    return (
      <CssBaseline>
        <AssetCard
          sectionName={editMode ? 'Editar Edifício' : 'Cadastro de Edifício'}
          sectionDescription={editMode ? 'Formulário para modificar dados de um edifício' : 'Formulário para cadastro de uma nova área'}
          handleCardButton={() => { history.push("/ativos/edificios") }}
          buttonName={'Edifícios'}
        >
          <div className="input-container">
            <form noValidate autoComplete="off">
              <DescriptionForm
                handleInputChange={handleFunctions.handleInputChange}
                {...state}
              />
              <div style={{ marginTop: "60px" }} />
              <LocationForm
                handleInputChange={handleFunctions.handleInputChange}
                {...state}
              />
              <div style={{ marginTop: "60px" }} />
              <ParentForm
                handleParentChange={handleFunctions.handleParentChange}
                handleContextChange={handleFunctions.handleContextChange}
                addNewParent={handleFunctions.addNewParent}
                removeParent={handleFunctions.removeParent}
                formData={formData}
                {...state}
              />
              <div style={{ marginTop: "60px" }} />
              <div style={{ display: "flex", justifyContent: "flex-end" }}>
                <Button variant="contained" color="primary" style={{ marginRight: "10px" }}>
                  {editMode ? "Atualizar" : "Cadastrar"}
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
  withGraphQLVariables,
  withDataFetching(),
  withRouter,
  WithFormLogic
)(FacilityForm);