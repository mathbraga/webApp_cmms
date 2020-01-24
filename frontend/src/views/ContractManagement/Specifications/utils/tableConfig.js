const tableConfig = {
  numberOfColumns: 4,
  checkbox: true,
  itemPath: '/gestao/servicos/view/',
  itemClickable: true,
  idAttributeForData: 'specId',
  columnObjects: [
    { name: 'name', description: 'Material / Serviço', style: { width: "300px" }, className: "text-justify", data: ['name', 'specSf'] },
    { name: 'category', description: 'Categoria', style: { width: "200px" }, className: "text-center", data: ['category'] },
    { name: 'subcategory', description: 'Subcategoria', style: { width: "200px" }, className: "text-center", data: ['subcategory'] },
  ],
};

export default tableConfig;