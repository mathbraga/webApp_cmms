import React, { Component } from 'react';

class DispatchForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      
    }
  }
  render() { 
    return ( 
      <div className='miniform-container'>
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
                className={'miniform__field__textarea'}
                type="textarea" 
                name="text" 
                id="exampleText" 
              />
            </div>
          </div>
          <div className='miniform__buttons'>
            <Button color="success" size="sm" style={{ marginRight: "10px" }}>
              Tramitar
            </Button>
            <Button color="secondary" size="sm" style={{ marginRight: "10px" }}>
              Limpar
            </Button>
            <Button color="danger" size="sm">
              Cancelar
            </Button>
          </div>
        </div>
     );
  }
}
 
export default DispatchForm;