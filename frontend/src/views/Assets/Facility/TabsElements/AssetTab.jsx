import React, { Component } from 'react';
import AssetTemplateTab from '../../../../components/Tabs/AssetsTab/AssetsTemplateTab';

class AssetTab extends Component {
  render() {
    const data = this.props.data || [];

    return (
      <>
        <AssetTemplateTab
          data={data}
        />
      </>
    );
  }
}

export default AssetTab;