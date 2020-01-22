const formatter = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format;

function addUnit(item, key) {
  return [`${item[key]} ${item.unit}`];
}

const tableConfig = {
  numberOfColumns: 6,
  checkbox: true,
  itemPath: '/manutencao/os/view/',
  itemClickable: false,
  idAttributeForData: 'specId',
  columnObjects: [
    { name: 'supplySf', description: 'Código', style: { width: "40px" }, className: "text-center", data: ['supplySf'] },
    { name: 'company', description: 'Empresa', style: { width: "100px" }, className: "text-justify", data: ['company', 'contractSf'] },
    { name: 'qty', description: 'Contratado', style: { width: "70px" }, className: "text-center", data: ['qty'] },
    { name: 'available', description: 'Disponível', style: { width: "70px" }, className: "text-center", data: ['available'] },
    { name: 'fullPrice', description: 'Preço', style: { width: "70px" }, className: "text-center", data: ['fullPrice'], dataGenerator: (item) => ([formatter(item.fullPrice)]) },
    { name: 'bidPrice', description: 'Pesquisa', style: { width: "70px" }, className: "text-center", data: ['bidPrice'], dataGenerator: (item) => ([formatter(item.bidPrice)]) },
  ],
};

export default tableConfig;