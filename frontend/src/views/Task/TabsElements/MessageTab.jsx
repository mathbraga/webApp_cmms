import React, { Component } from 'react';
import PaneTitle from '../../../components/TabPanes/PaneTitle';
import AnimateHeight from 'react-animate-height';
import MessageInput from '../../../components/NewForms/MessageInput';
import MessageBox from '../../../components/Message/MessageBox';

const message = {
  user: 'Pedro Serafim',
  team: 'Seplag',
  time: 'Mar 26, 2020 - 14h56',
  content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec odio urna, posuere ut quam id, facilisis porttitor neque. Nullam finibus neque sed lorem vehicula, ut dignissim mauris sagittis. Sed in aliquam eros. Nunc semper dui a vulputate dignissim. Duis vestibulum ac neque vel ultrices. Vestibulum porttitor sapien nec metus dictum.',
}

const referenceMessage = {
  user: 'Henrique Zaidan',
  time: 'Mar 19, 2020 - 8h35',
  content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec odio urna, posuere ut quam id, facilisis porttitor neque. Nullam finibus neque sed lorem vehicula, ut dignissim mauris sagittis.',
}

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
            <MessageInput 
              toggleForm={this.toggleMessageInput}
            />
          </div>
        </AnimateHeight>
        {(messageInputOpen) && (
          <PaneTitle 
            title={'Mensagens'}
          />
        )}
        <div className="tabpane__content" style={{ marginTop: '40px' }}>
          <MessageBox 
            message={message}
            referenceMessage={referenceMessage}
          />
        </div>
      </div>
    );
  }
}

export default MessageTab;