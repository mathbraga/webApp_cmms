export default function buildChartData(queryResponse, month1, month2){
  // Número de medidores a serem analisados
  var numMeters = queryResponse.length;

  // Montar array com os aamm do período pesquisado
  var m1 = parseInt(month1, 10);
  var m2 = parseInt(month2, 10);
  var periodStrings = [];
  var periodInts = [];
  let m = m1;
  while(m <= m2){
    if(m2 - m <= 11){
      periodInts.push(m);
      periodStrings.push(m.toString());
      m = m + 1;
    } else {
      periodInts.push(m);
      periodStrings.push(m.toString());
      m = m + 89;
    }
  }

  // Número de meses deve vir dos parâmetros da pesquisa, não da queryResponse
  var numMonths = periodInts.length; // Corrigir. Usar lógica com initialDate e finalDate
   
  // Inicializa a variável
  var answers = {basec: [], cip: [], desc: [], dff: [], dfp: [], dmf: [], dmp: [], erexf: [], erexp: [], icms: [], jma: [], kwh: [], kwhf: [], kwhp: [], trib: [], vbru: [], vdff: [], vdfp: [], verexf: [], verexp: [], vliq: [], vudf: [], vudp: []};

  // Inicia loop
  for(let i = 0; i <= numMonths - 1; i++){
    answers.basec.push(0); answers.cip.push(0); answers.desc.push(0); answers.dff.push(0); answers.dfp.push(0); answers.dmf.push(0); answers.dmp.push(0); answers.erexf.push(0); answers.erexp.push(0); answers.icms.push(0); answers.jma.push(0); answers.kwh.push(0); answers.kwhf.push(0); answers.kwhp.push(0); answers.trib.push(0); answers.vbru.push(0); answers.vdff.push(0); answers.vdfp.push(0); answers.verexf.push(0); answers.verexp.push(0); answers.vliq.push(0); answers.vudf.push(0); answers.vudp.push(0);
    for(let j = 0; j <= numMeters - 1; j++){
      if(queryResponse[j].Items.length > 0){ // Se o medidor não retornou dados (queryResponseay vazio); não será analisado
        if(queryResponse[j].Items[i].aamm === periodInts[i]){ // Se o mês corresponde ao pesquisado, podemos somá-lo
          answers.basec[i] = answers.basec[i] + queryResponse[j].Items[i].basec;
          answers.cip[i]   = answers.cip[i] + queryResponse[j].Items[i].cip;
          answers.desc[i]  = answers.desc[i] + queryResponse[j].Items[i].desc;
          answers.dff[i]   = answers.dff[i] + queryResponse[j].Items[i].dff;
          answers.dfp[i]   = answers.dfp[i] + queryResponse[j].Items[i].dfp;
          answers.dmf[i]   = answers.dmf[i] + queryResponse[j].Items[i].dmf;
          answers.dmp[i]   = answers.dmp[i] + queryResponse[j].Items[i].dmp;
          answers.erexf[i] = answers.erexf[i] + queryResponse[j].Items[i].erexf;
          answers.erexp[i] = answers.erexp[i] + queryResponse[j].Items[i].erexp;
          answers.icms[i]  = answers.icms[i] + queryResponse[j].Items[i].icms;
          answers.jma[i]   = answers.jma[i] + queryResponse[j].Items[i].jma;
          answers.kwh[i]   = answers.kwh[i] + queryResponse[j].Items[i].kwh;
          answers.kwhf[i]  = answers.kwhf[i] + queryResponse[j].Items[i].kwhf;
          answers.kwhp[i]  = answers.kwhp[i] + queryResponse[j].Items[i].kwhp;
          answers.trib[i]  = answers.trib[i] + queryResponse[j].Items[i].trib;
          answers.vbru[i]  = answers.vbru[i] + queryResponse[j].Items[i].vbru;
          answers.vdff[i]  = answers.vdff[i] + queryResponse[j].Items[i].vdff;
          answers.vdfp[i]  = answers.vdfp[i] + queryResponse[j].Items[i].vdfp;
          answers.verexf[i] = answers.verexf[i] + queryResponse[j].Items[i].verexf;
          answers.verexp[i] = answers.verexp[i] + queryResponse[j].Items[i].verexp;
          answers.vliq[i]   = answers.vliq[i] + queryResponse[j].Items[i].vliq;
          answers.vudf[i]   = answers.vudf[i] + queryResponse[j].Items[i].vudf;
          answers.vudp[i]   = answers.vudp[i] + queryResponse[j].Items[i].vudp;
        }
      }
    }
  }

  console.log('answers:');
  console.log(answers);
  
  // Build object with params for chart.js
  var chartConfig = {
    type: 'line',
    data: {
      labels: periodStrings,
      datasets: [{
        label: '',
        backgroundColor: "rgb(0, 14, 38)",
        borderColor: "rgb(0, 14, 38)",
        data: answers.vbru
      }],
        fill: false,
    },
    options: {
      responsive: true,
      title: {
        display: true,
        text: 'TITLE TEXT'
      },
      tooltips: {
        mode: 'index',
        intersect: false,
      },
      hover: {
        mode: 'nearest',
        intersect: true
      },
      scales: {
        xAxes: [{
          display: true,
          scaleLabel: {
            display: true,
            labelString: 'Mês'
          }
        }],
        yAxes: [{
          display: true,
          scaleLabel: {
            display: true,
            labelString: 'Valor'
          }
        }]
      }
    }
  };

  return chartConfig;

}  