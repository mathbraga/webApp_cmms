import React, { Component } from 'react';
import AssetCard from '../../components/Cards/AssetCard';
import { Button } from '@material-ui/core';
import { compose } from 'redux';
import './ApplianceForm.css';

import FormGroup from '../../components/Forms/FormGroup';
import DescriptionForm from './formParts/DescriptionForm';
import PurchaseForm from './formParts/PurchaseForm';
import ParentForm from './formParts/ParentForm';
import { withProps, withGraphQL, withQuery, withForm, withMutation } from '../../hocs'
import props from './props';
import paths from '../../paths';


class FacilityForm extends Component {
  render() {
    const { history, handleFunctions, formState, mutate } = this.props;
    const data = this.props.data.formData.nodes[0];
    return (
      <AssetCard
        sectionName={'Cadastro de Equipamentos'}
        sectionDescription={'Formulário para cadastro de novos equipamentos'}
        handleCardButton={() => { history.push(paths.appliance.all) }}
        buttonName={'Equipamentos'}
      >
        <div className="input-container">
          <form noValidate autoComplete="off">
            <FormGroup sectionTitle="Descrição do Equipamento">
              <DescriptionForm
                handleInputChange={handleFunctions.handleInputChange}
                {...formState}
              />
            </FormGroup>
          </form>
        </div>
        <br/> <br/> <br/>
        <div className="input-container">
          <form noValidate autoComplete="off">
            <DescriptionForm
              handleInputChange={handleFunctions.handleInputChange}
              {...formState}
            />
            <div style={{ marginTop: "60px" }} />
            <PurchaseForm
              handleInputChange={handleFunctions.handleInputChange}
              {...formState}
            />
            <div style={{ marginTop: "60px" }} />
            <ParentForm
              handleParentChange={handleFunctions.handleParentChange}
              handleContextChange={handleFunctions.handleContextChange}
              addNewParent={handleFunctions.addNewParent}
              removeParent={handleFunctions.removeParent}
              data={data}
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
)(FacilityForm);