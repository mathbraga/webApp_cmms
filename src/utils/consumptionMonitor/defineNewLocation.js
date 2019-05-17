export default function defineNewLocation(oneMonth, chosenMeter, initialDate, finalDate, meterType) {
  // Inputs:
  // oneMonth (boolean): input from FormDates
  // chosenMeter (string): input from FormDates
  // initialDate (string): input from FormDates
  // finalDate (string): input from FormDates
  //
  // Output:
  // Location (object): must contain pathname attribute
  //
  // Purpose:
  // Define location objectm to automate show (render) and hide (not render) components after search.
  // Location object is usable by react-router components (Route, Redirect etc.)
  
  if(meterType === "1"){
    if ((oneMonth || initialDate === finalDate) && chosenMeter !== "199") {
      return {
        hash: "",
        pathname: "/consumo/energia/resultados/OM",
        search: "",
        state: {}
      };
    }
    if (!oneMonth && chosenMeter !== "199") {
      return {
        hash: "",
        pathname: "/consumo/energia/resultados/OP",
        search: "",
        state: {}
      };
    }
    if ((oneMonth || initialDate === finalDate) && chosenMeter === "199") {
      return {
        hash: "",
        pathname: "/consumo/energia/resultados/AM",
        search: "",
        state: {}
      };
    }
    if (!oneMonth && chosenMeter === "199") {
      return {
        hash: "",
        pathname: "/consumo/energia/resultados/AP",
        search: "",
        state: {}
      };
    }
  }
  if(meterType === "2"){
    if ((oneMonth || initialDate === finalDate) && chosenMeter !== "299") {
      return {
        hash: "",
        pathname: "/consumo/agua/resultados/OM",
        search: "",
        state: {}
      };
    }
    if (!oneMonth && chosenMeter !== "299") {
      return {
        hash: "",
        pathname: "/consumo/agua/resultados/OP",
        search: "",
        state: {}
      };
    }
    if ((oneMonth || initialDate === finalDate) && chosenMeter === "299") {
      return {
        hash: "",
        pathname: "/consumo/agua/resultados/AM",
        search: "",
        state: {}
      };
    }
    if (!oneMonth && chosenMeter === "299") {
      return {
        hash: "",
        pathname: "/consumo/agua/resultados/AP",
        search: "",
        state: {}
      };
    }
  }
}
