import React, { Component } from 'react';
import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import { itemsMatrixSupply } from '../utils/materialTab/descriptionMatrix';
import tableConfig from '../utils/materialTab/tableConfig';
import { customFilters, filterAttributes } from '../utils/materialTab/filterParameters';
import searchableAttributes from '../utils/materialTab/searchParameters';
import withDataAccess from '../utils/materialTab/withDataAccess';
import CustomTable from '../../../components/Tables/CustomTable';
import withPrepareData from '../../../components/Formating/withPrepareData';
import withSelectLogic from '../../../components/Selection/withSelectLogic';

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
  }
  render() {
    const { addFormOpen, editFormOpen } = this.state;

    const actionButtons = {
      editFormOpen: [
        {name: 'Salvar', color: 'success', onClick: () => {console.log('Clicked')}},
        {name: 'Cancelar', color: 'danger', onClick: () => {console.log('Clicked')}}
      ],
      addFormOpen: [
        {name: 'Salvar', color: 'success', onClick: () => {console.log('Clicked')}},
        {name: 'Cancelar', color: 'danger', onClick: () => {console.log('Clicked')}}
      ],
      noFormOpen: [
        {name: 'Adicionar Suprimentos', color: 'primary', onClick: () => {console.log('Clicked')}},
      ],
    };

    const openedForm = addFormOpen ? 'addFormOpen' : (editFormOpen ? 'editFormOpen' : 'noFormOpen');

    return (
      <>
        <div className="tabpane-container">
          <PaneTitle 
            actionButtons={actionButtons[openedForm]}
            title={addFormOpen ? 'Adicionar novo suprimento' : (editFormOpen ? 'Alterar suprimentos' : 'Gastos com suprimentos')}
          />
        </div>

        <div className="tabpane__content">
          <PaneTextContent 
            numColumns='2' 
            itemsMatrix={itemsMatrixSupply()}
          />
        </div>

        {/* <CustomTable
          type={'full'}
          tableConfig={tableConfig}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
          searchableAttributes={searchableAttributes}
          selectedData={this.props.selectedData}
          handleSelectData={this.props.handleSelectData}
          data={this.props.data}
        /> */}
      </>
    );
  }
}

export default compose(
  withDataAccess,
  withPrepareData(tableConfig),
  withSelectLogic
)(MaterialTab);