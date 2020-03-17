import paths from '../../../../paths';

const tableConfig = {
  attForDataId: 'fileId',
  hasCheckbox: false,
  isItemClickable: false,
  isFileTable: true,
  fileColumnWidth: '10%',
  columnsConfig: [
    { columnId: 'name', columnName: 'Nome', width: "50%", align: "justify", idForValues: ['name', 'user'] },
    { columnId: 'size', columnName: 'Tamanho', width: "20%", align: "center", idForValues: ['size'] },
    { columnId: 'date', columnName: 'Criado em', width: "20%", align: "center", idForValues: ['date'] },
  ],
};

export default tableConfig;