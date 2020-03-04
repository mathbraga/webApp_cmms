import paths from '../../../paths';

const tableConfig = {
  numberOfColumns: 4,
  checkbox: true,
  itemPath: paths.spec.toOne,
  itemClickable: true,
  idAttributeForData: 'specId',
  columnObjects: [
    { name: 'name', description: 'Material / Serviço', style: { width: "300px" }, className: "text-justify", data: ['name', 'specSf'] },
    { name: 'category', description: 'Categoria', style: { width: "200px" }, className: "text-center", data: ['specCategoryText'] },
    { name: 'subcategory', description: 'Subcategoria', style: { width: "200px" }, className: "text-center", data: ['specSubcategoryText'] },
    { name: 'totalAvailable', description: 'Disponível', style: { width: "70px" }, className: "text-center", data: ['totalAvailable'] }
  ],
};

export default tableConfig;