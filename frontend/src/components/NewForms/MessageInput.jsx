import React, { useState } from 'react';
import { Button, Input } from 'reactstrap';
import './Message.css'

function MessageInput({ toggleForm, taskId }) {
  const [ messageValue, setMessageValue ] = useState('');
  console.log("Messagesss: ", messageValue);

  function onChangeMessage({target}) {
    if(target) {
      setMessageValue(target.value);
    } 
  }

  function handleSubmit() {
    console.log("Submit observation: ", messageValue);
    toggleForm();
    setMessageValue('');
  }

  function handleClean() {
    setMessageValue('');
  }

  return ( 
    <div className='miniform-container'>
        <div className='miniform__field'>
          <div className='miniform__field__label'>
            Nova mensagem
          </div>
          <div className='miniform__field__sub-label'>
            Escreva sua mensagem no campo abaixo. Após, clique em "Enviar Mensagem".
          </div>
          <div className='miniform__field__input'>
            <Input 
              className='miniform__field__textarea'
              type="textarea" 
              name="text" 
              id="exampleText" 
              rows='4'
              value={messageValue}
              onChange={onChangeMessage}
            />
          </div>
        </div>
        <div className='miniform__buttons'>
          <Button 
            color="success" 
            size="sm" 
            style={{ marginRight: "10px" }}
            onClick={handleSubmit}
          >
            Enviar Mensagem
          </Button>
          <Button 
            color="secondary" 
            size="sm" 
            style={{ marginRight: "10px" }}
            onClick={handleClean}
          >
            Limpar
          </Button>
          <Button 
            color="danger" 
            size="sm" 
            onClick={toggleForm}
          >
            Cancelar
          </Button>
        </div>
      </div>
   );
}
 
export default MessageInput;