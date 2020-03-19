import paths from '../../../../paths';

const tableConfig = {
  attForDataId: 'taskId',
  hasCheckbox: true,
  checkboxWidth: '5%',
  isItemClickable: true,
  dataAttForClickable: 'title',
  itemPathWithoutID: paths.task.toOne,
  columnsConfig: [
    { columnId: 'taskId', columnName: 'OS', width: "5%", align: "center", idForValues: ['taskId'] },
    { columnId: 'title', columnName: 'Descrição', width: "55%", align: "justify", isTextWrapped: true, idForValues: ['title', 'taskCategoryText'] },
    { columnId: 'status', columnName: 'Status', width: "15%", align: "center", idForValues: ['taskStatusText'] },
    { columnId: 'place', columnName: 'Localização', width: "20%", align: "center", idForValues: ['place'] },
  ]
};

export default tableConfig;