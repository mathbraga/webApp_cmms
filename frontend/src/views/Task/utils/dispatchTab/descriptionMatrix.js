import React from 'react';
import { FormGroup, Label, Input } from 'reactstrap';

export function currentStateInfo({createdAt, taskStatusText, teamName, events}) {
  let receivedDate = createdAt;
  let lastNote = "Tarefa tramitada sem observações"
  
  events.forEach(event => {
    if (event.eventName === 'receive') {
      receivedDate = event.createdAt;
    } else if (event.eventName === 'send') {
      lastNote = event.note;
    }
  })
  
  return (
    [
      [
        { id: 'status', title: 'Status', description: taskStatusText, span: 1 },
        { id: 'receivedDate', title: 'Data de recebimento', description: receivedDate.split("T")[0], span: 1 },
      ],
      [
        { id: 'team', title: 'Equipe', description: teamName, span: 1 },
        { id: 'totalDays', title: 'Dias com a tarefa', description: 'TODO', span: 1 }
      ],
      [
        { id: 'obs', title: 'Último despacho (tramitação)', description: lastNote, span: 2 },
      ],
    ]
  );
}

export function dispatchLogInfo(numEvent, handleLogTypeChange) {
  return (
    [
      [
        { 
          id: 'logData', 
          elementGenerator: () => (
            <FormGroup style={{width: "80%"}}>
              <Label className='desc-sub' for="exampleSelect" style={{ margin: "10px 0 2px 0 " }}>Exibir histórico de</Label>
              <Input type="select" name="select" id="exampleSelect" onChange={handleLogTypeChange}>
                <option value='all'>Tramitações e Status</option>
                <option value='assign'>Tramitações</option>
                <option value='status'>Status</option>
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
