import { CONTRACT_STATUS } from './dataDescription';
import React from 'react';

function changeStatusDescription(item) {
  return [CONTRACT_STATUS[item.status]];
}

function calculateTimeSpan(item) {
  return [`${item.dateStart} a ${item.dateEnd}`];
}

function addLink(item) {
  return [
    <a
      href={item.url}
      target="_blank"
      rel="noopener noreferrer nofollow"
      onClick={(e) => e.stopPropagation()}
    >
      {"CT " + parseInt(item.contractSf.slice(2, 6), 10) + "/" + item.contractSf.slice(6)}
    </a>
  ];
}

const tableConfig = {
  numberOfColumns: 6,
  checkbox: true,
  itemPath: '/gestao/contratos/view/',
  itemClickable: true,
  idAttributeForData: 'contractId',
  columnObjects: [
    { name: 'contractSf', description: 'Número', style: { width: "100px" }, className: "text-center", data: ['contractSf'] },
    { name: 'title', description: 'Objeto', style: { width: "300px" }, className: "text-justify", data: ['title', 'company'] },
    { name: 'status', description: 'Status', style: { width: "150px" }, className: "text-center", data: ['contractStatusText'] },
    { name: 'dateEnd', description: 'Vigência', style: { width: "150px" }, className: "text-center", data: ['dateEnd'], dataGenerator: calculateTimeSpan },
    { name: 'url', description: 'Link', style: { width: "100px" }, className: "text-center", data: ['url'], dataGenerator: addLink },
  ],
};

export default tableConfig;