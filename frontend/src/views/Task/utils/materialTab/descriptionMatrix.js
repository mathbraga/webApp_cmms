import React, { Component } from 'react';

export function itemsMatrixSupply() {
  return (
    [
      [
        { id: 'taskValue', title: 'Custo total da tarefa', description: 'R$ 1.341,00', span: 1 },
      ],
      [
        { id: 'taskValuePerStorage', title: 'Custo por "estoque"', description: 
          <ul style={{ paddingLeft: '20px', marginBottom: '0' }}>
            <li>Contrato n. 12/2020 - RCS:  <span style={{fontWeight: '600'}}>R$ 700,00</span></li>
            <li>Nota Fiscal n. 8918/2020:  <span style={{fontWeight: '600'}}>R$ 641,00</span></li>
          </ul>
        , span: 2 },
      ],
    ]
  );
}