import React, { Component } from 'react';

import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import CustomTable from '../../../components/Tables/CustomTable';
import { Button } from 'reactstrap';
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
          <div className="action-text">Tramitar Tarefa</div>
          <div className='action-buttons'>
            <Button color="success" size="sm" style={{ marginRight: "10px" }}>
              Tramitar
            </Button>
            <Button color="primary" size="sm">
              Alterar Status
            </Button>
          </div>
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