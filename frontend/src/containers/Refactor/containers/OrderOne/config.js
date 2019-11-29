export default {
  tabs: [
    {
      tabName: 'details',
      label: 'Detalhes',
      table: {
        noHead: true,
        head: [
          {
            field: 'label'
          },
          {
            field: 'value'
          }
        ],
        rows: [
          {
            name: 'title',
            label: 'Título',
            field: 'title'
          },
          {
            name: 'description',
            label: 'Descrição',
            field: 'description'
          },
          {
            name: 'category',
            label: 'Categoria',
            field: 'category'
          },
        ]
      }
    },
    {
      tabName: 'assets',
      label: 'Ativos',
      table: {
        noHead: false,
        head: [
          {
            field: 'sf',
            label: 'Código',
          },
          {
            field: 'name',
            label: 'Nome',
          }
        ],
      }
    },
    {
      tabName: 'supplies',
      label: 'Materiais e Serviços',
      table: {
        noHead: false,
        head: [
          {
            field: 'sf',
            label: 'Código',
          },
          {
            field: 'name',
            label: 'Nome',
          },
          {
            field: 'qty',
            label: 'Quantidade',
          },
        ],
      }
    },
    {
      tabName: 'files',
      label: 'Arquivos',
      table: {
        noHead: false,
        head: [
          {
            field: 'filename',
            label: 'Nome do Arquivo',
          },
          {
            field: 'size',
            label: 'Tamanho (bytes)',
          },
          {
            field: 'person',
            label: 'Adicionado por'
          },
          {
            field: 'createdAt',
            label: 'Adicionado em'
          },
        ],
      }
    },
  ],
};