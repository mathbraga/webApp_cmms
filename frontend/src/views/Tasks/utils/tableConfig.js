import paths from '../../../paths';

function formatDateLimit(item) {
  return item.dateLimit && item.dateLimit.split('T')[0];
}

const tableConfig = {
  attForDataId: 'taskId',
  hasCheckbox: true,
  checkboxWidth: '5%',
  isItemClickable: true,
  dataAttForClickable: 'title',
  itemPathWithoutID: paths.task.toOne,
  prepareData: {
    'dateLimitText': formatDateLimit,
  },
  columnsConfig: [
    { columnId: 'taskId', columnName: 'OS', width: "5%", align: "center", idForValues: ['taskId'] },
    { columnId: 'title', columnName: 'Título', width: "50%", align: "justify", idForValues: ['title', 'taskCategoryText'] },
    { columnId: 'status', columnName: 'Status', width: "10%", align: "center", idForValues: ['taskStatusText'] },
    { columnId: 'dateLimit', columnName: 'Prazo Final', width: "10%", align: "center", idForValues: ['dateLimitText'] },
    { columnId: 'place', columnName: 'Localização', width: "20%", isTextWrapped: true, align: "center", idForValues: ['place'] },
  ],
};

export default tableConfig;
