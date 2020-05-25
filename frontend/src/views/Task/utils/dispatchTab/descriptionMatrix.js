import React from 'react';
import { FormGroup, Label, Input } from 'reactstrap';

export function itemsMatrixAssetsHierachy(data) {
  return (
    [
      [
        { id: 'parentsAssets', title: 'Status', description: 'Fila de Espera', span: 1 },
        { id: 'childrenAssets', title: 'Data de recebimento', description: '10/10/2020', span: 1 },
      ],
      [
        { id: 'team', title: 'Equipe', description: 'Semac', span: 1 },
        { id: 'totalDays', title: 'Dias com a tarefa', description: '020 dias', span: 1 }
      ],
      [
        { id: 'obs', title: 'Última observação (tramitação)', description: 'Reparar os móveis localizados dentro da sala do SEMAC/SEPLAG. O serviço deverá ser realizado fora do horário de expediente. Qualquer dúvida, falar com o Pedro (Ramal: 2339)', span: 2 },
      ],
    ]
  );
}

export function itemsMatrixLog(numEvent) {
  return (
    [
      [
        { 
          id: 'logData', 
          elementGenerator: () => (
            <FormGroup style={{width: "80%"}}>
              <Label className='desc-sub' for="exampleSelect" style={{ margin: "10px 0 2px 0 " }}>Exibir histórico de</Label>
              <Input type="select" name="select" id="exampleSelect">
                <option>Tramitações e Status</option>
                <option>Tramitações</option>
                <option>Status</option>
              </Input>
            </FormGroup>
          ), 
          span: 1 
        },
        { id: 'totalEvents', title: 'Número de eventos', description: numEvent, span: 1 }
      ],
    ]
  );
}
