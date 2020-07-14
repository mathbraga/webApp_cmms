export function itemsMatrixAssets(data) {
  return (
    [
      [
        { id: 'numAssets', title: 'Número de ativos', description: data && data.length, span: 1 },
      ],
    ]
  );
}
