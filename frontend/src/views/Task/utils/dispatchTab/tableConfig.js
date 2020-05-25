import React, { Component } from 'react';

function generateEventName(item) {
  const relationEvents = {
    insert: 'Criado',
    send: 'Tramitado',
    receive: 'Tarefa recebida',
    cancel: 'Tramitação cancelada',
    move: 'Status alterado'
  }
  return relationEvents[item.event];
}

function selectTeamOrStatus(item) {
  let result = null;
  
  if (item.event === 'move') {
    result = item.taskStatusText;
  } else if (item.event === 'send') {
    result = item.recipientName;
  } else {
    result = item.senderName;
  }

  return result;
}

function createSubTeam(item) {
  let result = null;
  
  if (item.event === 'move' || item.event === 'send') {
    result = item.senderName;
  } else {
    result = null;
  }

  return result;
}

function styleStatus(item, columnId) {
  if (item.event === 'cancel' && columnId === 'event') {
    return {
      background: '#ff4c4c',
      borderRadius: '4px',
      fontWeight: '600',
      color: 'white',
    };
  }
  if (item.event === 'send' && columnId === 'event') {
    return {
      background: '#acb5bc',
      borderRadius: '4px',
      fontWeight: '600',
      color: 'white',
    };
  }
  if (item.event === 'receive' && columnId === 'event') {
    return {
      background: '#4dbd74',
      borderRadius: '4px',
      fontWeight: '600',
      color: 'white',
    };
  }
  if (item.event === 'move' && columnId === 'event') {
    return {
      background: '#43a7cb',
      borderRadius: '4px',
      fontWeight: '600',
      color: 'white',
    };
  }
  if (item.event === 'insert' && columnId === 'event') {
    return {
      background: '#181b1e',
      borderRadius: '4px',
      fontWeight: '600',
      color: 'white',
    };
  }
  return null;
}

function createTeamStatusElement(teamStatus, item) {
  if (item.event === 'send') {
    return (
      <div>
        <span style={{fontWeight: '700'}}>PARA: </span> {teamStatus}
      </div>
    );
  } else if (item.event === 'receive' || item.event === 'cancel' || item.event === 'insert') {
    return (
      <div>
        <span style={{fontWeight: '700'}}>POR: </span> {teamStatus}
      </div>
    );
  }
  return (teamStatus);
}

function createSubTeamStatusElement(subTeam, item) {
  if (item.event === 'send') {
    return (
      <div>
        <span style={{fontWeight: '700'}}>DE: </span> {subTeam}
      </div>
    );
  } 
  return (subTeam);
}


const tableConfig = {
  attForDataId: 'time',
  prepareData: {
    eventName: generateEventName,
    teamOrStatus: selectTeamOrStatus,
    subTeam: createSubTeam,
  },
  styleBodyElement: styleStatus,
  columnsConfig: [
    { columnId: 'date', columnName: 'Data / Usuário', width: '15%', align: "center", idForValues: ['time', 'personName']},
    { columnId: 'event', columnName: 'Evento', width: '18%', align: "center", idForValues: ['eventName'], styleText: {fontSize: '0.7rem'}},
    { columnId: 'team', columnName: 'Equipe / Status', width: '32%', align: "justify", idForValues: ['teamOrStatus', 'subTeam'], createElementWithData: createTeamStatusElement, createElementWithSubData: createSubTeamStatusElement },
    { columnId: 'note', columnName: 'Observação', width: '35%', align: "justify", isTextWrapped: true, idForValues: ['note']},
  ]
};

export default tableConfig;