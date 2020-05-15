import React, { Component } from 'react';

import DispatchForm from '../../../components/NewForms/DispatchForm'
import PaneTitle from '../../../components/TabPanes/PaneTitle'
import PaneTextContent from '../../../components/TabPanes/PaneTextContent';
import { itemsMatrixAssetsHierachy } from '../utils/dispatchTab/descriptionMatrix';
import './Tabs.css'

const DispatchActionButtons = [
  {name: 'Tramitar', color: 'success', onClick: () => {console.log('OK')}},
  {name: 'Alterar Status', color: 'primary', onClick: () => {console.log('OK')}}
];

class AssignTab extends Component {
  state = {}
  render() {
    const data = this.props.data.assets;
    return (
      <>
        <div className="tabpane-container">
          <PaneTitle 
            actionButtons={DispatchActionButtons}
            title={'Tramitar / Alterar status'}
          />
          <div className="tabpane__content">
            <DispatchForm 
              visible={true}
              helperText={'Utilize os botões "Tramitar" e "Alterar Status" para movimentar a tarefa ou atualizar sua situação atual.'}
            />
          </div>
          <PaneTitle 
            title={'Situação atual'}
          />
          <div className="tabpane__content">
            <PaneTextContent 
              numColumns='2' 
              itemsMatrix={itemsMatrixAssetsHierachy(data)}
            />
          </div>
        </div>
      </>
    );
  }
}

export default AssignTab;