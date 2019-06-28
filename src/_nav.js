export default {
  items: [
    {
      name: "Painel",
      url: "/painel",
      icon: "cui-chart"
    },
    {
      name: "Monitor de consumo",
      url: "/consumo",
      icon: "icon-speedometer",
      children: [
        {
          name: "Água",
          url: "/agua",
          icon: "icon-drop"
        },
        {
          name: "Energia elétrica",
          url: "/energia",
          icon: "cui-lightbulb"
        }
      ]
    },
    {
      name: "Ativos",
      url: "/ativos",
      icon: "icon-tag",
    },
    {
      name: "Manutenção",
      url: "/manutencao",
      icon: "icon-wrench",
      children: [
        // {
        //   name: "Solicitações",
        //   url: "/manutencao/solicitacoes",
        //   icon: "icon-drop"
        // },
        {
          name: "Ordens de serviço",
          url: "/manutencao/os",
          icon: "icon-list"
        },
      ]
    },
  ]
};
