import React from 'react';
import { FormGroup, Label, Input } from 'reactstrap';

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

export function itemsMatrixTableFilter(handleLogTypeChange) {
  return (
    [
      [
        { 
          id: 'logData', 
          elementGenerator: () => (
            <FormGroup style={{width: "80%"}}>
              <Label className='desc-sub' for="exampleSelect" style={{ margin: "10px 0 2px 0 " }}>Filtrar por</Label>
              <Input type="select" name="select" id="exampleSelect" onChange={handleLogTypeChange}>
                <option value='all'>Sem filtro</option>
                <option value='assign'>CT 020/2020 - RCS</option>
                <option value='status'>CT 020/2021 - RCS</option>
                <option value='status'>NF 0205/2020 - RCS</option>
              </Input>
            </FormGroup>
          ), 
          span: 1 
        }
      ],
    ]
  );
}