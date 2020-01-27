import React, { Component } from 'react';
import DescriptionTable from '../../../../components/Descriptions/DescriptionTable';
import { itemsMatrixBalance } from '../utils/descriptionMatrix';
import tableConfig from '../utils/contractsTab/tableConfig';
import { customFilters, filterAttributes } from '../utils/contractsTab/filterParameters';
import searchableAttributes from '../utils/contractsTab/searchParameters';
import TableFilter from '../../../../components/Tables/CustomTable/TableFilter';
import './Tabs.css';

class MaterialTab extends Component {
  state = {}
  render() {
    const data = this.props.data.supplies;
    console.log("Contracts: ", data);
    return (
      <>
        <DescriptionTable
          title={'Lista de Contratos'}
          numColumns={2}
          itemsMatrix={itemsMatrixBalance(data)}
        />
        <TableFilter
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

export default MaterialTab;