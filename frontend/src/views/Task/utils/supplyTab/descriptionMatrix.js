import React from 'react';
import { FormGroup, Label, Input } from 'reactstrap';

const formatter = new Intl.NumberFormat('pt-BR', {
  style: 'currency',
  currency: 'BRL',
});

export function itemsMatrixSupply(data) {
  
  const contracts = {};
  data.supplies.forEach((item) => {
    if (!(item.contractId in contracts)) {
      contracts[item.contractId] = {
        id: item.contractId,
        name: item.contractSf,
        company: item.company,
        cost: item.totalPrice
      }
    } else {
      contracts[item.contractId].cost += item.totalPrice
    }
  })
  
  console.log("Contracts 2: ", contracts);
  
  
  return (
    [
      [
        { 
          id: 'taskValue', title: 'Custo total da tarefa', 
          description: formatter.format(data.supplies.reduce((acc, item) => (item.totalPrice + acc), 0)), 
          span: 1 
        },
      ],
      [
        { id: 'taskValuePerStorage', 
          title: 'Custo por "estoque"', 
          description: 
          <ul style={{ paddingLeft: '20px', marginBottom: '0' }}>
            {Object.keys(contracts).map(contractId => (
               <li key={contractId}>{contracts[contractId].name} - {contracts[contractId].company}: <span style={{fontWeight: '600'}}>{formatter.format(contracts[contractId].cost)}</span></li>
            ))}
          </ul>, 
          span: 2 
        },
      ],
    ]
  );
}

export function itemsMatrixTableFilter(data, handleLogTypeChange) {
  const contracts = [...new Set(data.supplies.map(item => ({ id: item.contractId, name: item.contractSf, company: item.company })))];
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
                {contracts.map(contract => (
                  <option value={contract.id} key={contract.id}>{contract.name} - {contract.company}</option>
                ))}
              </Input>
            </FormGroup>
          ), 
          span: 1 
        }
      ],
    ]
  );
}