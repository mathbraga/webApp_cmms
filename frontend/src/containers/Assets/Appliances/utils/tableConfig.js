const tableConfig = {
  numberOfColumns: 3,
  checkbox: true,
  itemPath: '/ativos/equipamento/view/',
  itemClickable: true,
  idAttributeForData: 'assetSf',
  columnObjects: [
    { name: 'name', description: 'Equipamento', style: { width: "30%" }, className: "", data: ['name', 'assetSf'] },
    { name: 'model', description: 'Modelo', style: { width: "10%" }, className: "text-center", data: ['model'] },
    { name: 'manufacturer', description: 'Fabricante', style: { width: "10%" }, className: "text-center", data: ['manufacturer'] },
  ],
};

export default tableConfig;