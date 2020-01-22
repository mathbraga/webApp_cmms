export function itemsMatrixGeneral(data) {
  return (
    [
      [
        { id: 'title', title: 'Objeto', description: data.contractByContractSf.title, span: 1 },
        { id: 'manager', title: 'Fiscal', description: data.contractByContractSf.manager, span: 1 },
      ],
      [
        { id: 'contractSf', title: 'Contrato nº', description: data.contractByContractSf.contractSf, span: 1 },
        { id: 'company', title: 'Empresa', description: data.contractByContractSf.company, span: 1 },
      ],
      [
        { id: 'description', title: 'Descrição', description: data.contractByContractSf.description, span: 2 }
      ],
    ]
  );
}

export function itemsMatrixDate(data) {
  return (
    [
      [
        { id: 'dateStart', title: 'Início da Vigência', description: data.contractByContractSf.dateStart, span: 1 },
        { id: 'dateSign', title: 'Data da Assinatura', description: data.contractByContractSf.dateSign, span: 1 },
      ],
      [
        { id: 'dateEnd', title: 'Final da Vigência', description: data.contractByContractSf.dateEnd, span: 1 },
        { id: 'datePub', title: 'Data da Publicação', description: data.contractByContractSf.datePub, span: 1 },
      ],
    ]
  );
}

export function itemsMatrixDocs(data) {
  return (
    [
      [
        { id: 'url', title: 'Link para Contrato', description: data.contractByContractSf.url, span: 1 },
      ],
    ]
  );
}

export function itemsMatrixMaterial(data) {
  return (
    [
      [
        { id: 'material', title: 'Materiais', description: "R$ 10.000,00", span: 1 },
        { id: 'service', title: 'Serviços', description: "R$ 10.000,00", span: 1 },
      ],
      [
        { id: 'material', title: 'Materiais', description: "R$ 10.000,00", span: 1 },
        { id: 'service', title: 'Serviços', description: "R$ 10.000,00", span: 1 },
      ],
    ]
  );
}