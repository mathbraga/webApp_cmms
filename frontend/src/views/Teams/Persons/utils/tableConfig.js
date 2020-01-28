const tableConfig = {
  numberOfColumns: 3,
  checkbox: true,
  itemPath: '',
  itemClickable: false,
  idAttributeForData: 'cpf',
  columnObjects: [
    { name: 'name', description: 'Nome', style: { width: "300px" }, className: "", data: ['name'] },
    { name: 'phone', description: 'Telefone', style: { width: "150px" }, className: "text-center", data: ['phone'] },
    { name: 'email', description: 'E-mail', style: { width: "200px" }, className: "text-center", data: ['email'] },
  ],
};

export default tableConfig;