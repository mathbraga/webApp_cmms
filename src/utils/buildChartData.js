export default function buildChartData(arr){
  // Número de medidores a serem analisados
  var numMeters = arr.length;

  // Número de meses deve vir dos parâmetros da pesquisa, não da queryResponse
  var numMonths = arr[0].Items.length; // Corrigir. Usar lógica com initialDate e finalDate
  
  // Montar array com os aamm do período pesquisado
  var period = [1801, 1802, 1803, 1804, 1805, 1806, 1807, 1808, 1809, 1810, 1811, 1812];
  // CORRIGIR LINHA ACIMA. USAR LÓGICA PARA MONTAR ESTE ARRAY.
   
  // Inicializa a variável
  var answer = [];

  // Inicia loop
  for(let i = 0; i <= numMonths - 1; i++){
    answer.push({basec: 0, cip: 0, desc: 0, dff: 0, dfp: 0, dmf: 0, dmp: 0, erexf: 0, erexp: 0, icms: 0, jma: 0, kwh: 0, kwhf: 0, kwhp: 0, trib: 0, vbru: 0, vdff: 0, vdfp: 0, verexf: 0, verexp: 0, vliq: 0, vudf: 0, vudp: 0}); // Objeto que irá receber a soma do mês atual do loop
    for(let j = 0; j < numMeters - 1; j++){
      if(arr[j].Items.length > 0){ // Se o medidor não retornou dados (array vazio), não será analisado
        if(arr[j].Items[i].aamm === period[i]){ // Se o mês corresponde ao pesquisado, podemos somá-lo
          answer[i].basec = answer[i].basec + arr[j].Items[i].basec;
          answer[i].cip = answer[i].cip + arr[j].Items[i].cip;
          answer[i].desc = answer[i].desc + arr[j].Items[i].desc;
          answer[i].dff = answer[i].dff + arr[j].Items[i].dff;
          answer[i].dfp = answer[i].dfp + arr[j].Items[i].dfp;
          answer[i].dmf = answer[i].dmf + arr[j].Items[i].dmf;
          answer[i].dmp = answer[i].dmp + arr[j].Items[i].dmp;
          answer[i].erexf = answer[i].erexf + arr[j].Items[i].erexf;
          answer[i].erexp = answer[i].erexp + arr[j].Items[i].erexp;
          answer[i].icms = answer[i].icms + arr[j].Items[i].icms;
          answer[i].jma = answer[i].jma + arr[j].Items[i].jma;
          answer[i].kwh = answer[i].kwh + arr[j].Items[i].kwh;
          answer[i].kwhf = answer[i].kwhf + arr[j].Items[i].kwhf;
          answer[i].kwhp = answer[i].kwhp + arr[j].Items[i].kwhp;
          answer[i].trib = answer[i].trib + arr[j].Items[i].trib;
          answer[i].vbru = answer[i].vbru + arr[j].Items[i].vbru;
          answer[i].vdff = answer[i].vdff + arr[j].Items[i].vdff;
          answer[i].vdfp = answer[i].vdfp + arr[j].Items[i].vdfp;
          answer[i].verexf = answer[i].verexf + arr[j].Items[i].verexf;
          answer[i].verexp = answer[i].verexp + arr[j].Items[i].verexp;
          answer[i].vliq = answer[i].vliq + arr[j].Items[i].vliq;
          answer[i].vudf = answer[i].vudf + arr[j].Items[i].vudf;
          answer[i].vudp = answer[i].vudp + arr[j].Items[i].vudp;
        }
      }
    }
  }
  console.log(answer);
  

  // Build object with params for chart.js








}  