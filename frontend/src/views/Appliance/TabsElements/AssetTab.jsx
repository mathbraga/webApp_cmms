import React, { Component } from 'react';
import AssetTemplateTab from '../../../../components/Tabs/AssetTab/AssetsTemplateTab';
import tableConfig from '../utils/tableConfig.js';

class AssetTab extends Component {
  render() {
    const data = Object.values(this.props.data.relations || []);
    const final_data = [].concat(...data);

    return (
      <>
        <AssetTemplateTab
          data={final_data}
          tableConfig={tableConfig}
        />
      </>
    );
  }
}

export default AssetTab;