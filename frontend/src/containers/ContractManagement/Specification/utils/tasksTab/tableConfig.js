import { ORDER_STATUS_TYPE } from '../../../../Maintenance/Tasks/utils/dataDescription'

function displayStatus(item) {
  return [ORDER_STATUS_TYPE[item.status]];
}

const tableConfig = {
  numberOfColumns: 3,
  checkbox: true,
  itemPath: '/manutencao/os/view/',
  itemClickable: false,
  idAttributeForData: 'orderId',
  columnObjects: [
    { name: 'orderId', description: 'OS', style: { width: "50px" }, className: "text-center", data: ['orderId'] },
    { name: 'title', description: 'Descrição', style: { width: "300px" }, className: "text-justify", data: ['title'] },
    { name: 'status', description: 'Status', style: { width: "70px" }, className: "text-center", data: ['status'], dataGenerator: displayStatus },
    { name: 'place', description: 'Localização', style: { width: "150px" }, className: "text-center", data: ['place'] },
  ]
};

export default tableConfig;