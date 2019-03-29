export default function defineRoute(oneMonth, chosenMeter){
  if(oneMonth && chosenMeter !== "199"){
    return "/consumo/energia/resultados/OM";
  }
  if(!oneMonth && chosenMeter !== "199"){
    return "/consumo/energia/resultados/OP";
  }
  if(oneMonth && chosenMeter === "199"){
    return "/consumo/energia/resultados/AM";
  }
  if(!oneMonth && chosenMeter === "199"){
    return "/consumo/energia/resultados/AP";
  }
}