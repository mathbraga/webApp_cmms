const formatter = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format;

function formatCurrency(att) {
  return (function format(item) {
    return formatter(item[att]);
  });
}

function addUnit(att) {
  return (function add(item) {
    return `${item[att]} ${item.unit}`;
  });
}

const tableConfig = {
  attForDataId: 'supplyId',
  hasCheckbox: true,
  checkboxWidth: '5%',
  isItemClickable: false,
  dataAttForClickable: 'title',
  prepareData: {
    qtyInitial: addUnit("qtyInitial"),
    bidPrice: formatCurrency("bidPrice"),
    qtyConsumed: addUnit("qtyConsumed"),
    qtyBlocked: addUnit("qtyBlocked"),
    qtyAvailable: addUnit("qtyAvailable"),
  },
  columnsConfig: [
    { columnId: 'title', columnName: 'Material / Serviço', width: "35%", align: "justify", isTextWrapped: true, idForValues: ['name', 'supplySf'] },
    { columnId: 'qty', columnName: 'Quantidade', width: "12%", align: "center", isTextWrapped: true, idForValues: ['qtyInitial'] },
    { columnId: 'bidPrice', columnName: 'Preço', width: "12%", align: "center", idForValues: ['bidPrice'] },
    { columnId: 'consumed', columnName: 'Usado', width: "12%", align: "center", isTextWrapped: true, idForValues: ['qtyConsumed'] },
    { columnId: 'blocked', columnName: 'Bloqueado', width: "12%", align: "center", isTextWrapped: true, idForValues: ['qtyBlocked'] },
    { columnId: 'total', columnName: 'Saldo', width: "12%", align: "center", isTextWrapped: true, idForValues: ['qtyAvailable'] },
  ],
};

export default tableConfig;