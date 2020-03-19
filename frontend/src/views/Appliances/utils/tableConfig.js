import paths from '../../../paths';

const tableConfig = {
  attForDataId: 'assetId',
  hasCheckbox: true,
  checkboxWidth: '5%',
  isItemClickable: true,
  dataAttForClickable: 'name',
  itemPathWithoutID: paths.appliance.toOne,
  columnsConfig: [
    { columnId: 'name', columnName: 'Equipamento', width: "30%", align: "justify", idForValues: ['name', 'assetSf'] },
    { columnId: 'model', columnName: 'Modelo', width: "10%", align: "center", idForValues: ['model'] },
    { columnId: 'manufacturer', columnName: 'Fabricante', width: "10%", align: "center", idForValues: ['manufacturer'] },
  ],
};

export default tableConfig;