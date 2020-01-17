const tableConfig = {
  numberOfColumns: 6,
  checkbox: true,
  itemPath: '/manutencao/os/view/',
  idAttributeForData: 'orderId',
  columnObjects: [
    { name: 'orderId', description: 'OS', style: { width: "80px" }, className: "text-center", data: ['orderId'] },
    { name: 'title', description: 'Título', style: { width: "400px" }, className: "text-justify", data: ['title', 'category'] },
    { name: 'status', description: 'Status', style: { width: "100px" }, className: "text-center", data: ['status'] },
    { name: 'dateLimit', description: 'Prazo Final', style: { width: "100px" }, className: "text-center", data: ['dateLimit'] },
    { name: 'place', description: 'Localização', style: { width: "250px" }, className: "text-center", data: ['place'] },
  ],
};

export default tableConfig;