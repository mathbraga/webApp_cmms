import React, { Component } from 'react';
import './AddSupplyForm.css';

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

class AddSupplyForm extends Component {
  state = {  }
  render() { 
    const miniformClass = classNames({
      'miniform-container': true,
      'miniform-disabled': !visible
    });
    return ( 
      <div className={miniformClass}>
          <div className='miniform__field'>
            <div className='miniform__field__label'>
              Escolher suprimento
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
                options={teamsFake}
                styles={selectStyles}
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
                id="exampleText" 
                rows='3'
                onChange={() => {}}
                placeholder={''}
              />
            </div>
          </div>
          <div className='miniform__buttons'>
            <Button 
              color="success" 
              size="sm" 
              style={{ marginRight: "10px" }}
              onClick={() => {() => {}}}
            >
              Tramitar
            </Button>
            <Button 
              color="secondary" 
              size="sm" 
              style={{ marginRight: "10px" }}
              onClick={() => {}}
            >
              Limpar
            </Button>
            <Button 
              color="danger" 
              size="sm"
              onClick={() => {}}
            >
              Cancelar
            </Button>
          </div>
        </div>
     );
  }
}
 
export default AddSupplyForm;