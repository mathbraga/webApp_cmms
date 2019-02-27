export default {
  items: [
    {
      name: "Painel Principal",
      url: "/dashboard",
      icon: "cui-monitor"
    },
    {
      name: "Consumo",
      url: "/consumo",
      icon: "icon-speedometer",
      children: [
        {
          name: "Água e Esgoto",
          url: "/consumo/agua",
          icon: "icon-drop"
        },
        {
          name: "Energia Elétrica",
          url: "/consumo/energia",
          icon: "cui-lightbulb"
        }
      ]
    }
  ]
};
