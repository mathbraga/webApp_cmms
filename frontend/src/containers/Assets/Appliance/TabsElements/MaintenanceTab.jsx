import React, { Component } from 'react';
import DescriptionTable from '../../../../components/Description/DescriptionTable';
import { itemsMatrixReport, itemsMatrixMaintenance } from '../utils/descriptionMatrix';
import { customFilters, filterAttributes } from '../utils/filterParameters';
import searchableAttributes from '../utils/searchParameters';
import tableConfig from '../utils/tableConfig';
import CardWithTable from '../../../TableContainer/CardWithTable';

class MaintenanceTab extends Component {
  render() {
    const data = this.props.data.orderAssetsByAssetId.nodes.map((item) => (item.orderByOrderId));
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
          tableConfig={tableConfig}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
          searchableAttributes={searchableAttributes}
          hasAssetCard={false}
          data={data}
        />
      </>
    );
  }
}

export default MaintenanceTab;