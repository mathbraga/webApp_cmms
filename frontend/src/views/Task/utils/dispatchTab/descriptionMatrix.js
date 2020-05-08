import React from 'react';
import { FormGroup, Label, Input } from 'reactstrap';

export function itemsMatrixAssetsHierachy(data) {
  return (
    [
      [
        { id: 'parentsAssets', title: 'Equipe', description: 'Semac', span: 1 },
        { id: 'childrenAssets', title: 'Data de recebimento', description: '10/10/2020', span: 1 },
      ],
      [
        { id: 'parentsAssets', title: 'Dias com a tarefa', description: '020 dias', span: 1 }
      ],
    ]
  );
}
