const formatter = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format;

function formatCurreny(item, key) {
  return [formatter(item[key])];
}

function addUnit(item, key) {
  return [`${item[key]} ${item.unit}`];
}

const tableConfig = {
  numberOfColumns: 6,
  checkbox: true,
  itemPath: '/manutencao/os/view/',
  itemClickable: false,
  idAttributeForData: 'supplyId',
  columnObjects: [
    { name: 'title', description: 'Material / Serviço', style: { width: "250px" }, className: "text-justify", data: ['name', 'supplySf'] },
    { name: 'qty', description: 'Quantidade', style: { width: "70px" }, className: "text-center", data: ['qty'], dataGenerator: (item) => addUnit(item, 'qtyInitial') },
    { name: 'bidPrice', description: 'Preço', style: { width: "70px" }, className: "text-center", data: ['bidPrice'], dataGenerator: (item) => formatCurreny(item, 'bidPrice') },
    { name: 'consumed', description: 'Usado', style: { width: "70px" }, className: "text-center", data: ['consumed'], dataGenerator: (item) => addUnit(item, 'qtyConsumed') },
    { name: 'blocked', description: 'Bloqueado', style: { width: "70px" }, className: "text-center", data: ['blocked'], dataGenerator: (item) => addUnit(item, 'qtyBlocked') },
    { name: 'total', description: 'Saldo', style: { width: "70px" }, className: "text-center", data: ['total'], dataGenerator: (item) => addUnit(item, 'qtyAvailable') },
  ],
};

export default tableConfig;