import React, { Component } from 'react';

import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import CustomTable from '../../../components/Tables/CustomTable';
import DispatchForm from '../../../components/NewForms/DispatchForm'
import PaneTitle from './../../../components/TabPanes/PaneTitle'
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
            title={'Status Atual'}
          />
          <div className="tabpane__content">
            <DispatchForm 
              visible={false}
            />
          </div>
        </div>
      </>
    );
  }
}

export default AssignTab;