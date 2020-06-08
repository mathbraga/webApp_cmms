import React, { Component } from 'react';
import { Button, Input, Collapse } from 'reactstrap';
import "./Message.css"

const userAvatar = require("../../assets/avatar/user.png");

class MessageBox extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isOpen: false
    };

    this.setCollapseState = this.setCollapseState.bind(this);
  }

  setCollapseState(){
    this.setState({ isOpen: !this.state.isOpen })
  }

  render() {
    const { data } = this.props;
    const isOpen = this.state.isOpen;
    const setCollapseState = this.setCollapseState;

    return (
      <div className='message'>
        <div className="message__container">
          <div className="message__content">
              <div className="message__header">
                <div className="message__author">
                  <div className="message__avatar">
                    <img src={userAvatar} alt="User Avatar" style={{ width: "55px", height: "55px" }} />
                  </div>
                  <div className="user-description">
                    <div className="user-description__name">Pedro Serafim</div> 
                    <div className="user-description__team">Seplag</div>
                  </div>
                </div>
                <div className="text-muted message__date">Mar 26, 2020 - 14h56</div>
              </div>
              <div className="message__text">
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec odio urna, posuere ut quam id, facilisis porttitor neque. Nullam finibus neque sed lorem vehicula, ut dignissim mauris sagittis. Sed in aliquam eros. Nunc semper dui a vulputate dignissim. Duis vestibulum ac neque vel ultrices. Vestibulum porttitor sapien nec metus dictum.
              </div>
          </div>
          <div className="comment__action">
            <i className="comment__icon fa fa-comment"></i>
            <button className="comment__button" onClick={setCollapseState}>Responder</button>
          </div>
        </div>
        <Collapse isOpen={isOpen}>
          <div className="text__box">
            <div className="comment__bubble__name" style={{ marginBottom: '10px' }}>
              Digitar resposta à mensagem de <span className='comment__bubble__user'>Pedro Serafim</span>:
            </div>
            <Input placeholder="Digitar mensagem." className="text__box__input" type="textarea"/>
            <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
              <Button className="text__box__button" color="success" size='sm'>Enviar Mensagem</Button>
            </div>
          </div>
        </Collapse>
        <div className="message__container">
          <div className="comment__container">
            <div className="comment__bubble__container">
              <div className="comment__bubble__author">
                <div className="comment__bubble__author__info">
                  <span className="comment__bubble__name">
                    A mensagem acima é uma resposta ao <span className='comment__bubble__user'>Henrique Zaidan</span>:
                  </span>
                </div>
                <span className="comment__bubble__date text-muted">
                  Mar 20, 2020 - 8h32
                </span>
              </div>
              <div className="comment__bubble__box comment__bubble">
                <div className="comment__bubble__content">
                  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec odio urna, posuere ut quam id, facilisis porttitor neque. Nullam finibus neque sed lorem vehicula, ut dignissim mauris sagittis.
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default MessageBox;