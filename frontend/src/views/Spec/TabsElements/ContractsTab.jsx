import React, { Component } from 'react';
import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import { itemsMatrixBalance } from '../utils/descriptionMatrix';
import tableConfig from '../utils/contractsTab/tableConfig';
import { customFilters, filterAttributes } from '../utils/contractsTab/filterParameters';
import searchableAttributes from '../utils/contractsTab/searchParameters';
import withDataAccess from '../utils/contractsTab/withDataAccess';
import CustomTable from '../../../components/Tables/CustomTable';
import withPrepareData from '../../../components/Formating/withPrepareData';
import withSelectLogic from '../../../components/Selection/withSelectLogic';
import { compose } from 'redux';
import './Tabs.css';

class ContractsTab extends Component {
  state = {}
  render() {
    return (
      <>
        <DescriptionTable
          title={'Lista de Contratos'}
          numColumns={2}
          itemsMatrix={itemsMatrixBalance(this.props.data)}
        />
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
)(ContractsTab);