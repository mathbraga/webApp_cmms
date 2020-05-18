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
      dispatchFormOpen: false,
      statusFormOpen: false,
    };
    this.toggleForm = this.toggleForm.bind(this);
  }

  toggleForm(formName) {
    this.setState(prevState => ({
      [formName]: !prevState[formName]
    }));
  }

  render() {
    const data = this.props.data.assets;
    const { formOpen } = this.state;
    const DispatchActionButtons = [
      {name: 'Tramitar', color: 'success', onClick: () => this.toggleForm('dispatchFormOpen')},
      {name: 'Alterar Status', color: 'primary', onClick: () => this.toggleForm('statusFormOpen')}
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
              visible={this.state.formOpen}
            />
          </div>
          <PaneTitle 
            title={'Situação atual'}
            actionButtons={!formOpen && DispatchActionButtons}
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