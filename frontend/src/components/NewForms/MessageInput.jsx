import React, { Component } from 'react';
import { Button, Input } from 'reactstrap';
import './Message.css'

class MessageInput extends Component {
  constructor(props) {
    super(props);
    this.state = {
      messageValue: '',
    }

    this.onChangeMessage = this.onChangeMessage.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleClean = this.handleClean.bind(this);
  }

  onChangeMessage(target) {
    if(target) {
      this.setState({
        messageValue: target.value,
      });
    } 
  }

  handleSubmit(toggleForm) {
    console.log("Submit observation: ", this.state.messageValue);
    toggleForm();
  }

  handleClean() {
    this.setState({
      messageValue: '',
    });
  }

  render() { 
    const { toggleForm } = this.props;
    const { messageValue } = this.state;

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
                onChange={this.onChangeMessage}
              />
            </div>
          </div>
          <div className='miniform__buttons'>
            <Button 
              color="success" 
              size="sm" 
              style={{ marginRight: "10px" }}
              onClick={() => {this.handleSubmit(toggleForm)}}
            >
              Enviar Mensagem
            </Button>
            <Button 
              color="secondary" 
              size="sm" 
              style={{ marginRight: "10px" }}
              onClick={this.handleClean}
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
}
 
export default MessageInput;