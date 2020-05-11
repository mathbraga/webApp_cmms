import React, { Component } from 'react';

import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import CustomTable from '../../../components/Tables/CustomTable';
import { Button } from '@material-ui/core';
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
            <Button variant="contained" color="primary" style={{ marginRight: "10px" }}>
              Limpar
            </Button>
            <Button variant="contained" color="secondary">
              Cancelar
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