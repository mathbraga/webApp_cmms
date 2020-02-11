export const tableConfig = {
  numberOfColumns: 6,
  checkbox: true,
  checkboxWidth: "5%",
  itemPath: '/manutencao/os/view/',
  itemClickable: true,
  idAttributeForData: 'taskId',
  columns: [
    { name: 'taskId', description: 'OS', width: "10%", align: "center", data: ['taskId'] },
    { name: 'title', description: 'Título', width: "40%", align: "justify", wrapText: true, data: ['title', 'category'] },
    { name: 'status', description: 'Status', width: "15%", align: "center", data: ['status'] },
    { name: 'dateLimit', description: 'Prazo Final', width: "15%", align: "center", data: ['dateLimit'] },
    { name: 'place', description: 'Localização', width: "15%", align: "center", data: ['place'] },
  ],
};

export const selectedData = {
  "005": true,
  "008": true,
  "009": true,
  "010": true,
}

export const data = [
  { taskId: "001", category: "Reparo em Forro", title: "Troca de vidros quebradosTroca de vidros quebradosTroca de vidros quebradosTroca de vidros quebradosTroca de vidros quebradosTroca de vidros quebradosTroca de vidros quebradosTroca de vidros quebrados", status: "Cancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "002", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "Cancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "003", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "BCancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "004", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "Cancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "005", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "DCancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "006", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "Cancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "007", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "FCancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "008", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "GCancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "009", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "HCancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "010", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "Cancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "011", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "ICancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "012", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "ACancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "013", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "Cancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "014", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "Cancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "015", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "ACancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "016", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "ECancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "017", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "ECancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "018", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "BCancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "019", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "Cancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "020", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "Cancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "021", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "CCCancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "022", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "DCancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "023", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "ECancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
  { taskId: "024", category: "Reparo em Forro", title: "Troca de vidros quebrados", status: "Cancelada", dateLimit: "12-10-2020", place: "Sala do SEMAC" },
];