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
        <div 
          className='action-container'
        >
          Tramitar Tarefa
        </div>
        <DescriptionTable
          title={'Unidade Atual'}
          numColumns={2}
          itemsMatrix={itemsMatrixAssetsHierachy(data)}
        />
      </>
    );
  }
}

export default AssignTab;