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



const tableConfig = {
  attForDataId: 'time',
  prepareData: {
    eventName: generateEventName,
  },
  columnsConfig: [
    { columnId: 'date', columnName: 'Data', width: '15%', align: "center", idForValues: ['time']},
    { columnId: 'event', columnName: 'Evento', width: '20%', align: "center", idForValues: ['eventName']},
    { columnId: 'team', columnName: 'Equipe / Status', width: '25%', align: "justify", idForValues: ['senderName', 'personName']},
    { columnId: 'note', columnName: 'Observação', width: '40%', align: "justify", isTextWrapped: true, idForValues: ['note']},
  ]
};

export default tableConfig;