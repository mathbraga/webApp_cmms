import React, { useState } from 'react';
import PaneTitle from '../../../components/TabPanes/PaneTitle';
import AnimateHeight from 'react-animate-height';
import MessageInput from '../../../components/NewForms/MessageInput';
import MessageBox from '../../../components/Message/MessageBox';

import messages from '../utils/messageTab/fakeMessages';

function MessageTab({ data }) { 
  const [ messageInputOpen, setMessageInputOpen ] = useState(false);
  const { taskId } = data;

  const actionButtons = {
    messageInputOpen: [
      {name: 'Cancelar', color: 'danger', onClick: toggleMessageInput}
    ],
    noFormOpen: [
      {name: 'Nova Mensagem', color: 'success', onClick: toggleMessageInput},
    ],
  };

  const heightMessageInput = messageInputOpen === true ? 'auto' : 0;
  
  function toggleMessageInput() {
    setMessageInputOpen(!messageInputOpen);
  }

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
            toggleForm={toggleMessageInput}
            taskId={taskId}
          />
        </div>
      </AnimateHeight>
      {(messageInputOpen) && (
        <PaneTitle 
          title={'Mensagens'}
        />
      )}
      {
        messages.map(message => (
          <div className="tabpane__content" style={{ marginTop: '40px' }}>
            <MessageBox 
              message={message}
            />
          </div>
        ))
      }
    </div>
  );
}

export default MessageTab;