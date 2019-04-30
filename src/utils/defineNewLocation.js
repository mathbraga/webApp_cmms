export default function defineNewLocation(oneMonth, chosenMeter, initialDate, finalDate) {
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
