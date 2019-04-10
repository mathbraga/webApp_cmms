export default function defineNewLocation(
  oneMonth,
  chosenMeter,
  initialDate,
  finalDate
) {
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
