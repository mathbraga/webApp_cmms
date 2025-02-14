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
  state = {}
  render() {
    return (
      <>
        <DescriptionTable
          title={'Lista de Materiais e Serviços'}
          numColumns={2}
          itemsMatrix={itemsMatrixMaterial(this.props.data)}
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
)(MaterialTab);