import { ORDER_CATEGORY_TYPE, ORDER_STATUS_TYPE } from './dataDescription';

function changeStatusDescription(item, dataDescription) {
  return [dataDescription[item.status]];
}

function changeCategoryDescription(item, dataDescription) {
  return [item.title, dataDescription[item.category]];
}

function formatDateLimit(item) {
  console.log("Item: ", item.dateLimit && item.dateLimit.split('T')[0]);
  return [item.dateLimit && item.dateLimit.split('T')[0]];
}

const tableConfig = {
  numberOfColumns: 6,
  checkbox: true,
  itemPath: '/manutencao/os/view/',
  itemClickable: true,
  idAttributeForData: 'orderId',
  columnObjects: [
    { name: 'orderId', description: 'OS', style: { width: "80px" }, className: "text-center", data: ['orderId'] },
    { name: 'title', description: 'Título', style: { width: "400px" }, className: "text-justify", data: ['title', 'category'], dataGenerator: (item) => changeCategoryDescription(item, ORDER_CATEGORY_TYPE) },
    { name: 'status', description: 'Status', style: { width: "100px" }, className: "text-center", data: ['status'] },
    { name: 'dateLimit', description: 'Prazo Final', style: { width: "100px" }, className: "text-center", data: ['dateLimit'], dataGenerator: (item) => formatDateLimit(item) },
    { name: 'place', description: 'Localização', style: { width: "250px" }, className: "text-center", data: ['place'] },
  ],
};

export default tableConfig;

// TODO => Create dataGenerator => Function to be applied on a data before using the data. Also used to access nested data.