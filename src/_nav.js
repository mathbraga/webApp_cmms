export default {
  items: [
    {
      name: "Painel",
      url: "/painel",
      icon: "cui-monitor"
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
      icon: "icon-speedometer",
    },
    {
      name: "Ordens de serviços",
      url: "/os",
      icon: "icon-speedometer",
    },
  ]
};
