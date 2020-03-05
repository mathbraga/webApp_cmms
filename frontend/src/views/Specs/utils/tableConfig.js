import paths from '../../../paths';

function calculeAvailableWithUnit(item) {
  console.log("Item: ", item);
  return `${item.totalAvailable}`;
}

const tableConfig = {
  attForDataId: 'specId',
  hasCheckbox: true,
  checkboxWidth: '5%',
  isItemClickable: true,
  dataAttForClickable: 'name',
  itemPathWithoutID: paths.spec.toOne,
  prepareData: {
    availableWithUnit: calculeAvailableWithUnit
  },
  columnsConfig: [
    { columnId: 'name', columnName: 'Material / Serviço', width: "50%", align: "justify", idForValues: ['name', 'specSf'] },
    { columnId: 'category', columnName: 'Categoria', width: "20%", align: "center", idForValues: ['specCategoryText'] },
    { columnId: 'subcategory', columnName: 'Subcategoria', width: "15%", align: "center", idForValues: ['specSubcategoryText'] },
    { columnId: 'totalAvailable', columnName: 'Disponível', width: "10%", align: "center", idForValues: ['availableWithUnit'] }
  ],
};

export default tableConfig;