import React from 'react';

const mapIcon = require("../../../assets/icons/map.png");

function prepareArea(area) {
  if (area) {
    return (`${new Intl.NumberFormat('pt-BR', { maximumFractionDigits: 0 }).format(area)} m²`);
  }
  return null;
}

const tableConfig = {
  attForDataId: 'assetId',
  hasCheckbox: true,
  checkboxWidth: '5%',
  isItemClickable: true,
  dataAttForClickable: 'name',
  itemPathWithoutID: '/edificios/ver/',
  prepareData: {
    area: prepareArea,
  },
  prepareDisplayElement: false,
  columnsConfig: [
    { columnId: 'name', columnName: 'Ativo', width: "40%", align: "justify", idForValues: ['name', 'assetSf'] },
    { columnId: 'area', columnName: 'Área', width: "15%", align: "center", idForValues: ['area'] },
    { columnId: 'map', columnName: 'Planta', width: "10%", align: "center", createElement: (<img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />) },
  ],
};

export default tableConfig;