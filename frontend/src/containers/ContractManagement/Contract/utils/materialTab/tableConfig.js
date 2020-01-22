const formatter = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format;

function formatCurreny(item, key) {
  return [formatter(item[key])];
}

function addUnit(item, key) {
  return [`${item[key]} ${item.unit}`];
}

function calculateBalance(item) {
  return [`${item.qty - item.consumed - item.blocked} ${item.unit}`];
}

const tableConfig = {
  numberOfColumns: 6,
  checkbox: true,
  itemPath: '/manutencao/os/view/',
  itemClickable: false,
  idAttributeForData: 'supplySf',
  columnObjects: [
    { name: 'title', description: 'Material / Serviço', style: { width: "250px" }, className: "text-justify", data: ['name', 'supplySf'] },
    { name: 'qty', description: 'Quantidade', style: { width: "70px" }, className: "text-center", data: ['qty'], dataGenerator: (item) => addUnit(item, 'qty') },
    { name: 'bidPrice', description: 'Preço', style: { width: "70px" }, className: "text-center", data: ['bidPrice'], dataGenerator: (item) => formatCurreny(item, 'bidPrice') },
    { name: 'consumed', description: 'Usado', style: { width: "70px" }, className: "text-center", data: ['consumed'], dataGenerator: (item) => addUnit(item, 'consumed') },
    { name: 'blocked', description: 'Bloqueado', style: { width: "70px" }, className: "text-center", data: ['blocked'], dataGenerator: (item) => addUnit(item, 'blocked') },
    { name: 'total', description: 'Saldo', style: { width: "70px" }, className: "text-center", data: ['total'], dataGenerator: calculateBalance },
  ],
};

export default tableConfig;