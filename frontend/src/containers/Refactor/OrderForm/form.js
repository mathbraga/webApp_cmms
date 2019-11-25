export const form = {
  cardTitle: 'Título do formulário',
  inputs: [
    {
      id: 'text',
      label: 'text',
      name: 'text',
      type: 'text',
      value: 'hehhe',
      placeholder: 'text',
      required: false,
      selectDefault: null,
      selectOptions: [],
    },
    {
      id: 'contract',
      label: 'contract',
      name: 'contract',
      type: 'select',
      placeholder: 'contract',
      required: true,
      selectDefault: null,
      selectOptions: [
        {
          id: '1',
          name: '1',
          value: 1,
          label: '1'
        },
        {
          id: '2',
          name: '2',
          value: 2,
          label: '2'
        },
      ],
    }
  ]
};