export const fakeWorkOrders = {
  items: [
    {
      id: "12345",
      requestData: {
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
        local: "Mezanino SINFRA, sala do SEPLAG",
        description: "Favor trocar a lâmpada da sala.",
        details: "Lâmpada queimou ontem.",
        files: "Nenhum"
      },
      situation: "Pendente",
      priority: "Normal",
      assignedTo: "RCS Tecnologia",
      category: "Elétrica",
      sigad: "N/A",
      requestingDepartment: "SEPLAG",
      messageToRequester: "",
      budget: "",
      initialDate: "25/06/2019",
      finalDate: "30/06/2019",
      progress: "0 %",
      checked: "",
      localOfficial: "BL14-MEZ-043",
      executor: "Nikola Tesla",
      ans: "",
      status: "Pendente",
      multiTask: "",
      relatedWorkOrders: "",
      subTasks: "",
      log: "Atualizado por Henrique Zaidan.",
      asset: "BL14-MEZ-043"
    },
  ],
  tableConfig: [
    { name: "ID", style: { width: "20%" }, className: "text-center", key: "id" },
    { name: "Status", style: { width: "20%" }, className: "text-center", key: "status" },
    { name: "Ativo", style: { width: "20%" }, className: "text-center", key: "asset" },
    { name: "Local", style: { width: "20%" }, className: "text-center", key: "localOfficial" },
  ]
};