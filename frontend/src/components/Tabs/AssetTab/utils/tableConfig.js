import React from 'react';

const mapIcon = require("../../../../assets/icons/map.png");

const tableConfig = {
  attForDataId: 'assetId',
  hasCheckbox: true,
  checkboxWidth: '5%',
  isItemClickable: false,
  dataAttForClickable: 'title',
  columnsConfig: [
    { columnId: 'name', columnName: 'Ativo', width: "40%", align: "justify", idForValues: ['name', 'assetSf'] },
    { columnId: 'map', columnName: 'Planta', width: "10%", align: "center", createElement: (<img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />) }
  ],
};

export default tableConfig;