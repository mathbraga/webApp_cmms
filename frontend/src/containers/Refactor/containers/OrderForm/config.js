export default {
  title: 'Nova Ordem de Serviço',
  inputs: [
    // OBJECT MANDATORY FORMAT:
    // {
    //   autoFocus: false,
    //   id: 'id',
    //   label: 'label',
    //   multiple: false,
    //   name: 'name',
    //   options: [],
    //   placeholder: 'placeholder',
    //   required: false,
    //   type: 'type',
    // },
    {
      autoFocus: true,
      id: 'title',
      label: 'title',
      multiple: false,
      name: 'title',
      options: [],
      placeholder: 'title',
      required: true,
      type: 'text',
    },
    {
      autoFocus: false,
      id: 'description',
      label: 'description',
      multiple: false,
      name: 'description',
      options: [],
      placeholder: 'description',
      required: true,
      type: 'textarea',
    },
    {
      autoFocus: false,
      id: 'assets',
      label: 'assets',
      multiple: true,
      name: 'assets',
      options: [],
      placeholder: 'assets',
      required: true,
      type: 'select',
    },
    {
      autoFocus: false,
      id: 'status',
      label: 'status',
      multiple: false,
      name: 'status',
      options: [
        {
          value: null,
          text: 'Selecione o status'
        },
      ],
      placeholder: 'status',
      required: true,
      type: 'select',
    },
    {
      autoFocus: false,
      id: 'priority',
      label: 'priority',
      multiple: false,
      name: 'priority',
      options: [
        {
          value: null,
          text: 'Selecione a prioridade'
        },
      ],
      placeholder: 'priority',
      required: true,
      type: 'select',
    },
    {
      autoFocus: false,
      id: 'category',
      label: 'category',
      multiple: false,
      name: 'category',
      options: [
        {
          value: null,
          text: 'Selecione a categoria'
        },
      ],
      placeholder: 'category',
      required: true,
      type: 'select',
    },
    {
      autoFocus: false,
      id: 'parent',
      label: 'parent',
      multiple: false,
      name: 'parent',
      options: [],
      placeholder: 'parent',
      required: false,
      type: 'text',
    },
    {
      autoFocus: false,
      id: 'contractId',
      label: 'contractId',
      multiple: false,
      name: 'contractId',
      options: [
        {
          value: '1',
          text: '1'
        },
        {
          value: '2',
          text: '2'
        },
        {
          value: '3',
          text: '3'
        },  
      ],
      placeholder: 'contractId',
      required: false,
      type: 'select',
    },
    {
      autoFocus: false,
      id: 'departmentId',
      label: 'departmentId',
      multiple: false,
      name: 'departmentId',
      options: [],
      placeholder: 'departmentId',
      required: false,
      type: 'text',
    },
    {
      autoFocus: false,
      id: 'createdBy',
      label: 'createdBy',
      multiple: false,
      name: 'createdBy',
      options: [],
      placeholder: 'createdBy',
      required: false,
      type: 'text',
    },
    {
      autoFocus: false,
      id: 'contactName',
      label: 'contactName',
      multiple: false,
      name: 'contactName',
      options: [],
      placeholder: 'contactName',
      required: false,
      type: 'text',
    },
    {
      autoFocus: false,
      id: 'contactPhone',
      label: 'contactPhone',
      multiple: false,
      name: 'contactPhone',
      options: [],
      placeholder: 'contactPhone',
      required: false,
      type: 'text',
    },
    {
      autoFocus: false,
      id: 'contactEmail',
      label: 'contactEmail',
      multiple: false,
      name: 'contactEmail',
      options: [],
      placeholder: 'contactEmail',
      required: false,
      type: 'text',
    },
    {
      autoFocus: false,
      id: 'place',
      label: 'place',
      multiple: false,
      name: 'place',
      options: [],
      placeholder: 'place',
      required: false,
      type: 'text',
    },
    {
      autoFocus: false,
      id: 'progress',
      label: 'progress',
      multiple: false,
      name: 'progress',
      options: [],
      placeholder: 'progress',
      required: false,
      type: 'text',
    },
    {
      autoFocus: false,
      id: 'dateLimit',
      label: 'dateLimit',
      multiple: false,
      name: 'dateLimit',
      options: [],
      placeholder: 'dateLimit',
      required: false,
      type: 'date',
    },
    {
      autoFocus: false,
      id: 'dateStart',
      label: 'dateStart',
      multiple: false,
      name: 'dateStart',
      options: [],
      placeholder: 'dateStart',
      required: false,
      type: 'date',
    },
    {
      autoFocus: false,
      id: 'dateEnd',
      label: 'dateEnd',
      multiple: false,
      name: 'dateEnd',
      options: [],
      placeholder: 'dateEnd',
      required: false,
      type: 'date',
    },
    {
      autoFocus: false,
      id: 'files',
      label: 'files',
      multiple: true,
      name: 'files',
      options: [],
      placeholder: 'files',
      required: false,
      type: 'file',
    },
  ]
};