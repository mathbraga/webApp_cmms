import paths from '../../../paths';

import React from 'react';

function prepareDate(item) {
  return [`${item.dateStart} a ${item.dateEnd}`];
}

function prepareUrlText(item) {
  return `CT ${parseInt(item.contractSf.slice(2, 6), 10)}/${item.contractSf.slice(6)}`;
}

function createUrlElement(url, item) {
  return (
    <a
      href={url}
      target="_blank"
      rel="noopener noreferrer nofollow"
      onClick={(e) => e.stopPropagation()}
    >
      {item.urlText}
    </a>
  );
}



const tableConfig = {
  attForDataId: 'contractId',
  hasCheckbox: true,
  checkboxWidth: '5%',
  isItemClickable: true,
  dataAttForClickable: 'title',
  itemPathWithoutID: paths.contract.toOne,
  prepareData: {
    dateEndText: prepareDate,
    urlText: prepareUrlText,
  },
  columnsConfig: [
    { columnId: 'contractSf', columnName: 'Número', width: "10%", align: "center", idForValues: ['contractSf'] },
    { columnId: 'title', columnName: 'Objeto', width: "45%", align: "justify", idForValues: ['title', 'company'] },
    { columnId: 'status', columnName: 'Status', width: "10%", align: "center", idForValues: ['contractStatusText'] },
    { columnId: 'dateEnd', columnName: 'Vigência', width: "20%", align: "center", idForValues: ['dateEndText'] },
    { columnId: 'url', columnName: 'Link', width: "10%", align: "center", idForValues: ['url'], createElementWithData: createUrlElement },
  ],
};

export default tableConfig;