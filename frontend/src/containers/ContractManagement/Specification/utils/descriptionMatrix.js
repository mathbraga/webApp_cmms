

export function itemsMatrixGeneral(data) {
  return (
    [
      [
        { id: 'name', title: 'Serviço / Material', description: data.specBySpecId.name, span: 1 },
        { id: 'specSf', title: 'Código', description: data.specBySpecId.specSf, span: 1 },
      ],
      [
        { id: 'category', title: 'Categoria', description: data.specBySpecId.category, span: 1 },
        { id: 'version', title: 'Versão', description: data.specBySpecId.version, span: 1 },
      ],
      [
        { id: 'subcategory', title: 'Subcategoria', description: data.specBySpecId.subcategory, span: 1 },
        { id: 'catmat', title: 'Catmat / Catser', description: `${data.specBySpecId.catmat || "-"} / ${data.specBySpecId.catser || "-"}`, span: 1 },
      ],
      [{ id: 'description', title: 'Descrição Detalhada', description: data.specBySpecId.description, span: 2 }],
    ]
  );
}

export function itemsMatrixBalance(array) {
  return (
    [
      [{
        id: 'balance',
        title: 'Total Disponível',
        description: array.reduce((acc, item) => (Number(item.available) + Number(acc)), 0),
        span: 1
      }],
    ]
  );
}

export function itemsMatrixTasks(array) {
  return (
    [
      [{
        id: 'tasks',
        title: 'Quantidade de OS',
        description: array.length.toString().padStart(3, "0"),
        span: 1
      }],
    ]
  );
}