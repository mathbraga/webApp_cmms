import React, { Component } from 'react';
import { FormGroup, CustomInput, Label, Input } from 'reactstrap';

export function itemsMatrixAssets(data) {
  return (
    [
      [
        { id: 'parents', title: 'Total de Ativos Pais', description: '003', span: 1 },
        { id: 'children', title: 'Total de Ativos Filhos', description: '020', span: 1 },
      ],
    ]
  );
}

export function itemsMatrixAssetsConfig(data) {
  return (
    [
      [
        { id: 'children', elementGenerator: () => (
          <FormGroup style={{width: "80%"}}>
            <Label className='desc-sub' for="exampleSelect" style={{ margin: "10px 0 4px 0 " }}>Hierarquia dos Ativos</Label>
            <Input type="select" name="select" id="exampleSelect">
              <option>Ativos Descendentes (Filhos)</option>
              <option>Ativos Ascendentes (Pais)</option>
              <option>Todos os Ativos</option>
            </Input>
          </FormGroup>
        ), span: 1 },
        { id: 'children', elementGenerator: () => (
          <FormGroup style={{width: "80%"}}>
            <Label className='desc-sub' for="exampleSelect" style={{ margin: "10px 0 4px 0 " }}>Contexto</Label>
            <Input type="select" name="select" id="exampleSelect">
              <option>Endereçamento do CASF</option>
              <option>Sistema Elétrico</option>
              <option>Sistema Hidráulico</option>
              <option>Sistema Civil</option>
              <option>Sistema Mecânico</option>
            </Input>
          </FormGroup>
        ), span: 1 },
      ],
    ]
  );
}