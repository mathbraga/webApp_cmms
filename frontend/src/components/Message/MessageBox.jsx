import React, { useState } from 'react';
import { Button, Input, Collapse } from 'reactstrap';
import "./Message.css"

const userAvatar = require("../../assets/avatar/user.png");
const dispatchAvatar = require("../../assets/avatar/log_dispatch.png");
const statusAvatar = require("../../assets/avatar/log_status.png");
const MessageAvatar = require("../../assets/avatar/log_message.png");

function MessageBox({ event }) {
  const [ isMessageInputOpen, setisMessageInputOpen ] = useState(false);

  function toggleMessageInput() {
    setisMessageInputOpen(!isMessageInputOpen);
  }

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
                  <div className="user-description__name">{event.user}</div> 
                  <div className="user-description__team">{event.team}</div>
                </div>
              </div>
              <div className="text-muted message__date">{event.time}</div>
            </div>
            <div className="message__text">
              {event.content}
            </div>
        </div>
        <div className="comment__action">
          <i className="comment__icon fa fa-comment"></i>
          <button className="comment__button" onClick={toggleMessageInput}>Responder</button>
        </div>
      </div>
      <Collapse isOpen={isMessageInputOpen}>
        <div className="text__box">
          <div className="comment__bubble__name" style={{ marginBottom: '10px' }}>
            Digitar resposta à mensagem de <span className='comment__bubble__user'>{event.user}</span>:
          </div>
          <Input placeholder="Digitar mensagem." className="text__box__input" type="textarea"/>
          <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
            <Button className="text__box__button" color="success" size='sm'>Enviar Mensagem</Button>
          </div>
        </div>
      </Collapse>
      {event.reference && (
        <div className="message__container">
          <div className="comment__container">
            <div className="comment__bubble__container">
              <div className="comment__bubble__author">
                <div className="comment__bubble__author__info">
                  <span className="comment__bubble__name">
                    A mensagem acima é uma resposta ao <span className='comment__bubble__user'>{event.reference.user}</span>:
                  </span>
                </div>
                <span className="comment__bubble__date text-muted">
                  {event.reference.time}
                </span>
              </div>
              <div className="comment__bubble__box comment__bubble">
                <div className="comment__bubble__content">
                  {event.reference.content}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default MessageBox;