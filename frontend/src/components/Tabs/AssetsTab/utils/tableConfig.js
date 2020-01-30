import React from 'react';

const tableConfig = {
  numberOfColumns: 2,
  checkbox: true,
  itemPath: '/ativos/edificio/view/',
  itemClickable: true,
  idAttributeForData: 'assetId',
  columnObjects: [
    { name: 'name', description: 'Ativo', style: { width: "40%" }, className: "", data: ['name', 'assetSf'] }
  ],
};

export default tableConfig;