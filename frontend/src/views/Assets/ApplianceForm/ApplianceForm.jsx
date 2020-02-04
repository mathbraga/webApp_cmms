import React, { Component } from 'react';
import AssetCard from '../../../components/Cards/AssetCard';
import CssBaseline from '@material-ui/core/CssBaseline';
import { Button } from '@material-ui/core';
import { withRouter } from 'react-router-dom';
import { compose } from 'redux';
import './ApplianceForm.css';

import DescriptionForm from './formParts/DescriptionForm';
import PurchaseForm from './formParts/PurchaseForm';
import ParentForm from './formParts/ParentForm';
import WithFormLogic from './withFormLogic';
import withDataFetching from '../../../components/DataFetch';
import withGraphQLVariables from './withGraphQLVariables';

class FacilityForm extends Component {
  render() {
    const { history, handleFunctions, state } = this.props;
    const data = this.props.data.allAssetFormData.nodes[0];
    return (
      <CssBaseline>
        <AssetCard
          sectionName={'Cadastro de Equipamentos'}
          sectionDescription={'Formulário para cadastro de novos equipamentos'}
          handleCardButton={() => { history.push("/ativos/equipamentos") }}
          buttonName={'Equipamentos'}
        >
          <div className="input-container">
            <form noValidate autoComplete="off">
              <DescriptionForm
                handleInputChange={handleFunctions.handleInputChange}
                {...state}
              />
              <div style={{ marginTop: "60px" }} />
              <PurchaseForm
                handleInputChange={handleFunctions.handleInputChange}
                {...state}
              />
              <div style={{ marginTop: "60px" }} />
              <ParentForm
                handleParentChange={handleFunctions.handleParentChange}
                handleContextChange={handleFunctions.handleContextChange}
                addNewParent={handleFunctions.addNewParent}
                removeParent={handleFunctions.removeParent}
                data={data}
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
  withGraphQLVariables,
  withDataFetching(),
  withRouter,
  WithFormLogic
)(FacilityForm);