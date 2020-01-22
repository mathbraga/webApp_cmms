import { ORDER_CATEGORY_TYPE, ORDER_STATUS_TYPE, ORDER_PRIORITY_TYPE } from '../../Tasks/utils/dataDescription';

export function itemsMatrixGeneral(data) {
  return (
    [
      [
        { id: 'title', title: 'Título do Serviço', description: data.orderByOrderId.title, span: 1 },
        { id: 'status', title: 'Status', description: ORDER_STATUS_TYPE[data.orderByOrderId.status], span: 1 },
      ],
      [
        { id: 'orderId', title: 'Ordem de Serviço nº', description: data.orderByOrderId.orderId.toString().padStart(4, "0"), span: 1 },
        { id: 'progress', title: 'Executado (%)', description: data.orderByOrderId.progress, span: 1 },
      ],
      [
        { id: 'category', title: 'Categoria', description: ORDER_CATEGORY_TYPE[data.orderByOrderId.category], span: 1 },
        { id: 'priority', title: 'Prioridade', description: ORDER_PRIORITY_TYPE[data.orderByOrderId.priority], span: 1 },
      ],
      [{ id: 'place', title: 'Local', description: data.orderByOrderId.place, span: 1 }],
      [{ id: 'description', title: 'Descrição Técnica', description: data.orderByOrderId.description, span: 2 }],
    ]
  );
}

export function itemsMatrixDate(data) {
  return (
    [
      [
        { id: 'createdAt', title: 'Criação da OS', description: data.orderByOrderId.createdAt, span: 1 },
        { id: 'dateLimit', title: 'Prazo Final', description: data.orderByOrderId.dateLimit, span: 1 },
      ],
      [
        { id: 'dateStart', title: 'Início da Execução', description: data.orderByOrderId.dateStart, span: 1 },
        { id: 'delay', title: 'Dias de Atraso', description: data.orderByOrderId.dateLimit, span: 1 },
      ],
      [{ id: 'dateEnd', title: 'Término da Execução', description: data.orderByOrderId.dateEnd, span: 1 }],
    ]
  );
}

export function itemsMatrixMaterial(data) {
  return (
    [
      [{ id: 'quantity', title: 'Quantidade', description: data.length.toString().padStart(3, "0"), span: 1 }],
    ]
  );
}