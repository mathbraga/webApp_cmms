import React, { Component } from 'react';
// import DescriptionTable from '../../../../components/Descriptions/DescriptionTable';
// import { itemsMatrixAssets } from '../utils/descriptionMatrix';
// import tableConfig from '../utils/assetTab/tableConfig';
// import { customFilters, filterAttributes } from '../utils/assetTab/filterParameters';
// import searchableAttributes from '../utils/assetTab/searchParameters';
// import TableFilter from '../../../../components/Tables/CustomTable/TableFilter';
import AssetTemplateTab from '../../../components/Tabs/AssetTab/AssetsTemplateTab';

import PaneTitle from '../../../components/TabPanes/PaneTitle';

import './Tabs.css';

class AssetTab extends Component {
  state = {}
  render() {
    const data = this.props.data.assets;

    return (
      <>
        <div className="tabpane-container">
          <PaneTitle 
            title={'Tabela de Ativos'}
          />
        </div>
      </>
    );
  }
}

export default AssetTab;