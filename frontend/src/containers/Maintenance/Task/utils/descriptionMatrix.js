import React, { Component } from 'react';
import { FormGroup, CustomInput } from 'reactstrap';
import { ORDER_CATEGORY_TYPE, ORDER_STATUS_TYPE, ORDER_PRIORITY_TYPE } from '../../Tasks/utils/dataDescription';

export function itemsMatrixGeneral(data) {
  return (
    [
      [
        { id: 'appliance', title: 'Título do Serviço', description: data.orderByOrderId.title, span: 1 },
        { id: 'serial', title: 'Status', description: ORDER_STATUS_TYPE[data.orderByOrderId.status], span: 1 },
      ],
      [
        { id: 'id', title: 'Ordem de Serviço nº', description: data.orderByOrderId.orderId.toString().padStart(4, "0"), span: 1 },
        { id: 'price', title: 'Executado (%)', description: data.orderByOrderId.progress, span: 1 },
      ],
      [
        { id: 'appliance', title: 'Categoria', description: ORDER_CATEGORY_TYPE[data.orderByOrderId.category], span: 1 },
        { id: 'serial', title: 'Prioridade', description: ORDER_PRIORITY_TYPE[data.orderByOrderId.priority], span: 1 },
      ],
      [{ id: 'model', title: 'Local', description: data.orderByOrderId.place, span: 1 }],
      [{ id: 'model', title: 'Descrição Técnica', description: data.orderByOrderId.description, span: 2 }],
    ]
  );
}

export function itemsMatrixDate(data) {
  return (
    [
      [
        { id: 'manufacturer', title: 'Criação da OS', description: data.orderByOrderId.createdAt, span: 1 },
        { id: 'phone', title: 'Prazo Final', description: data.orderByOrderId.dateLimit, span: 1 },
      ],
      [
        { id: 'city', title: 'Início da Execução', description: data.orderByOrderId.dateStart, span: 1 },
        { id: 'email', title: 'Dias de Atraso', description: data.orderByOrderId.dateLimit, span: 1 },
      ],
      [{ id: 'model', title: 'Término da Execução', description: data.orderByOrderId.dateEnd, span: 1 }],
    ]
  );
}