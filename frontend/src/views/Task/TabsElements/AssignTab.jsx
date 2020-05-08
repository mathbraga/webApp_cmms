import React, { Component } from 'react';

import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import CustomTable from '../../../components/Tables/CustomTable';
import { itemsMatrixAssetsHierachy } from '../utils/dispatchTab/descriptionMatrix';

class AssignTab extends Component {
  state = {}
  render() {
    const data = this.props.data.assets;
    return (
      <>
        <DescriptionTable
          title={'Unidade Atual'}
          numColumns={2}
          itemsMatrix={itemsMatrixAssetsHierachy(data)}
        />
        <div 
          className='action-container'
        >
          Hey
        </div>
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