import React, { Component } from 'react';
import DescriptionTable from '../../../../components/Description/DescriptionTable';
import { itemsMatrixBalance } from '../utils/descriptionMatrix';
// import tableConfig from '../utils/materialTab/tableConfig';
// import { customFilters, filterAttributes } from '../utils/materialTab/filterParameters';
// import searchableAttributes from '../utils/materialTab/searchParameters';
// import CardWithTable from '../../../TableContainer/CardWithTable';
import './Tabs.css';

class MaterialTab extends Component {
  state = {}
  render() {
    const data = this.props.data.allBalances.nodes;
    console.log("Material: ", data);
    return (
      <>
        <DescriptionTable
          title={'Lista de Contratos'}
          numColumns={2}
          itemsMatrix={itemsMatrixBalance(data)}
        />
        {/* <CardWithTable
          tableConfig={tableConfig}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
          searchableAttributes={searchableAttributes}
          hasAssetCard={false}
          data={data}
        /> */}
      </>
    );
  }
}

export default MaterialTab;