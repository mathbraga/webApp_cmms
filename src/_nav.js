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
      url: "/ativos/todos",
      icon: "icon-speedometer",
      // children: [
      //   {
      //     name: "Todos",
      //     url: "/ativos/todos",
      //     icon: "icon-drop"
      //   },
      //   {
      //     name: "Edifícios e áreas",
      //     url: "/ativos/edificios",
      //     icon: "icon-drop"
      //   },
      //   {
      //     name: "Equipamentos",
      //     url: "/ativos/equipamentos",
      //     icon: "icon-drop"
      //   },
      //   {
      //     name: "Ferramentas",
      //     url: "/ativos/ferramentas",
      //     icon: "icon-drop"
      //   },
      //   {
      //     name: "Materiais",
      //     url: "/ativos/materiais",
      //     icon: "icon-drop"
      //   }
      // ]
    }
  ]
};
