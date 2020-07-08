import React, { useState } from 'react';
import Select from 'react-select';
import { Button, Input } from 'reactstrap';
import classNames from 'classnames';
import './DispatchForm.css'
import { useQuery, useMutation } from '@apollo/react-hooks';

import { ALL_TEAMS_QUERY, SEND_TASK, TASK_TEAMS_QUERY } from './graphql/dispatchFormGql';

const selectStyles = {
  control: base => ({
    ...base,
    border: "1px solid #e4e7e9",
  }),
};

const teamsFake = [
  {value: 'Concluído', label: 'Concluído'}, 
  {value: 'Cancelado', label: 'Cancelado'}, 
  {value: 'Espera', label: 'Fila de Espera'},
  {value: 'Execução', label: 'Em Execução'},
  {value: 'Pendente', label: 'Pendente'},
  {value: 'Suspenso', label: 'Suspenso'},
  {value: 'Análise', label: 'Em análise'},
];

function StatusForm({ visible, toggleForm, taskId }) {
  const [ statusValue, setStatusValue ] = useState(null);
  const [ observationValue, setObservationValue ] = useState(null);
  const [ statusOptions, setStatusOptions ] = useState([]);
  
  const miniformClass = classNames({
    'miniform-container': true,
    'miniform-disabled': !visible
  });

  function onChangeStatus(target) {
    if(target) {
      setStatusValue({
        label: target.label,
        value: target.value
      });
    } else {
      setStatusValue(null);
    }
  }

  function onChangeObservation(target) {
    if(target) {
      setObservationValue(target.value);
    } 
  }

  function handleSubmit(toggleForm) {
    toggleForm();
  }

  function handleClean() {
    setStatusValue(null);
    setObservationValue(null);
  }

  return ( 
    <div className={miniformClass}>
        <div className='miniform__field'>
          <div className='miniform__field__label'>
            Novo status
          </div>
          <div className='miniform__field__sub-label'>
            Escolha o status atual da tarefa.
          </div>
          <div className='miniform__field__input'>
            <Select
              className="basic-single"
              classNamePrefix="select"
              defaultValue={'Semac'}
              isClearable
              isSearchable
              name="team"
              value={statusValue}
              options={teamsFake}
              styles={selectStyles}
              onChange={onChangeStatus}
              placeholder={'Status ...'}
            />
          </div>
        </div>
        <div className='miniform__field'>
          <div className='miniform__field__label'>
            Observações
          </div>
          <div className='miniform__field__sub-label'>
            Deixe registrado o motivo da alteração do status, ou qualquer outra informação relevante.
          </div>
          <div className='miniform__field__input'>
            <Input 
              className='miniform__field__textarea'
              type="textarea" 
              name="text" 
              id="exampleText" 
              rows='3'
              value={observationValue}
              onChange={onChangeObservation}
            />
          </div>
        </div>
        <div className='miniform__buttons'>
          <Button 
            color="success" 
            size="sm" 
            style={{ marginRight: "10px" }}
            onClick={() => {handleSubmit(toggleForm)}}
          >
            Alterar
          </Button>
          <Button 
            color="secondary" 
            size="sm" 
            style={{ marginRight: "10px" }}
            onClick={handleClean}
          >
            Limpar
          </Button>
          <Button 
            color="danger" 
            size="sm" 
            onClick={toggleForm}
          >
            Cancelar
          </Button>
        </div>
      </div>
   );
}
 
export default StatusForm;