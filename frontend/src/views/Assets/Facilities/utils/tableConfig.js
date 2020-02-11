import React from 'react';

const mapIcon = require("../../../../assets/icons/map.png");

const tableConfig = {
  numberOfColumns: 3,
  checkbox: true,
  itemPath: '/edificios/ver/',
  itemClickable: true,
  idAttributeForData: 'assetId',
  columnObjects: [
    { name: 'name', description: 'Ativo', style: { width: "40%" }, className: "", data: ['name', 'assetSf'] },
    { name: 'area', description: 'Área', style: { width: "15%" }, className: "text-center", data: ['area'] },
    { name: 'map', description: 'Planta', style: { width: "10%" }, className: "text-center", createElement: (<img src={mapIcon} alt="Google Maps" style={{ width: "35px", height: "35px" }} />) },
  ],
};

export default tableConfig;