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
        body: [
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
            name: 'status',
            label: 'Status',
            field: 'status'
          },
          {
            name: 'priority',
            label: 'Prioridade',
            field: 'priority'
          },
          {
            name: 'category',
            label: 'Categoria',
            field: 'category'
          },
          {
            name: 'contractId',
            label: 'Contrato',
            field: 'contractId'
          },
          {
            name: 'departmentId',
            label: 'Departamento',
            field: 'departmentId'
          },
          {
            name: 'Criado por',
            label: 'createdBy',
            field: 'createdBy'
          },
          {
            name: 'contactName',
            label: 'Contato (nome)',
            field: 'contactName'
          },
          {
            name: 'contactPhone',
            label: 'Contato (telefone)',
            field: 'contactPhone'
          },
          {
            name: 'contactEmail',
            label: 'Contato (email)',
            field: 'contactEmail'
          },
          {
            name: 'place',
            label: 'Local (referência)',
            field: 'place'
          },
          {
            name: 'progresso',
            label: 'Progresso (%)',
            field: 'dateLimit'
          },
          {
            name: 'dateLimit',
            label: 'Prazo de conclusão',
            field: ''
          },
          {
            name: 'dateStart',
            label: 'Início da execução',
            field: 'dateStart'
          },
          {
            name: 'dateEnd',
            label: 'Data de conclusão',
            field: 'dateEnd'
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