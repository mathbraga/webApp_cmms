export default function buildChartData(queryResponse, aamm1, aamm2) {
  // Number of meters to loop through queryResponse
  var numMeters = queryResponse.length;

  // Build arrays with all 'aamm' of period in query
  // periodStrings: array of 'aamm' strings
  // periodInts: array of 'aamm' integers
  // newPeriodStrings: array of strings in 'mmm/aa' format (mmm represent 3 letters designating the month)
  var m1 = parseInt(aamm1, 10);
  var m2 = parseInt(aamm2, 10);
  var periodStrings = [];
  var periodInts = [];
  var m = m1;
  while (m <= m2) {
    periodInts.push(m);
    periodStrings.push(m.toString());
    m = m + 1;
    if (parseInt(m.toString().slice(2), 10) === 13) {
      m = m + 88;
    }
  }

  var newPeriodStrings = periodStrings.map(month => {
    if (month.slice(2) === "01") {
      return "jan/" + month.slice(0, 2);
    } else if (month.slice(2) === "02") {
      return "fev/" + month.slice(0, 2);
    } else if (month.slice(2) === "03") {
      return "mar/" + month.slice(0, 2);
    } else if (month.slice(2) === "04") {
      return "abr/" + month.slice(0, 2);
    } else if (month.slice(2) === "05") {
      return "mai/" + month.slice(0, 2);
    } else if (month.slice(2) === "06") {
      return "jun/" + month.slice(0, 2);
    } else if (month.slice(2) === "07") {
      return "jul/" + month.slice(0, 2);
    } else if (month.slice(2) === "08") {
      return "ago/" + month.slice(0, 2);
    } else if (month.slice(2) === "09") {
      return "set/" + month.slice(0, 2);
    } else if (month.slice(2) === "10") {
      return "out/" + month.slice(0, 2);
    } else if (month.slice(2) === "11") {
      return "nov/" + month.slice(0, 2);
    } else if (month.slice(2) === "12") {
      return "dez/" + month.slice(0, 2);
    }
  });

  // Number of months in the query
  var numMonths = periodInts.length;

  // Initializes answers array, considering all attributes in EnergyTable
  var answers = {
    basec: [],
    cip: [],
    dcf: [],
    dcp: [],
    desc: [],
    dff: [],
    dfp: [],
    dmf: [],
    dmp: [],
    dms: [],
    uferf: [],
    uferp: [],
    icms: [],
    jma: [],
    kwh: [],
    kwhf: [],
    kwhp: [],
    tipo: [],
    trib: [],
    vbru: [],
    vdff: [],
    vdfp: [],
    verexf: [],
    verexp: [],
    vliq: [],
    vudf: [],
    vudp: []
  };

  // Loops through queryResponse to build answers array
  for (let i = 0; i <= numMonths - 1; i++) {
    answers.basec.push(0);
    answers.cip.push(0);
    answers.dcf.push(0);
    answers.dcp.push(0);
    answers.desc.push(0);
    answers.dff.push(0);
    answers.dfp.push(0);
    answers.dmf.push(0);
    answers.dmp.push(0);
    answers.dms.push(0);
    answers.uferf.push(0);
    answers.uferp.push(0);
    answers.icms.push(0);
    answers.jma.push(0);
    answers.kwh.push(0);
    answers.kwhf.push(0);
    answers.kwhp.push(0);
    answers.tipo.push(0);
    answers.trib.push(0);
    answers.vbru.push(0);
    answers.vdff.push(0);
    answers.vdfp.push(0);
    answers.verexf.push(0);
    answers.verexp.push(0);
    answers.vliq.push(0);
    answers.vudf.push(0);
    answers.vudp.push(0);
    for (let j = 0; j <= numMeters - 1; j++) {
      if (queryResponse[j].Items.length > 0) {
        // If current meter does not have data, will not be considered for sum
        for (let k = 0; k <= queryResponse[j].Items.length - 1; k++) {
          // Block access of inexisting months in a meter
          if (queryResponse[j].Items[k].aamm === periodInts[i]) {
            // Check if 'aamm' corresponds to current loop month. If true, the value is added
            answers.basec[i] =
              answers.basec[i] + queryResponse[j].Items[k].basec;
            answers.cip[i] = answers.cip[i] + queryResponse[j].Items[k].cip;
            answers.dcf[i] = answers.dcf[i] + queryResponse[j].Items[k].dcf;
            answers.dcp[i] = answers.dcp[i] + queryResponse[j].Items[k].dcp;
            answers.desc[i] = answers.desc[i] + queryResponse[j].Items[k].desc;
            answers.dff[i] = answers.dff[i] + queryResponse[j].Items[k].dff;
            answers.dfp[i] = answers.dfp[i] + queryResponse[j].Items[k].dfp;
            answers.dmf[i] = answers.dmf[i] + queryResponse[j].Items[k].dmf;
            answers.dmp[i] = answers.dmp[i] + queryResponse[j].Items[k].dmp;
            answers.dms[i] =
              answers.dms[i] +
              (queryResponse[j].Items[k].dmf > queryResponse[j].Items[k].dmp
                ? queryResponse[j].Items[k].dmf
                : queryResponse[j].Items[k].dmp);
            answers.uferf[i] =
              answers.uferf[i] + queryResponse[j].Items[k].uferf;
            answers.uferp[i] =
              answers.uferp[i] + queryResponse[j].Items[k].uferp;
            answers.icms[i] = answers.icms[i] + queryResponse[j].Items[k].icms;
            answers.jma[i] = answers.jma[i] + queryResponse[j].Items[k].jma;
            answers.kwh[i] = answers.kwh[i] + queryResponse[j].Items[k].kwh;
            answers.kwhf[i] = answers.kwhf[i] + queryResponse[j].Items[k].kwhf;
            answers.kwhp[i] = answers.kwhp[i] + queryResponse[j].Items[k].kwhp;
            answers.tipo[i] = answers.tipo[i] + queryResponse[j].Items[k].tipo;
            answers.trib[i] = answers.trib[i] + queryResponse[j].Items[k].trib;
            answers.vbru[i] = answers.vbru[i] + queryResponse[j].Items[k].vbru;
            answers.vdff[i] = answers.vdff[i] + queryResponse[j].Items[k].vdff;
            answers.vdfp[i] = answers.vdfp[i] + queryResponse[j].Items[k].vdfp;
            answers.verexf[i] =
              answers.verexf[i] + queryResponse[j].Items[k].verexf;
            answers.verexp[i] =
              answers.verexp[i] + queryResponse[j].Items[k].verexp;
            answers.vliq[i] = answers.vliq[i] + queryResponse[j].Items[k].vliq;
            answers.vudf[i] = answers.vudf[i] + queryResponse[j].Items[k].vudf;
            answers.vudp[i] = answers.vudp[i] + queryResponse[j].Items[k].vudp;
          }
        }
      }
    }
  }

  // Define helper object with strings to be used by chartConfigs
  var helper = {
    datasetLabel: {
      vbru: "Valor bruto",
      vliq: "Valor líquido",
      basec: "Base de cálculo",
      jma: "Juros, multas e atualizações monetárias",
      dcf: "Demanda contratada - Fora de ponta",
      dcp: "Demanda contratada - Ponta",
      tipo: "Tipo",
      desc: "Compensações e/ou descontos",
      trib: "Tributos federais",
      icms: "ICMS",
      cip: "Contribuição de iluminação pública - CIP",
      kwh: "Consumo total",
      kwhf: "Consumo - Fora de ponta",
      kwhp: "Consumo - Ponta",
      uferf: "UFER - Fora de ponta",
      uferp: "UFER - Ponta",
      verexf: "Valor EREX - Fora de ponta",
      verexp: "Valor EREX - Ponta",
      dmf: "Demanda medida - Fora de ponta",
      dmp: "Demanda medida - Ponta",
      dms: "Demanda medida - Diária", // Somatório das maiores demandas do dia
      dff: "Demanda faturada - Fora de ponta",
      dfp: "Demanda faturada - Ponta",
      vdff: "Valor da demanda faturada - Fora de ponta",
      vdfp: "Valor da demanda faturada - Ponta",
      vudf: "Valor da ultrapassagem de demanda - Fora de ponta",
      vudp: "Valor da ultrapassagem de demanda - Ponta"
    },
    title: {
      vbru: "Valor bruto",
      vliq: "Valor líquido",
      basec: "Base de cálculo",
      jma: "Juros, multas e atualizações monetárias",
      dcf: "Demanda contratada - Fora de ponta",
      dcp: "Demanda contratada - Ponta",
      tipo: "Tipo",
      desc: "Compensações e/ou descontos",
      trib: "Tributos federais",
      icms: "ICMS",
      cip: "Contribuição de iluminação pública - CIP",
      kwh: "Consumo total",
      kwhf: "Consumo - Fora de ponta",
      kwhp: "Consumo - Ponta",
      uferf: "UFER - Fora de ponta",
      uferp: "UFER - Ponta",
      verexf: "Valor EREX - Fora de ponta",
      verexp: "Valor EREX - Ponta",
      dmf: "Demanda medida - Fora de ponta",
      dmp: "Demanda medida - Ponta",
      dms: "Demanda medida - Diária",
      dff: "Demanda faturada - Fora de ponta",
      dfp: "Demanda faturada - Ponta",
      vdff: "Valor da demanda faturada - Fora de ponta",
      vdfp: "Valor da demanda faturada - Ponta",
      vudf: "Valor da ultrapassagem de demanda - Fora de ponta",
      vudp: "Valor da ultrapassagem de demanda - Ponta"
    },
    yLabel: {
      vbru: "R$",
      vliq: "R$",
      basec: "R$",
      jma: "R$",
      dcf: "kW",
      dcp: "kW",
      tipo: "Tipo",
      desc: "R$",
      trib: "R$",
      icms: "R$",
      cip: "R$",
      kwh: "kWh",
      kwhf: "kWh",
      kwhp: "kWh",
      uferf: "UFER - Fora de ponta",
      uferp: "UFER - Ponta",
      verexf: "R$",
      verexp: "R$",
      dmf: "kW",
      dmp: "kW",
      dms: "kW",
      dff: "kW",
      dfp: "kW",
      vdff: "R$",
      vdfp: "R$",
      vudf: "R$",
      vudp: "R$"
    }
  };

  // Build chartConfig as an object of objects
  var chartConfigs = {};
  Object.keys(answers).map(key => {
    chartConfigs[key] = {
      type: "line",
      data: {
        labels: newPeriodStrings,
        datasets: [
          {
            label: helper.datasetLabel[key],
            backgroundColor: "rgb(0, 0, 0)",
            borderColor: "rgb(0, 0, 0)",
            data: answers[key],
            fill: false
          }
        ]
      },
      options: {
        legend: false,
        responsive: true,
        title: {
          display: true,
          text: helper.title[key]
        },
        tooltips: {
          mode: "index",
          intersect: false
        },
        hover: {
          mode: "nearest",
          intersect: true
        },
        scales: {
          xAxes: [
            {
              display: true,
              scaleLabel: {
                display: true,
                labelString: "Mês"
              }
            }
          ],
          yAxes: [
            {
              display: true,
              scaleLabel: {
                display: true,
                labelString: helper.yLabel[key]
              }
            }
          ]
        }
      }
    };
  });

  // Return chartConfigs object
  return chartConfigs;
}
