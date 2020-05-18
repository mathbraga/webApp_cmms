import React, { Component } from 'react';
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
  {value: 'Concluído', label: 'Concluído'}, 
  {value: 'Cancelado', label: 'Cancelado'}, 
  {value: 'Espera', label: 'Fila de Espera'},
  {value: 'Execução', label: 'Em Execução'},
  {value: 'Pendente', label: 'Pendente'},
  {value: 'Suspenso', label: 'Suspenso'},
  {value: 'Análise', label: 'Em análise'},
];

class StatusForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      statusValue: [],
      observationValue: null,
    }

    this.onChangeStatus = this.onChangeStatus.bind(this);
    this.onChangeObservation = this.onChangeObservation.bind(this);
  }

  onChangeStatus(target) {
    if(target) {
      this.setState({
        statusValue: Array.of({
          label: target.label,
          value: target.value,
        })
      });
    } else {
      this.setState({
        statusValue: Array.of()
      });
    }
  }

  onChangeObservation(target) {
    if(target) {
      this.setState({
        observationValue: target.value,
      });
    } 
  }

  render() { 
    const { visible } = this.props;
    const { statusValue, observationValue } = this.state;
    const miniformClass = classNames({
      'miniform-container': true,
      'miniform-disabled': !visible
    });
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
                onChange={this.onChangeStatus}
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
                onChange={this.onChangeObservation}
              />
            </div>
          </div>
          <div className='miniform__buttons'>
            <Button color="success" size="sm" style={{ marginRight: "10px" }}>
              Alterar
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
 
export default StatusForm;