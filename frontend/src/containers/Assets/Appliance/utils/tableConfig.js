import {
  ORDER_CATEGORY_TYPE,
  ORDER_STATUS_TYPE,
  ORDER_PRIORITY_TYPE
} from '../../../Maintenance/Tasks/utils/dataDescription';

function changeStatusDescription(item) {
  return [ORDER_STATUS_TYPE[item.status]];
}

function changeCategoryDescription(item) {
  return [item.description, ORDER_CATEGORY_TYPE[item.category]];
}

function changePriorityDescription(item) {
  return [ORDER_PRIORITY_TYPE[item.priority]];
}

function formatDateLimit(item) {
  return [item.dateLimit && item.dateLimit.split('T')[0]];
}

const tableConfig = {
  numberOfColumns: 6,
  checkbox: true,
  itemPath: '/manutencao/os/view/',
  itemClickable: true,
  idAttributeForData: 'orderId',
  columnObjects: [
    { name: 'orderId', description: 'OS', style: { width: "50px" }, className: "text-center", data: ['orderId'] },
    { name: 'description', description: 'Título', style: { width: "300px" }, className: "text-justify", data: ['description', 'category'], dataGenerator: changeCategoryDescription },
    { name: 'status', description: 'Status', style: { width: "100px" }, className: "text-center", data: ['status'], dataGenerator: changeStatusDescription },
    { name: 'priority', description: 'Prioridade', style: { width: "100px" }, className: "text-center", data: ['priority'], dataGenerator: changePriorityDescription },
    { name: 'dateLimit', description: 'Prazo Final', style: { width: "100px" }, className: "text-center", data: ['dateLimit'], dataGenerator: formatDateLimit },
  ],
};

export default tableConfig;