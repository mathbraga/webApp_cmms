import React, { Component } from 'react';
import PaneTitle from '../../../components/TabPanes/PaneTitle';
import AnimateHeight from 'react-animate-height';
import EditAssetForm from '../../../components/NewForms/EditAssetForm';

class MessageTab extends Component {
  constructor(props) {
    super(props);
    this.state = {
      messageInputOpen: false
    }
    this.toggleMessageInput = this.toggleMessageInput.bind(this);
  }


  toggleMessageInput() {
    this.setState(prevState => ({
      messageInputOpen: !prevState.messageInputOpen,
    }));
  }

  render() {
    return (
      <div className="tabpane-container">
        <PaneTitle 
          actionButtons={editFormOpen ? actionButtons.editFormOpen : actionButtons.noFormOpen}
          title={editFormOpen ? 'Alterar ativos' : 'Tabela de ativos'}
        />
        <AnimateHeight 
          duration={300}
          height={heightEdit}
        >
          <div className="tabpane__content">
            <EditAssetForm 
              toggleForm={this.toggleEditForm}
            />
          </div>
        </AnimateHeight>
        {(editFormOpen) && (
          <PaneTitle 
            title={'Tabela de Ativos'}
          />
        )}
      </div>
    );
  }
}

export default MessageTab;