export const rowNames = {
  energy: [
    {
      name: "Consumo",
      type: "main",
      unit: "",
      attr: "",
      var: false,
      mean: false,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Horário ponta",
      type: "sub-1",
      unit: "",
      attr: "",
      var: false,
      mean: false,
      showInTypes: [1, 2]
    },
    {
      name: "Consumo registrado",
      type: "hover-line sub-2",
      unit: "kWh",
      attr: "kwhp",
      var: true,
      mean: true,
      showInTypes: [1, 2]
    },
    {
      name: "Tarifa",
      type: "hover-line sub-2",
      unit: "R$/kWh",
      attr: "",
      var: true,
      mean: false,
      showInTypes: [1, 2]
    },
    {
      name: "Valor",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "",
      var: true,
      mean: false,
      showInTypes: [1, 2]
    },
    {
      name: "Horário fora de ponta",
      type: "sub-1",
      unit: "",
      attr: "",
      var: false,
      mean: false,
      showInTypes: [1, 2]
    },
    {
      name: "Consumo registrado",
      type: "hover-line sub-2",
      unit: "kWh",
      attr: "kwhf",
      var: true,
      mean: true,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Consumo faturado",
      type: "hover-line sub-2",
      unit: "kWh",
      attr: "confat",
      var: true,
      mean: true,
      showInTypes: [0]
    },
    {
      name: "Tarifa",
      type: "hover-line sub-2",
      unit: "R$/kWh",
      attr: "",
      var: true,
      mean: false,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Valor",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "",
      var: true,
      mean: false,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Consumo total",
      type: "hover-line sub-1",
      unit: "kWh",
      attr: "kwh",
      var: true,
      mean: true,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Valor total",
      type: "hover-line sub-1",
      unit: "R$",
      attr: "",
      var: false,
      mean: false,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Demanda",
      type: "main",
      unit: "",
      attr: "",
      var: false,
      mean: false,
      showInTypes: [1, 2]
    },
    {
      name: "Horário ponta",
      type: "sub-1",
      unit: "",
      attr: "",
      var: false,
      mean: false,
      justBlue: true,
      showInTypes: [2]
    },
    {
      name: "Medido",
      type: "hover-line sub-2",
      unit: "kW",
      attr: "dmp",
      var: true,
      mean: true,
      justBlue: true,
      showInTypes: [2]
    },
    {
      name: "Contratado",
      type: "hover-line sub-2",
      unit: "kW",
      attr: "dcp",
      var: false,
      mean: false,
      justBlue: true,
      showInTypes: [2]
    },
    {
      name: "Faturado",
      type: "hover-line sub-2",
      unit: "kW",
      attr: "dfp",
      var: true,
      mean: true,
      justBlue: true,
      showInTypes: [2]
    },
    {
      name: "Tarifa",
      type: "hover-line sub-2",
      unit: "R$/kW",
      attr: "",
      var: true,
      mean: false,
      justBlue: true,
      showInTypes: [2]
    },
    {
      name: "Valor faturado",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "vdfp",
      var: true,
      mean: true,
      justBlue: true,
      showInTypes: [2]
    },
    {
      name: "Ultrapassagem",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "vudp",
      var: true,
      justBlue: true,
      showInTypes: [2]
    },
    {
      name: "Horário fora de ponta",
      type: "sub-1",
      unit: "",
      attr: "",
      var: false,
      mean: false,
      justBlue: true,
      showInTypes: [2]
    },
    {
      name: "Medido",
      type: "hover-line sub-2",
      unit: "kW",
      attr: "dmf",
      var: true,
      mean: true,
      showInTypes: [1, 2]
    },
    {
      name: "Contratado",
      type: "hover-line sub-2",
      unit: "kW",
      attr: "dcf",
      var: false,
      mean: false,
      showInTypes: [1, 2]
    },
    {
      name: "Faturado",
      type: "hover-line sub-2",
      unit: "kW",
      attr: "dff",
      var: true,
      mean: true,
      showInTypes: [1, 2]
    },
    {
      name: "Tarifa",
      type: "hover-line sub-2",
      unit: "R$/kW",
      attr: "",
      var: true,
      mean: false,
      showInTypes: [1, 2]
    },
    {
      name: "Valor faturado",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "vdff",
      var: true,
      mean: true,
      showInTypes: [1, 2]
    },
    {
      name: "Ultrapassagem",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "vudf",
      var: true,
      mean: true,
      showInTypes: [1, 2]
    },
    {
      name: "Energia reativa",
      type: "main",
      unit: "",
      attr: "",
      var: false,
      mean: false,
      showInTypes: [1, 2]
    },
    {
      name: "EREX P",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "verexp",
      var: true,
      mean: true,
      showInTypes: [1, 2]
    },
    {
      name: "EREX FP",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "verexf",
      var: true,
      mean: true,
      showInTypes: [1, 2]
    },
    {
      name: "Valor total",
      type: "hover-line sub-1",
      unit: "R$",
      attr: "",
      var: false,
      mean: false,
      showInTypes: [1, 2]
    },
    {
      name: "Tributos",
      type: "main",
      unit: "",
      attr: "",
      var: false,
      mean: false,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Base de cáculo",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "basec",
      var: true,
      mean: true,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Valor total",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "trib",
      var: true,
      mean: true,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Resumo dos valores",
      type: "main",
      unit: "",
      attr: "",
      var: false,
      mean: false,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Energia",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "",
      var: true,
      mean: false,
      showInTypes: [0, 1, 2]
    },
    {
      name: "CIP",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "cip",
      var: true,
      mean: true,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Descontos/Compensação",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "desc",
      var: true,
      mean: true,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Juros/Multas",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "jma",
      var: true,
      mean: true,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Total bruto",
      type: "hover-line main",
      unit: "R$",
      attr: "vbru",
      var: true,
      mean: true,
      showInTypes: [0, 1, 2]
    },
    {
      name: "Total líquido",
      type: "hover-line main",
      unit: "R$",
      attr: "vliq",
      var: true,
      mean: true,
      showInTypes: [0, 1, 2]
    }
  ],
  water: [
    {
      name: "Leitura atual",
      type: "main",
      unit: "",
      attr: "",
      var: false,
      mean: false,
    },
    {
      name: "Data",
      type: "hover-line sub-2",
      unit: "",
      attr: "dlat",
      var: false,
      mean: false,
    },
    {
      name: "Leitura",
      type: "hover-line sub-2",
      unit: "m³",
      attr: "lat",
      var: true,
      mean: true,
    },
    {
      name: "Leitura anterior",
      type: "main",
      unit: "",
      attr: "",
      var: false,
      mean: false,
    },
    {
      name: "Data",
      type: "hover-line sub-2",
      unit: "",
      attr: "dlan",
      var: false,
      mean: false,
    },
    {
      name: "Leitura",
      type: "hover-line sub-2",
      unit: "m³",
      attr: "lan",
      var: true,
      mean: true,
    },
    {
      name: "Consumo",
      type: "main",
      unit: "",
      attr: "",
      var: false,
      mean: false,
    },
    {
      name: "Médio",
      type: "hover-line sub-2",
      unit: "m³",
      attr: "consm",
      var: true,
      mean: true,
    },
    {
      name: "Faturado",
      type: "hover-line sub-2",
      unit: "m³",
      attr: "consf",
      var: true,
      mean: true,
    },
    {
      name: "Tributos",
      type: "main",
      unit: "",
      attr: "",
      var: false,
      mean: false,
    },
    {
      name: "COFINS",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "cofins",
      var: true,
      mean: true,
    },
    {
      name: "CSLL",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "csll",
      var: true,
      mean: true,
    },
    {
      name: "IRPJ",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "irpj",
      var: true,
      mean: true,
    },
    {
      name: "PASEP",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "pasep",
      var: true,
      mean: true,
    },
    {
      name: "Lançamentos",
      type: "main",
      unit: "",
      attr: "",
      var: false,
      mean: false,
    },
    {
      name: "Tarifa (água)",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "vagu",
      var: true,
      mean: true,
    },
    {
      name: "Tarifa (esgoto)",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "vesg",
      var: true,
      mean: true,
    },
    {
      name: "Adicional",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "adic",
      var: true,
      mean: true,
    },
    {
      name: "Subtotal na fatura",
      type: "hover-line sub-2",
      unit: "R$",
      attr: "subtotal",
      var: true,
      mean: true,
    }
  ]
};