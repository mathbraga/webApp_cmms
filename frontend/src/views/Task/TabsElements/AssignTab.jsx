import React, { Component } from 'react';

import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import CustomTable from '../../../components/Tables/CustomTable';

class AssignTab extends Component {
  state = {}
  render() {
    const data = this.props.data.assets;
    return (
      <>
        <DescriptionTable
          title={'Lista de Ativos'}
          numColumns={2}
          itemsMatrix={itemsMatrixAssets(data)}
        />
        {/* <CustomTable
          type={'pages-with-search'}
          tableConfig={tableConfig}
          customFilters={customFilters}
          filterAttributes={filterAttributes}
          searchableAttributes={searchableAttributes}
          selectedData={this.props.selectedData}
          handleSelectData={this.props.handleSelectData}
          data={data}
        /> */}
      </>
    );
  }
}

export default AssignTab;