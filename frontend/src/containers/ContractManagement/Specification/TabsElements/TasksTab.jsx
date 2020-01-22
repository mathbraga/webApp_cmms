import React, { Component } from 'react';
import DescriptionTable from '../../../../components/Description/DescriptionTable';
import { itemsMatrixTasks } from '../utils/descriptionMatrix';
// import tableConfig from '../utils/materialTab/tableConfig';
// import { customFilters, filterAttributes } from '../utils/materialTab/filterParameters';
// import searchableAttributes from '../utils/materialTab/searchParameters';
// import CardWithTable from '../../../TableContainer/CardWithTable';
import './Tabs.css';

class MaterialTab extends Component {
  state = {}
  render() {
    const data = this.props.data.allSpecOrders.nodes;
    console.log("Tasks: ", data);
    return (
      <>
        <DescriptionTable
          title={'Lista de Ordens de Serviço'}
          numColumns={2}
          itemsMatrix={itemsMatrixTasks(data)}
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