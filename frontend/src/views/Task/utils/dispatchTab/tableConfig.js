function generateEventName(item) {
  const relationEvents = {
    insert: 'Criado por',
    send: 'Tramitado para',
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


const tableConfig = {
  attForDataId: 'time',
  prepareData: {
    eventName: generateEventName,
    teamOrStatus: selectTeamOrStatus,
  },
  styleBodyElement: styleStatus,
  columnsConfig: [
    { columnId: 'date', columnName: 'Data', width: '15%', align: "center", idForValues: ['time']},
    { columnId: 'event', columnName: 'Evento', width: '20%', align: "center", idForValues: ['eventName'], style: {fontWeight: '600'}},
    { columnId: 'team', columnName: 'Equipe / Status', width: '30%', align: "justify", idForValues: ['teamOrStatus', 'personName']},
    { columnId: 'note', columnName: 'Observação', width: '35%', align: "justify", isTextWrapped: true, idForValues: ['note']},
  ]
};

export default tableConfig;