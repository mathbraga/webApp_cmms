import paths from './paths';

export default {
  items: [
    {
      name: "Painel",
      url: paths.DASHBOARD,
      icon: "cui-chart"
    },
    // {
    //   name: "Monitor de consumo",
    //   url: "/consumo",
    //   icon: "icon-speedometer",
    //   children: [
    //     {
    //       name: "Água",
    //       url: "/agua",
    //       icon: "icon-drop"
    //     },
    //     {
    //       name: "Energia elétrica",
    //       url: "/energia",
    //       icon: "cui-lightbulb"
    //     }
    //   ]
    // },
    {
      name: "Ativos",
      url: "/ativos",
      icon: "fa fa-university",
      children: [
        {
          name: "Edifícios",
          url: "/ativos/edificios",
          icon: "icon-home"
        },
        {
          name: "Equipamentos",
          url: "/ativos/equipamentos",
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
          url: "/gestao/contratos",
          icon: "fa fa-file-text-o"
        },
        {
          name: "Espec. Técnicas",
          url: "/gestao/servicos",
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
          name: "Equipes",
          url: "/equipes/grupos",
          icon: "icon-people"
        },
        {
          name: "Pessoas",
          url: "/equipes/pessoas",
          icon: "icon-user"
        },
      ]
    },
  ]
};
