import paths from '../../../../paths';

const formatter = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format;

function formatCurrency(att) {
  return (function format(item) {
    return formatter(item[att]);
  });
}

function addUnit(item) {
  return [`${item.qty} ${item.unit}`]
}

const tableConfig = {
  attForDataId: 'supplyId',
  isItemClickable: true,
  dataAttForClickable: 'name',
  itemPathWithoutID: paths.spec.toOne,
  actionColumn: ['delete'],
  actionColumnWidth: '10%',
  prepareData: {
    qtyWithUnit: addUnit,
    bidPriceText: formatCurrency("bidPrice"),
    totalPriceText: formatCurrency("totalPrice"),
  },
  columnsConfig: [
    { columnId: 'supplySf', columnName: 'Código', width: "10%", align: "center", idForValues: ['supplySf'] },
    { columnId: 'name', columnName: 'Descrição', width: "40%", align: "justify", isTextWrapped: true, idForValues: ['name'] },
    { columnId: 'qty', columnName: 'Quantidade', width: "13%", align: "center", isTextWrapped: true, idForValues: ['qtyWithUnit'] },
    { columnId: 'bidPrice', columnName: 'Preço Unitário', width: "13%", align: "center", idForValues: ['bidPriceText'] },
    { columnId: 'totalPrice', columnName: 'Total', width: "14%", align: "center", idForValues: ['totalPriceText'] },
  ],
};

export default tableConfig;