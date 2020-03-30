import React from 'react';

function createParentElement(parent) {
  return `${parent.assetSf}: ${parent.name}`;
}

function createContextElement(context) {
  return `${context.name}`;
}

const tableConfig = {
  attForDataId: 'id',
  actionColumn: ['delete'],
  columnsConfig: [
    { columnId: 'parent', columnName: 'Ativo Pai', width: "70%", align: "justify", idForValues: ['parent'], createElementWithData: createParentElement },
    { columnId: 'context', columnName: 'Contexto', width: "30%", align: "center", idForValues: ['context'], createElementWithData: createContextElement },
  ],
};

export default tableConfig;