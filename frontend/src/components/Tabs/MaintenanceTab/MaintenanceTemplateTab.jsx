import React, { Component } from 'react';
import DescriptionTable from '../../Descriptions/DescriptionTable';
import { itemsMatrixReport, itemsMatrixMaintenance } from './utils/descriptionMatrix';
import { customFilters, filterAttributes } from './utils/filterParameters';
import searchableAttributes from './utils/searchParameters';
import tableConfig from './utils/tableConfig';
import CardWithTable from '../../../views/TableContainer/CardWithTable';

class MaintenanceTemplateTab extends Component {
  render() {
    const { data } = this.props;
    return (
      <>
        <DescriptionTable
          title={'Relatório de Manutenções'}
          numColumns={2}
          itemsMatrix={itemsMatrixReport(data)}
        />
        <DescriptionTable
          title={'Tabela de Manutenções'}
          numColumns={2}
          itemsMatrix={itemsMatrixMaintenance(data)}
        />
        <CardWithTable
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

export default MaintenanceTemplateTab;