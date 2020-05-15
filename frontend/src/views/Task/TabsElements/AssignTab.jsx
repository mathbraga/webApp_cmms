import React, { Component } from 'react';

import DispatchForm from '../../../components/NewForms/DispatchForm'
import PaneTitle from '../../../components/TabPanes/PaneTitle'
import PaneTextContent from '../../../components/TabPanes/PaneTextContent';
import { itemsMatrixAssetsHierachy } from '../utils/dispatchTab/descriptionMatrix';
import './Tabs.css'

class AssignTab extends Component {
  constructor(props) {
    super(props);
    this.state = {
      formOpen: false,
    };
    this.toggleForm = this.toggleForm.bind(this);
  }

  toggleForm() {
    this.setState(prevState => ({
      formOpen: !prevState.formOpen
    }));
  }

  render() {
    const data = this.props.data.assets;
    const DispatchActionButtons = [
      {name: 'Tramitar', color: 'success', onClick: this.toggleForm},
      {name: 'Alterar Status', color: 'primary', onClick: this.toggleForm}
    ];
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