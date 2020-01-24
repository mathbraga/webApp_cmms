import React, { Component } from 'react';
import DescriptionTable from '../../../../components/Descriptions/DescriptionTable';
import { itemsMatrixAssets } from '../utils/descriptionMatrix';
import tableConfig from '../utils/assetTab/tableConfig';
import { customFilters, filterAttributes } from '../utils/assetTab/filterParameters';
import searchableAttributes from '../utils/assetTab/searchParameters';
import CardWithTable from '../../../../components/Tables/CustomTable/CardWithTable';
import './Tabs.css';

class MaterialTab extends Component {
  state = {}
  render() {
    const data = this.props.data.orderByOrderId.orderAssetsByOrderId.nodes.map((item) => item.assetByAssetId);
    console.log("Material: ", data);
    return (
      <>
        <DescriptionTable
          title={'Lista de Ativos'}
          numColumns={2}
          itemsMatrix={itemsMatrixAssets(data)}
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

export default MaterialTab;