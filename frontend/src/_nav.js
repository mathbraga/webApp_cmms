import paths from './paths';

export default {
  items: [
    {
      name: "Painel",
      url: '/painel',
      icon: "cui-chart"
    },
    {
      name: "Ativos",
      url: "/ativos",
      icon: "fa fa-university",
      children: [
        {
          name: "Edifícios",
          url: paths.facility.all,
          icon: "icon-home"
        },
        {
          name: "Equipamentos",
          url: paths.appliance.all,
          icon: "icon-rocket"
        }
      ]
    },
    {
      name: "Manutenção",
      url: "/manutencao",
      icon: "icon-wrench",
      children: [
        {
          name: "Ordens de serviço",
          url: "/manutencao/os",
          icon: "icon-list"
        },
      ]
    },
    {
      name: "Gestão de Contratos",
      url: "/gestao",
      icon: "fa fa-book",
      children: [
        {
          name: "Contratos",
          url: paths.contract.all,
          icon: "fa fa-file-text-o"
        },
        {
          name: "Espec. Técnicas",
          url: paths.spec.all,
          icon: "icon-list"
        },
      ]
    },
    {
      name: "Recursos Humanos",
      url: "/equipes",
      icon: "fa fa-group",
      children: [
        {
          name: "Pessoas",
          url: "/equipes/pessoas",
          icon: "icon-user"
        },
        {
          name: "Equipes",
          url: "/equipes/grupos",
          icon: "icon-people"
        },
      ]
    },
  ]
};
