import React, { Component } from 'react';

import DispatchForm from '../../../components/NewForms/DispatchForm'
import StatusForm from '../../../components/NewForms/StatusForm'
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
    this.toggleDispatchForm = this.toggleDispatchForm.bind(this);
    this.toggleStatusForm = this.toggleStatusForm.bind(this);
  }

  toggleDispatchForm() {
    this.setState(prevState => ({
      dispatchFormOpen: !prevState.dispatchFormOpen,
      statusFormOpen: false
    }));
  }

  toggleStatusForm() {
    this.setState(prevState => ({
      statusFormOpen: !prevState.statusFormOpen,
      dispatchFormOpen: false
    }));
  }

  render() {
    const data = this.props.data.assets;
    const { dispatchFormOpen, statusFormOpen } = this.state;

    const actionButtons = {
      statusFormOpen: [
        {name: 'Cancelar', color: 'danger', onClick: this.toggleStatusForm}
      ],
      dispatchFormOpen: [
        {name: 'Cancelar', color: 'danger', onClick: this.toggleDispatchForm}
      ],
      noFormOpen: [
        {name: 'Tramitar Tarefa', color: 'success', onClick: this.toggleDispatchForm},
        {name: 'Alterar Status', color: 'primary', onClick: this.toggleStatusForm}
      ],
    };
    const openedForm = dispatchFormOpen ? 'dispatchFormOpen' : (statusFormOpen ? 'statusFormOpen' : 'noFormOpen');

    return (
      <>
        <div className="tabpane-container">
          <PaneTitle 
            actionButtons={actionButtons[openedForm]}
            title={dispatchFormOpen ? 'Tramitar Tarefa' : (statusFormOpen ? 'Alterar Status' : 'Situação Atual')}
          />
          {dispatchFormOpen && (
            <div className="tabpane__content">
              <DispatchForm 
                visible={true}
                toggleForm={this.toggleDispatchForm}
              />
            </div>
          )}
          {statusFormOpen && (
            <div className="tabpane__content">
              <StatusForm 
                visible={true}
                toggleForm={this.toggleStatusForm}
              />
            </div>
          )}
          {(statusFormOpen || dispatchFormOpen) && (
            <PaneTitle 
              title={'Situação Atual'}
            />
          )}
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