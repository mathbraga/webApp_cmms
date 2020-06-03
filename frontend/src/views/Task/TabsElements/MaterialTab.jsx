import React, { Component } from 'react';
import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import { itemsMatrixSupply, itemsMatrixTableFilter } from '../utils/materialTab/descriptionMatrix';
import tableConfig from '../utils/materialTab/tableConfig';
import { customFilters, filterAttributes } from '../utils/materialTab/filterParameters';
import searchableAttributes from '../utils/materialTab/searchParameters';
import withDataAccess from '../utils/materialTab/withDataAccess';
import CustomTable from '../../../components/Tables/CustomTable';
import withPrepareData from '../../../components/Formating/withPrepareData';
import withSelectLogic from '../../../components/Selection/withSelectLogic';

import AnimateHeight from 'react-animate-height';
import DispatchForm from '../../../components/NewForms/DispatchForm';
import StatusForm from '../../../components/NewForms/StatusForm';
import AddSupplyForm from '../../../components/NewForms/AddSupplyForm';
import EditSupplyForm from '../../../components/NewForms/EditSupplyForm';

import PaneTitle from '../../../components/TabPanes/PaneTitle';
import PaneTextContent from '../../../components/TabPanes/PaneTextContent';

import { compose } from 'redux';
import './Tabs.css';

class MaterialTab extends Component {
  constructor(props) {
    super(props);
    this.state = {
      addFormOpen: false,
      editFormOpen: false,
    };
    this.toggleAddForm = this.toggleAddForm.bind(this);
    this.toggleEditForm = this.toggleEditForm.bind(this);
  }

  toggleAddForm() {
    this.setState(prevState => ({
      addFormOpen: !prevState.addFormOpen,
      editFormOpen: false
    }));
  }

  toggleEditForm() {
    this.setState(prevState => ({
      editFormOpen: !prevState.editFormOpen,
      addFormOpen: false
    }));
  }

  render() {
    const { addFormOpen, editFormOpen } = this.state;

    console.log("Data", this.props.data);

    const actionButtons = {
      editFormOpen: [
        {name: 'Salvar', color: 'success', onClick: this.toggleEditForm},
        {name: 'Cancelar', color: 'danger', onClick: this.toggleEditForm}
      ],
      addFormOpen: [
        {name: 'Voltar', color: 'danger', onClick: this.toggleAddForm}
      ],
      noFormOpen: [
        {name: 'Adicionar Suprimentos', color: 'primary', onClick: this.toggleAddForm},
        {name: 'Editar Suprimentos', color: 'success', onClick: this.toggleEditForm},
      ],
    };

    const openedForm = addFormOpen ? 'addFormOpen' : (editFormOpen ? 'editFormOpen' : 'noFormOpen');
    const heightAdd = openedForm === 'addFormOpen' ? 'auto' : 0;
    const heightEdit = openedForm === 'editFormOpen' ? 'auto' : 0;

    return (
      <>
        <div className="tabpane-container">
          <PaneTitle 
            actionButtons={actionButtons[openedForm]}
            title={addFormOpen ? 'Adicionar novo suprimento' : (editFormOpen ? 'Alterar suprimentos' : 'Resumo dos gastos')}
          />
          <AnimateHeight 
            duration={300}
            height={heightAdd}
          >
            <div className="tabpane__content">
              <AddSupplyForm 
                visible={true}
                toggleForm={this.toggleAddForm}
              />
            </div>
          </AnimateHeight>
          <AnimateHeight 
            duration={300}
            height={heightEdit}
          >
            <div className="tabpane__content">
              <EditSupplyForm 
                visible={true}
                toggleForm={this.toggleEditForm}
              />
            </div>
          </AnimateHeight>
          {(addFormOpen || editFormOpen) && (
            <PaneTitle 
              title={'Resumo dos Gastos'}
            />
          )}
          <div className="tabpane__content">
            <PaneTextContent 
              numColumns='2' 
              itemsMatrix={itemsMatrixSupply()}
            />
          </div>
          <PaneTitle 
            title={'Tabela de suprimentos'}
          />
          <div className="tabpane__content">
            <PaneTextContent 
              numColumns='2' 
              itemsMatrix={itemsMatrixTableFilter()}
            />
          </div>
          <div className="tabpane__content__table">
            <CustomTable
              type={'pages-with-search'}
              tableConfig={tableConfig}
              searchableAttributes={searchableAttributes}
              selectedData={this.props.selectedData}
              handleSelectData={this.props.handleSelectData}
              data={this.props.data}
              disableSorting
            />
          </div>
        </div>
      </>
    );
  }
}

export default compose(
  withDataAccess,
  withPrepareData(tableConfig),
  withSelectLogic
)(MaterialTab);