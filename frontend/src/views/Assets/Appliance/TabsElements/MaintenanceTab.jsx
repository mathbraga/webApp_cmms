import React, { Component } from 'react';
import MaintenanceTemplateTab from '../../../../components/Tabs/MaintenanceTab/MaintenanceTemplateTab';

class MaintenanceTab extends Component {
  render() {
    const data = this.props.data.orderAssetsByAssetId.nodes.map((item) => (item.orderByOrderId));
    return (
      <>
        <MaintenanceTemplateTab
          data={data}
        />
      </>
    );
  }
}

export default MaintenanceTab;