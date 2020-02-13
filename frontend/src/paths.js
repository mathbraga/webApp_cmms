const paths = {
  facility: {
    all:          '/edificios',
    one:          '/edificios/ver/:id',
    create:       '/edificios/criar',
    update:       '/edificios/editar/:id',
    mutationDone: '/edificios/ver/',
  },
  appliance: {
    all:          '/equipamentos',
    one:          '/equipamentos/ver/:id',
    create:       '/equipamentos/criar',
    update:       '/equipamentos/editar/:id',
    mutationDone: '/equipamentos/ver/',
  }
};

export default paths;
