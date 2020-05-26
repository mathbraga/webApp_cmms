import React, { Component } from 'react';
import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import { itemsMatrixMaterial } from '../utils/descriptionMatrix';
import tableConfig from '../utils/materialTab/tableConfig';
import { customFilters, filterAttributes } from '../utils/materialTab/filterParameters';
import searchableAttributes from '../utils/materialTab/searchParameters';
import withDataAccess from '../utils/materialTab/withDataAccess';
import CustomTable from '../../../components/Tables/CustomTable';
import withPrepareData from '../../../components/Formating/withPrepareData';
import withSelectLogic from '../../../components/Selection/withSelectLogic';
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
    return (
      <>
        <div className="tabpane-container">

        </div>
        <CustomTable
          type={'full'}
          tableConfig={tableConfig}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
          searchableAttributes={searchableAttributes}
          selectedData={this.props.selectedData}
          handleSelectData={this.props.handleSelectData}
          data={this.props.data}
        />
      </>
    );
  }
}

export default compose(
  withDataAccess,
  withPrepareData(tableConfig),
  withSelectLogic
)(MaterialTab);