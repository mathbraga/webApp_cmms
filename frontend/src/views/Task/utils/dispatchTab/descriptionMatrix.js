import React from 'react';
import { FormGroup, Label, Input } from 'reactstrap';

export function itemsMatrixAssetsHierachy(data) {
  return (
    [
      [
        { id: 'parentsAssets', title: 'Total de Ativos Pais', description: '003', span: 1 },
        { id: 'childrenAssets', title: 'Total de Ativos Filhos', description: '020', span: 1 },
      ],
    ]
  );
}
