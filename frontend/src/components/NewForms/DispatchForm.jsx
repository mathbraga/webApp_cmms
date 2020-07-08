import React, { useState } from 'react';
import Select from 'react-select';
import { Button, Input } from 'reactstrap';
import classNames from 'classnames';
import './DispatchForm.css'

const selectStyles = {
  control: base => ({
    ...base,
    border: "1px solid #e4e7e9",
  }),
};

const teamsFake = [
  {value: 'Semac', label: 'Semac'}, 
  {value: 'Coemant', label: 'Coemant'}, 
  {value: 'Sinfra', label: 'Sinfra'},
  {value: 'Coproj', label: 'Coproj'},
  {value: 'Copre', label: 'Copre'},
  {value: 'GabSinfra', label: 'Gabinete Sinfra'},
  {value: 'Seau', label: 'Seau'},
  {value: 'Dger', label: 'Dger'},
  {value: 'Ngcic', label: 'Ngcic'},
  {value: 'Ngcot', label: 'Ngcoc'},
  {value: 'Segp', label: 'Segp'},
  {value: 'Prodasen', label: 'Prodasen'},
];

function DispatchForm({ visible, toggleForm }) { 
  const [ teamValue, setTeamValue ] = useState([]);
  const [ observationValue, setObservationValue ] = useState("");
  
  const miniformClass = classNames({
    'miniform-container': true,
    'miniform-disabled': !visible
  });

  function onChangeTeam(target) {
    if(target) {
      setTeamValue([{
        label: target.label,
        value: target.value,
      }]);
    } else {
      setTeamValue([]);
    }
  }

  function onChangeObservation(target) {
    if(target) {
      setObservationValue(target.value);
    } 
  }

  function handleSubmit(toggleForm) {
    toggleForm();
    handleClean();
  }

  function handleClean() {
    setTeamValue([]);
    setObservationValue("");
  } 

  return ( 
    <div className={miniformClass}>
        <div className='miniform__field'>
          <div className='miniform__field__label'>
            Tramitar para
          </div>
          <div className='miniform__field__sub-label'>
            Escolha a equipe que será o destinatário da tarefa.
          </div>
          <div className='miniform__field__input'>
            <Select
              className="basic-single"
              classNamePrefix="select"
              defaultValue={'Semac'}
              isClearable
              isSearchable
              name="team"
              value={teamValue}
              options={teamsFake}
              styles={selectStyles}
              onChange={onChangeTeam}
              placeholder={'Equipes ...'}
            />
          </div>
        </div>
        <div className='miniform__field'>
          <div className='miniform__field__label'>
            Observações
          </div>
          <div className='miniform__field__sub-label'>
            Deixe registrado o motivo da tramitação, ou qualquer outra informação relevante.
          </div>
          <div className='miniform__field__input'>
            <Input 
              className='miniform__field__textarea'
              type="textarea" 
              name="text"
              value={observationValue}
              id="exampleText" 
              rows='3'
              onChange={onChangeObservation}
              placeholder={''}
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
            Tramitar
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
            onClick={() => {toggleForm(); handleClean()}}
          >
            Cancelar
          </Button>
        </div>
      </div>
   );
}
 
export default DispatchForm;