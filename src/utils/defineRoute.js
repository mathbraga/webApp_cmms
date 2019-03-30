export default function defineRoute(oneMonth, chosenMeter){
  if(oneMonth && chosenMeter !== "199"){
    return {
      hash: "",
      pathname: "/consumo/energia/resultados/OM",
      search: "",
      state: {}
    };
  }
  if(!oneMonth && chosenMeter !== "199"){
    return {
      hash: "",
      pathname: "/consumo/energia/resultados/OP",
      search: "",
      state: {}
    };
  }
  if(oneMonth && chosenMeter === "199"){
    return {
      hash: "",
      pathname: "/consumo/energia/resultados/AM",
      search: "",
      state: {}
    };
  }
  if(!oneMonth && chosenMeter === "199"){
    return {
      hash: "",
      pathname: "/consumo/energia/resultados/AP",
      search: "",
      state: {}
    };
  }
}