import paths from '../../../../paths';

const tableConfig = {
  numberOfColumns: 3,
  checkbox: true,
  itemPath: paths.facility.toOne,
  itemClickable: true,
  idAttributeForData: 'assetId',
  columnObjects: [
    { name: 'name', description: 'Ativo', style: { width: "300px" }, className: "text-justify", data: ['name', 'assetSf'] },
    { name: 'place', description: 'Localização', style: { width: "150px" }, className: "text-center", data: ['place'] }
  ]
};

export default tableConfig;