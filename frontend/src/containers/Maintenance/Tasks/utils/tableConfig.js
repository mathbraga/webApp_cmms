import { ORDER_CATEGORY_TYPE, ORDER_STATUS_TYPE } from './dataDescription';

function changeDataDescription(item, dataDescription, dataID) {
  const result = dataID.map((ID) => ([dataDescription[item[ID]]]))
  return result;
}

const tableConfig = {
  numberOfColumns: 6,
  checkbox: true,
  itemPath: '/manutencao/os/view/',
  idAttributeForData: 'orderId',
  columnObjects: [
    { name: 'orderId', description: 'OS', style: { width: "80px" }, className: "text-center", data: ['orderId'] },
    { name: 'title', description: 'Título', style: { width: "400px" }, className: "text-justify", data: ['title', 'category'] },
    { name: 'status', description: 'Status', style: { width: "100px" }, className: "text-center", data: ['status'], dataGenerator: (item) => changeDataDescription(item, ORDER_STATUS_TYPE, ["status"]) },
    { name: 'dateLimit', description: 'Prazo Final', style: { width: "100px" }, className: "text-center", data: ['dateLimit'] },
    { name: 'place', description: 'Localização', style: { width: "250px" }, className: "text-center", data: ['place'] },
  ],
};

export default tableConfig;

// TODO => Create dataGenerator => Function to be applied on a data before using the data. Also used to access nested data.