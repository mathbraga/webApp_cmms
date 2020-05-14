import React, { Component } from 'react';

import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import CustomTable from '../../../components/Tables/CustomTable';
import { Button } from 'reactstrap';
import DispatchForm from '../../../components/NewForms/DispatchForm'
import { itemsMatrixAssetsHierachy } from '../utils/dispatchTab/descriptionMatrix';
import './Tabs.css'

class AssignTab extends Component {
  state = {}
  render() {
    const data = this.props.data.assets;
    return (
      <>
        <div 
          className='action-container'
        >
          <div className="action__text">Tramitar Tarefa / Alterar Status</div>
          <div className='action__buttons'>
            <Button color="success" size="sm" style={{ marginRight: "10px" }}>
              Tramitar
            </Button>
            <Button color="primary" size="sm">
              Alterar Status
            </Button>
          </div>
        </div>
        <DispatchForm />
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