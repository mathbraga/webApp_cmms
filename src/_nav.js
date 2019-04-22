export default {
  items: [
    {
      name: "Painel SINFRA",
      url: "/dashboard",
      icon: "cui-monitor"
    },
    {
      name: "Login",
      url: "/login",
      icon: ""
    },
    {
      name: "Cadastro",
      url: "/cadastro",
      icon: ""
    },
    {
      name: "Monitor de consumo",
      url: "/consumo",
      icon: "icon-speedometer",
      children: [
        // {
        //   name: "Água",
        //   url: "/consumo/agua",
        //   icon: "icon-drop"
        // },
        {
          name: "Energia elétrica",
          url: "/consumo/energia",
          icon: "cui-lightbulb"
        }
      ]
    }
  ]
};
