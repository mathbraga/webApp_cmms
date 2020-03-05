const tableConfig = {
  attForDataId: 'teamId',
  hasCheckbox: true,
  checkboxWidth: '5%',
  isItemClickable: false,
  columnsConfig: [
    { columnId: 'name', columnName: 'Nome da equipe', width: "65%", align: "justify", idForValues: ['name', 'description'] },
    { columnId: 'memberCount', columnName: 'Número de membros', width: "30%", align: "center", idForValues: ['memberCount'] },
  ],
};

export default tableConfig;