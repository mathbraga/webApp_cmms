import paths from '../../../../paths';

const tableConfig = {
  attForDataId: 'eventID',
  columnsConfig: [
    { columnId: 'date', columnName: 'Data', width: '15%', align: "center", idForValues: ['time']},
    { columnId: 'event', columnName: 'Evento', width: '20%', align: "justify", idForValues: ['event', 'personName']},
    { columnId: 'team', columnName: 'Equipe', width: '25%', align: "justify", idForValues: ['recipientName']},
    { columnId: 'note', columnName: 'Observação', width: '40%', align: "justify", isTextWrapped: true, idForValues: ['note']},
  ]
};

export default tableConfig;