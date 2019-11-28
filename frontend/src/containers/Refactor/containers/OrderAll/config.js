export default {
  title: 'Ordens de Serviço',
  columns: [
    {
      label: '#',
      width: '100',
      field: 'orderId',
    },
    {
      label: 'Título',
      width: '100',
      field: 'title',
    },
    {
      label: 'Categoria',
      width: '100',
      field: 'category',
    },
    {
      label: 'Status',
      width: '100',
      field: 'status',
    },
    {
      label: 'Data de Abertura',
      width: '100',
      field: 'createdAt',
    },
  ],
  list: [
    {
      orderId: '',
      title: '',
      category: '',
      status: '',
      createdAt: '',
    },
  ]
};