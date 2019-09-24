export default {
  items: [
    {
      name: "Painel",
      url: "/painel",
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
      icon: "icon-speedometer",
      children: [
        {
          name: "Edifícios",
          url: "/ativos/edificios",
          icon: "icon-speedometer"
        },
        {
          name: "Equipamentos",
          url: "/ativos/equipamentos",
          icon: "icon-speedometer"
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
  ]
};
