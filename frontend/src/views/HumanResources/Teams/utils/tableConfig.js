const tableConfig = {
  numberOfColumns: 2,
  checkbox: true,
  itemPath: '',
  itemClickable: false,
  idAttributeForData: 'teamId',
  columnObjects: [
    { name: 'name', description: 'Nome da equipe', style: {}, className: "", data: ['name', 'description'] },
    { name: 'memberCount', description: 'Número de membros', style: {}, className: "text-center", data: ['memberCount'] },
  ],
};

export default tableConfig;