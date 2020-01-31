import React, { Component } from 'react';
import AssetTemplateTab from '../../../../components/Tabs/AssetsTab/AssetsTemplateTab';

class AssetTab extends Component {
  render() {
    const data = this.props.data.map((item) => item.assets) || [];
    const final_data = [].concat(...data);

    return (
      <>
        <AssetTemplateTab
          data={final_data}
        />
      </>
    );
  }
}

export default AssetTab;