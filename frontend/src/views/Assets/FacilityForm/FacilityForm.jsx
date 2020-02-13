import React, { Component } from 'react';
import AssetCard from '../../../components/Cards/AssetCard';
import CssBaseline from '@material-ui/core/CssBaseline';
import { Button } from '@material-ui/core';
import './FacilityForm.css';
import DescriptionForm from './formParts/DescriptionForm';
import LocationForm from './formParts/LocationForm';
import ParentForm from './formParts/ParentForm';
import { withGraphQL, withQuery, withForm, withMutation } from '../../../hocs'
import { compose } from 'redux';

class FacilityForm extends Component {
  render() {
    const { history, handleFunctions, formState, mode, mutate, paths } = this.props;
    const formData = this.props.data.formData.nodes[0];
    return (
      <CssBaseline>
        <AssetCard
          sectionName={mode === 'update' ? 'Editar Edifício' : 'Cadastro de Edifício'}
          sectionDescription={mode === 'update' ? 'Formulário para modificar dados de um edifício' : 'Formulário para cadastro de uma nova área'}
          handleCardButton={() => { history.push(paths.all) }}
          buttonName={'Edifícios'}
        >
          <div className="input-container">
            <form noValidate autoComplete="off">
              <DescriptionForm
                handleInputChange={handleFunctions.handleInputChange}
                {...formState}
              />
              <div style={{ marginTop: "60px" }} />
              <LocationForm
                handleInputChange={handleFunctions.handleInputChange}
                {...formState}
              />
              <div style={{ marginTop: "60px" }} />
              <ParentForm
                handleParentChange={handleFunctions.handleParentChange}
                handleContextChange={handleFunctions.handleContextChange}
                addNewParent={handleFunctions.addNewParent}
                removeParent={handleFunctions.removeParent}
                formData={formData}
                {...formState}
              />
              <div style={{ marginTop: "60px" }} />
              <div style={{ display: "flex", justifyContent: "flex-end" }}>
                <Button 
                  variant="contained"
                  color="primary"
                  style={{ marginRight: "10px" }}
                  onClick={mutate}
                >
                  {mode === 'update' ? "Atualizar" : "Cadastrar"}
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
  withGraphQL,
  withQuery,
  withForm,
  withMutation
)(FacilityForm);