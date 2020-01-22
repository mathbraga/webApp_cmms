const formatter = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format;

const tableConfig = {
  numberOfColumns: 6,
  checkbox: true,
  itemPath: '/manutencao/os/view/',
  itemClickable: false,
  idAttributeForData: 'specId',
  columnObjects: [
    { name: 'supplySf', description: 'Código', style: { width: "40px" }, className: "text-center", data: ['supplySf'] },
    { name: 'name', description: 'Descrição', style: { width: "200px" }, className: "text-justify", data: ['name'] },
    { name: 'qty', description: 'Quantidade', style: { width: "50px" }, className: "text-center", data: ['qty'] },
    { name: 'bidPrice', description: 'Preço Unitário', style: { width: "70px" }, className: "text-center", data: ['bidPrice'], dataGenerator: (item) => ([formatter(item.bidPrice)]) },
    { name: 'total', description: 'Total', style: { width: "70px" }, className: "text-center", data: ['total'], dataGenerator: (item) => ([formatter(item.total)]) },
  ],
};

export default tableConfig;