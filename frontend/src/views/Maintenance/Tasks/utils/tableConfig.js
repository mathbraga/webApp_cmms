import { ORDER_CATEGORY_TYPE, ORDER_STATUS_TYPE } from './dataDescription';

function changeStatusDescription(item) {
  return [ORDER_STATUS_TYPE[item.status]];
}

function changeCategoryDescription(item) {
  return [item.title, ORDER_CATEGORY_TYPE[item.category]];
}

function formatDateLimit(item) {
  return [item.dateLimit && item.dateLimit.split('T')[0]];
}

function fakeData() {
  return ['Fake'];
}

const tableConfig = {
  numberOfColumns: 6,
  checkbox: true,
  itemPath: '/manutencao/os/view/',
  itemClickable: true,
  idAttributeForData: 'taskId',
  columnObjects: [
    { name: 'orderId', description: 'OS', style: { width: "80px" }, className: "text-center", data: ['taskId'] },
    { name: 'title', description: 'Título', style: { width: "400px" }, className: "text-justify", data: ['title', 'category'], dataGenerator: changeCategoryDescription },
    { name: 'status', description: 'Status', style: { width: "100px" }, className: "text-center", data: ['status'], dataGenerator: fakeData },
    { name: 'dateLimit', description: 'Prazo Final', style: { width: "100px" }, className: "text-center", data: ['dateLimit'], dataGenerator: formatDateLimit },
    { name: 'place', description: 'Localização', style: { width: "250px" }, className: "text-center", data: ['place'] },
  ],
};

export default tableConfig;

// TODO => Create dataGenerator => Function to be applied on a data before using the data. Also used to access nested data.