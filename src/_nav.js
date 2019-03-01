export default {
  items: [
    {
      name: "Início",
      url: "/dashboard",
      icon: "cui-monitor"
    },
    {
      name: "Consumo",
      url: "/consumo",
      icon: "icon-speedometer",
      children: [
        {
          name: "Água e esgoto",
          url: "/consumo/agua",
          icon: "icon-drop"
        },
        {
          name: "Energia elétrica",
          url: "/consumo/energia",
          icon: "cui-lightbulb"
        }
      ]
    }
  ]
};
