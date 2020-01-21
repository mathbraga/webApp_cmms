import React, { Component } from 'react';
import DescriptionTable from '../../../../components/Description/DescriptionTable';
import { itemsMatrixReport, itemsMatrixMaintenance } from '../utils/descriptionMatrix';

class MaintenanceTab extends Component {
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
        {/* <CardWithTable
          tableConfig={tableConfig}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
          searchableAttributes={searchableAttributes}
          data={data}
        /> */}
      </>
    );
  }
}

export default MaintenanceTab;