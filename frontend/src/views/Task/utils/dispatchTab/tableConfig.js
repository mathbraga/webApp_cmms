function generateEventName(item) {
  const relationEvents = {
    insert: 'Criado por',
    send: 'Tramitado para',
    receive: 'Tramitação recebida',
    cancel: 'Tramitação cancelada',
    move: 'Status alterado'
  }
  return relationEvents[item.event];
}

function selectTeamOrStatus(item) {
  let result = null;
  
  if (item.event === 'move') {
    result = item.taskStatusText;
  } else if (item.event = 'send') {
    result = item.recipientName;
  } else {
    result = item.senderName;
  }

  return result;
}



const tableConfig = {
  attForDataId: 'time',
  prepareData: {
    eventName: generateEventName,
    teamOrStatus: selectTeamOrStatus,
  },
  columnsConfig: [
    { columnId: 'date', columnName: 'Data', width: '15%', align: "center", idForValues: ['time']},
    { columnId: 'event', columnName: 'Evento', width: '20%', align: "center", idForValues: ['eventName']},
    { columnId: 'team', columnName: 'Equipe / Status', width: '25%', align: "justify", idForValues: ['teamOrStatus', 'personName']},
    { columnId: 'note', columnName: 'Observação', width: '40%', align: "justify", isTextWrapped: true, idForValues: ['note']},
  ]
};

export default tableConfig;