const paths = {
  facility: {
    all:      '/edificios',
    toOne:    '/edificios/ver/',
    one:      '/edificios/ver/:id',
    create:   '/edificios/criar',
    toUpdate: '/edificios/editar/',
    update:   '/edificios/editar/:id',
  },
  appliance: {
    all:      '/equipamentos',
    toOne:    '/equipamentos/ver/',
    one:      '/equipamentos/ver/:id',
    create:   '/equipamentos/criar',
    toUpdate: '/equipamentos/editar/',
    update:   '/equipamentos/editar/:id',
  },
  task: {},
  contract: {},
  spec: {},
  team: {},
  person: {},
};

export default paths;
