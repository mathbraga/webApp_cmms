import React, { Component } from 'react';
import Select from 'react-select';
import { Button, Input, InputGroup, InputGroupAddon, InputGroupText } from 'reactstrap';
import classNames from 'classnames';
import './SupplyForm.css';

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

class EditSupplyForm extends Component {
  state = {  }
  render() { 
    const { visible, toggleForm } = this.props;
    const miniformClass = classNames({
      'miniform-container': true,
      'miniform-disabled': !visible
    });
    return ( 
      <div className={miniformClass}>
          <div className='miniform__field'>
            <div className='miniform__field__label'>
              Alterar ou exlcuir suprimento
            </div>
            <div className='miniform__field__sub-label'>
              Ao salvar, os itens alterados na lista abaixo serão gravados na tabela de suprimentos.
            </div>
            <div className='miniform__field__item'>
              <div className='miniform__field__edit-supply' style={{flexGrow: '1'}}>
                <Select
                  className="basic-single"
                  classNamePrefix="select"
                  defaultValue={'Semac'}
                  isClearable
                  isSearchable
                  name="team"
                  placeholder={'Estoque'}
                  options={teamsFake}
                  styles={selectStyles}
                />
              </div>
              <div className='miniform__field__edit-supply' style={{flexGrow: '1'}}>
                <Select
                  className="basic-single"
                  classNamePrefix="select"
                  defaultValue={'Semac'}
                  isClearable
                  isSearchable
                  name="team"
                  placeholder={'Suprimento'}
                  options={teamsFake}
                  styles={selectStyles}
                />
              </div>
              <div className='miniform__field__edit-supply' style={{flexGrow: '1'}}>
                <InputGroup>
                  <Input className='miniform__field__textarea' style={{ textAlign: 'right' }} placeholder='0,00'/>
                  <InputGroupAddon addonType="append">
                    <InputGroupText>metro(s)</InputGroupText>
                  </InputGroupAddon>
                </InputGroup>
              </div>
              <div style={{flexGrow: '1'}}>
                <div className="miniform__field__remove-button">
                  Exlcuir
                </div>
              </div>
            </div>
          </div>
          <div className='miniform__buttons'>
            <Button 
              color="success" 
              size="sm" 
              style={{ marginRight: "10px" }}
              onClick={() => {}}
            >
              Salvar
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
 
export default EditSupplyForm;