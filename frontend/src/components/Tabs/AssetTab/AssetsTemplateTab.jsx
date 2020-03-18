import React, { Component } from 'react';
import DescriptionTable from '../../Descriptions/DescriptionTable';
import { itemsMatrixAssets, itemsMatrixAssetsConfig } from './utils/descriptionMatrix';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import tableConfig from './utils/tableConfig';
import CustomTable from '../../Tables/CustomTable';
import withPrepareData from '../../Formating/withPrepareData';
import withSelectLogic from '../../Selection/withSelectLogic';
import { compose } from 'redux';

class AssetTemplateTab extends Component {
  render() {
    const { data } = this.props;

    return (
      <>
        <DescriptionTable
          title={'Lista de Ativos'}
          numColumns={2}
          itemsMatrix={itemsMatrixAssets(data)}
        />
        <DescriptionTable
          title={'Configuração da Lista'}
          numColumns={2}
          itemsMatrix={itemsMatrixAssetsConfig(data)}
        />
        <CustomTable
          type={'pages-with-search'}
          tableConfig={tableConfig}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
          searchableAttributes={searchableAttributes}
          selectedData={this.props.selectedData}
          handleSelectData={this.props.handleSelectData}
          data={data}
        />
      </>
    );
  }
}

export default compose(
  withPrepareData(tableConfig),
  withSelectLogic
)(AssetTemplateTab);