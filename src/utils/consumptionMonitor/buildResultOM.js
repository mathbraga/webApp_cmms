import { transformDateString } from "./transformDateString";
import formatNumber from "./formatText";

export default function buildResultOM(meterType, meters, chosenMeter, queryResponse){
  
  let resultObject = {};
  
  meters.forEach(meter => {
    if((parseInt(meter.med.N) + 100*parseInt(meter.tipomed.N)) === parseInt(chosenMeter)){
      resultObject.unit = meter;
    }
  });

  resultObject.queryResponse = queryResponse[0].Items[0];

  resultObject.dateString = transformDateString(resultObject.queryResponse.aamm);

  resultObject.image1 = "/money_energy.png";

  resultObject.image2 = "/plug_energy.png";

  resultObject.image3 = "/alert_icon.png";

  resultObject.threeColumnValues = {
    0: {
      titles: [
        "Total",
        "CIP",
        "Tributos",
        "ICMS",
        "Multas/Juros",
        "Compensação"
      ],
      values: [
        "R$ " + formatNumber(resultObject.queryResponse.vbru, 2),
        "R$ " + formatNumber(resultObject.queryResponse.cip, 2),
        "R$ " + formatNumber(resultObject.queryResponse.trib, 2),
        "R$ " + formatNumber(resultObject.queryResponse.icms, 2),
        "R$ " + formatNumber(resultObject.queryResponse.jma, 2),
        "R$ " + formatNumber(resultObject.queryResponse.desc, 2)
      ]
    },
    1: {
      titles: [
        "Demanda FP",
        "Demanda P",
        "Contrato FP",
        "Contrato P",
        "Faturado FP",
        "Faturado P"
      ],
      values: [
        formatNumber(resultObject.queryResponse.dmf, 0) + " kW",
        formatNumber(resultObject.queryResponse.dmp, 0) + " kW",
        formatNumber(resultObject.queryResponse.dcf, 0) + " kW",
        formatNumber(resultObject.queryResponse.dcp, 0) + " kW",
        formatNumber(resultObject.queryResponse.dff, 0) + " kW",
        formatNumber(resultObject.queryResponse.dfp, 0) + " kW"
      ]
    },
    2: {
      titles: [
        "Demanda FP",
        "Demanda P",
        "Contrato FP",
        "Contrato P",
        "Faturado FP",
        "Faturado P"
      ],
      values: [
        formatNumber(resultObject.queryResponse.dmf, 0) + " kW",
        formatNumber(resultObject.queryResponse.dmp, 0) + " kW",
        formatNumber(resultObject.queryResponse.dcf, 0) + " kW",
        formatNumber(resultObject.queryResponse.dcp, 0) + " kW",
        formatNumber(resultObject.queryResponse.dff, 0) + " kW",
        formatNumber(resultObject.queryResponse.dfp, 0) + " kW"
      ]
    }
  };

  resultObject.typeText = {
    0: "Convencional",
    1: "Horária - Verde",
    2: "Horária - Azul"
  };

  resultObject.rowNamesInfo = [
    { name: "Identificação CEB", attr: "id" },
    { name: "Nome do medidor", attr: "nome" },
    { name: "Contrato", attr: "ct" },
    { name: "Classe", attr: "classe" },
    { name: "Subclasse", attr: "subclasse" },
    { name: "Grupo", attr: "grupo" },
    { name: "Subgrupo", attr: "subgrupo" },
    { name: "Ligação", attr: "lig" },
    { name: "Modalidade tarifária", attr: "modtar" },
    { name: "Locais", attr: "locais" },
    { name: "Demanda contratada (FP/P)", attr: "dem" },
    { name: "Observações", attr: "obs" }
  ];

  resultObject.rowNamesBill = [
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
  ];

  return resultObject;
}