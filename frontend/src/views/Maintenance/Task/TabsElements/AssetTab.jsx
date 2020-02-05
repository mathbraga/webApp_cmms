import React, { Component } from 'react';
// import DescriptionTable from '../../../../components/Descriptions/DescriptionTable';
// import { itemsMatrixAssets } from '../utils/descriptionMatrix';
// import tableConfig from '../utils/assetTab/tableConfig';
// import { customFilters, filterAttributes } from '../utils/assetTab/filterParameters';
// import searchableAttributes from '../utils/assetTab/searchParameters';
// import TableFilter from '../../../../components/Tables/CustomTable/TableFilter';
import AssetTemplateTab from '../../../../components/Tabs/AssetTab/AssetsTemplateTab';
import './Tabs.css';

class AssetTab extends Component {
  state = {}
  render() {
    const data = this.props.data.assets;

    return (
      <>
        <AssetTemplateTab
          data={data}
        />
      </>
    );
    // return (
    //   <>
    //     <DescriptionTable
    //       title={'Lista de Ativos'}
    //       numColumns={2}
    //       itemsMatrix={itemsMatrixAssets(data)}
    //     />
    //     <TableFilter
    //       tableConfig={tableConfig}
    //       customFilters={customFilters}
    //       filterAttributes={filterAttributes}
    //       searchableAttributes={searchableAttributes}
    //       hasAssetCard={false}
    //       data={data}
    //     />
    //   </>
    // );
  }
}

export default AssetTab;