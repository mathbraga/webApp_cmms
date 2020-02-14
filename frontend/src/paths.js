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
  team: {
    all:      '/equipes',
    toOne:    '/equipes/ver/',
    one:      '/equipes/ver/:id',
    create:   '/equipes/criar',
    toUpdate: '/equipes/editar/',
    update:   '/equipes/editar/:id',
  },
  person: {
    all:      '/usuario',
    toOne:    '/usuario/ver/',
    one:      '/usuario/ver/:id',
    create:   '/usuario/criar',
    toUpdate: '/usuario/editar/',
    update:   '/usuario/editar/:id',
  },
};

export default paths;
