import React, { useState } from 'react';
import PaneTitle from '../../../components/TabPanes/PaneTitle';
import AnimateHeight from 'react-animate-height';
import MessageInput from '../../../components/NewForms/MessageInput';
import MessageBox from '../../../components/Message/MessageBox';

function MessageTab({ data }) { 
  const [ messageInputOpen, setMessageInputOpen ] = useState(false);
  const { taskId, events } = data;
  
  if (events[0].eventName === 'insert') {
    events.reverse();
  }
  
  console.log("Eventos: ", events);

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
        title={messageInputOpen ? 'Escrever mensagem' : 'Histórico'}
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
          title={'Histórico'}
        />
      )}
      {
        events.map(event => (
          <div className="tabpane__content" style={{ marginTop: '40px' }}>
            <MessageBox 
              event={event}
            />
          </div>
        ))
      }
    </div>
  );
}

export default MessageTab;