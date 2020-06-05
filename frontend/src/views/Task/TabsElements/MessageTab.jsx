import React, { Component } from 'react';

class MessageTab extends Component {
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