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
  attForDataId: 'supplySf',
  hasCheckbox: true,
  checkboxWidth: '5%',
  isItemClickable: false,
  dataAttForClickable: 'company',
  prepareData: {
    fullPrice: formatCurrency("fullPrice"),
    bidPrice: formatCurrency("bidPrice"),
  },
  columnsConfig: [
    { columnId: 'supplySf', columnName: 'Cód.', width: "5%", align: "center", idForValues: ['supplySf'] },
    { columnId: 'company', columnName: 'Empresa', width: "42%", align: "justify", idForValues: ['company', 'contractSf'] },
    { columnId: 'qty', columnName: 'Contratado', width: "12%", align: "center", idForValues: ['qtyInitial'] },
    { columnId: 'available', columnName: 'Disponível', width: "12%", align: "center", idForValues: ['qtyAvailable'] },
    { columnId: 'fullPrice', columnName: 'Preço', width: "12%", align: "center", idForValues: ['fullPrice'] },
    { columnId: 'bidPrice', columnName: 'Pesquisa', width: "12%", align: "center", idForValues: ['bidPrice'] },
  ],
};

export default tableConfig;