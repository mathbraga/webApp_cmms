export const fakeWorkOrders = {
  items: [
    {
      requestData: {
        id: "12345",
        creationDate: "25/06/2019",
        selectedService: "Troca de lâmpada",
        lastUpdate: "26/06/2019",
        requestCreator: {
          name: "Henrique Zaidan Lopes",
          email: "hzlopes@senado.leg.br",
          phone: "(61)33032339"
        },
        requestContact: {
          name: "Henrique Zaidan Lopes",
          email: "hzlopes@senado.leg.br",
          phone: "(61)33032339"
        },
        local: "BL14-MEZ-039",
        description: "Favor trocar a lâmpada da sala.",
        details: "Lâmpada queimou ontem.",
        files: "Nenhum"
      },
      situation:
      priority:
      assignedTo:
      category:
      sigad:
      requestingDepartment:
      messageToRequester:
      budget:
      initialDate:
      finalDate:
      progress:
      checked:
      localOfficial:
      executor:
      ans:
      status:
      multiTask:
      relatedWorkOrders:
      subTasks:
      log:
    },
  ],
  tableConfig: [
    { name: "ID", style: { width: "20%" }, className: "", key: "id" },
    { name: "Serviço", style: { width: "20%" }, className: "text-center", key: "selectedService" },
    { name: "Local", style: { width: "20%" }, className: "text-center", key: "local" },
    { name: "Data de criação", style: { width: "20%" }, className: "text-center", key: "creationDate" },
    { name: "Última atualização", style: { width: "20%" }, className: "text-center", key: "lastUpdate" },
  ]
};