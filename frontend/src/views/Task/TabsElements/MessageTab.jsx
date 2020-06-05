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
    const { messageInputOpen } = this.state;

    const actionButtons = {
      messageInputOpen: [
        {name: 'Cancelar', color: 'danger', onClick: this.toggleMessageInput}
      ],
      noFormOpen: [
        {name: 'Nova Mensagem', color: 'success', onClick: this.toggleMessageInput},
      ],
    };

    const heightMessageInput = messageInputOpen === true ? 'auto' : 0;

    return (
      <div className="tabpane-container">
        <PaneTitle 
          actionButtons={messageInputOpen ? actionButtons.messageInputOpen : actionButtons.noFormOpen}
          title={messageInputOpen ? 'Escrever mensagem' : 'Mensagens'}
        />
        <AnimateHeight 
          duration={300}
          height={heightMessageInput}
        >
          <div className="tabpane__content">
            <EditAssetForm 
              toggleForm={this.toggleMessageInput}
            />
          </div>
        </AnimateHeight>
        {(messageInputOpen) && (
          <PaneTitle 
            title={'Mensagens'}
          />
        )}
      </div>
    );
  }
}

export default MessageTab;