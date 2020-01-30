import React, { Component } from 'react';
import DescriptionTable from '../../Descriptions/DescriptionTable';
// import { itemsMatrixReport, itemsMatrixMaintenance } from './utils/descriptionMatrix';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import tableConfig from './utils/tableConfig';
import TableFilter from '../../Tables/CustomTable/TableFilter';

class AssetTemplateTab extends Component {
  render() {
    const { data } = this.props;
    return (
      <>
        <DescriptionTable
          title={'Relatório de Manutenções'}
        //   numColumns={2}
        //   itemsMatrix={itemsMatrixReport(data)}
        />
        <TableFilter
          tableConfig={this.props.tableConfig || tableConfig}
          customFilters={this.props.customFilters || customFilters}
          filterAttributes={this.props.filterAttributes || filterAttributes}
          searchableAttributes={this.props.searchableAttributes || searchableAttributes}
          hasAssetCard={false}
          data={data}
        />
      </>
    );
  }
}

export default AssetTemplateTab;