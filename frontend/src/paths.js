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
  contract: {
    all:      '/contratos',
    toOne:    '/contratos/ver/',
    one:      '/contratos/ver/:id',
    create:   '/contratos/criar',
    toUpdate: '/contratos/editar/',
    update:   '/contratos/editar/:id',
  },
  spec: {
    all:      '/espectec',
    toOne:    '/espectec/ver/',
    one:      '/espectec/ver/:id',
    create:   '/espectec/criar',
    toUpdate: '/espectec/editar/',
    update:   '/espectec/editar/:id',
  },
  team: {},
  person: {},
};

export default paths;
