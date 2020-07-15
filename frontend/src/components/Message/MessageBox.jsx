import React, { useState } from 'react';
import { Button, Input, Collapse } from 'reactstrap';
import moment from 'moment';
import 'moment/locale/pt-br' 
import "./Message.css"

const userAvatar = require("../../assets/avatar/user.png");

const eventsAvatar = {
  insert: require("../../assets/avatar/log_insert.png"),
  send: require("../../assets/avatar/log_dispatch.png"),
  receive: require("../../assets/avatar/log_receive.png"),
  cancel: require("../../assets/avatar/log_cancel.png"),
  move: require("../../assets/avatar/log_status.png"),
  note: require("../../assets/avatar/log_message.png"),
}

const subTitleEvent = {
  insert: 'Tarefa criada com sucesso',
  send: 'Tramitação',
  receive: 'Recebimento da tramitação',
  cancel: 'Tramitação cancelada',
  move: 'Alteração de status',
  note: 'Nova mensagem',
}

function LogContent({ event }) {
  const logContent = {
    insert: (
      <ul style ={{ margin: '0' }}>
        <li><span style={{ fontWeight: '600' }}>Tarefa criada por: </span><span>{event.teamName}</span></li>
        <li><span style={{ fontWeight: '600' }}>Observações: </span><span>{event.note || "Evento sem observações."}</span></li>
      </ul>
    ),
    send: (
      <ul style ={{ margin: '0' }}>
        <li><span style={{ fontWeight: '600' }}>De: </span><span>{event.teamName}</span></li>
        <li><span style={{ fontWeight: '600' }}>Para: </span><span>{event.nextTeamName}</span></li>
        <li><span style={{ fontWeight: '600' }}>Despacho: </span><span>{event.note || "Evento sem observações."}</span></li>
      </ul>
    ),
    receive: (
      <ul style ={{ margin: '0' }}>
        <li><span style={{ fontWeight: '600' }}>Recebido por: </span><span>{event.teamName}</span></li>
        <li><span style={{ fontWeight: '600' }}>Observações: </span><span>{event.note || "Evento sem observações."}</span></li>
      </ul>
    ),
    cancel: (
      <ul style ={{ margin: '0' }}>
        <li><span style={{ fontWeight: '600' }}>Cancelado por: </span><span>{event.teamName}</span></li>
        <li><span style={{ fontWeight: '600' }}>Observações: </span><span>{event.note || "Evento sem observações."}</span></li>
      </ul>
    ),
    move: (
      <ul style ={{ margin: '0' }}>
        <li><span style={{ fontWeight: '600' }}>Novo Status: </span><span>{event.taskStatusText}</span></li>
        <li><span style={{ fontWeight: '600' }}>Alterado por: </span><span>{event.teamName}</span></li>
        <li><span style={{ fontWeight: '600' }}>Observações: </span><span>{event.note || "Evento sem observações."}</span></li>
      </ul>
    ),
    note: (
      <ul style ={{ margin: '0' }}>
        <li><span style={{ fontWeight: '600' }}>Mensagem de: </span><span>{event.teamName}</span></li>
        <li><span style={{ fontWeight: '600' }}>Mensagem: </span><span>{event.note || "Nenhuma mensagem foi cadastrada."}</span></li>
      </ul>
    ),
  };
  return logContent[event.eventName];
}

function MessageBox({ event }) {
  const [ isMessageInputOpen, setisMessageInputOpen ] = useState(false);
  
  const createdAt = moment(event.createdAt).locale('pt-br');

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
                <img src={eventsAvatar[event.eventName]} alt="User Avatar" style={{ width: "55px", height: "55px" }} />
              </div>
              <div className="user-description">
                <div className="user-description__name">{event.personName}</div> 
                <div className="user-description__team">{subTitleEvent[event.eventName]}</div>
              </div>
            </div>
            <div className="text-muted message__date">{createdAt.format("DD/MM/YYYY - h:mm:ss a")}</div>
          </div>
          <div className="message__text">
            <LogContent event={event} />
          </div>
        </div>
        {event.eventName === 'note' && (
          <div className="comment__action">
            <i className="comment__icon fa fa-comment"></i>
            <button className="comment__button" onClick={toggleMessageInput}>Responder</button>
          </div>
        )}
      </div>
      <Collapse isOpen={isMessageInputOpen}>
        <div className="text__box">
          <div className="comment__bubble__name" style={{ marginBottom: '10px' }}>
            Resposta à mensagem de <span className='comment__bubble__user'>{event.personName}</span>:
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