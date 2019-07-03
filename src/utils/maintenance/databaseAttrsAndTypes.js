export const dbAttrs = {
  
  // Work order attributes
  creationDate: "S",
  impact: "BOOL",
  reqName: "S",
  selectedService: "S",
  status: "S",

  // Asset attributes
  areaconst: "N",
  lat: "N",
  lon: "N",
  modelo: "S",
  nome: "S",
  pai: "S",
  serial: "S",
  subnome: "S",
  visita: "BOOL",

  // WO x ASSET
  woId: "N",
  assetId: "S",

};

export const dbTypes = ["N", "S", "BOOL"];