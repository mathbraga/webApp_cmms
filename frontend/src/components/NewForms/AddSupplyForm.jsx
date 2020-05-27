import React, { Component } from 'react';
import Select from 'react-select';
import { Button, Input, InputGroup, InputGroupAddon, InputGroupText } from 'reactstrap';
import classNames from 'classnames';
import './AddSupplyForm.css';

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

class AddSupplyForm extends Component {
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
              Escolher o suprimento
            </div>
            <div className='miniform__field__sub-label'>
              Escolha o estoque que será utilizado, e logo em seguida o suprimento.
            </div>
            <div className="miniform__field__input__container">
              <div className='miniform__field__input-half'>
                <Select
                  className="basic-single"
                  classNamePrefix="select"
                  defaultValue={'Semac'}
                  isClearable
                  isSearchable
                  name="team"
                  placeholder={'Estoque (contrato, nota fiscal, ...)'}
                  options={teamsFake}
                  styles={selectStyles}
                />
              </div>
              <div className='miniform__field__input-half'>
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
            </div>
          </div>
          <div className='miniform__field'>
            <div style={{ display: 'flex', justifyContent: 'space-around', width: '100%' }}>
              <div className="miniform__info__container">
                <div className="miniform__info__label">
                  Código do Item
                </div>
                <div className="miniform__info__value">
                  SF-054205
                </div>
              </div>
              <div className="miniform__info__container">
                <div className="miniform__info__label">
                  Quantidade Disponível
                </div>
                <div className="miniform__info__value" style={{ color: '#f86c6b' }}>
                  735 metro(s)
                </div>
              </div>
              <div className="miniform__info__container">
                <div className="miniform__info__label">
                  Preço Unitário
                </div>
                <div className="miniform__info__value">
                  R$ 12,00
                </div>
              </div>
            </div>
          </div>
          <div className='miniform__field'>
            <div className='miniform__field__label'>
              Quantitativo
            </div>
            <div className='miniform__field__sub-label'>
              Indique a quantidade utilizada. **Atenção para a unidade de medida.
            </div>
            <div className="miniform__field__input__container">
              <div className='miniform__field__input-half'>
                <InputGroup>
                  <Input className='miniform__field__textarea' style={{ textAlign: 'right' }} placeholder='0,00'/>
                  <InputGroupAddon addonType="append">
                    <InputGroupText>metro(s)</InputGroupText>
                  </InputGroupAddon>
                </InputGroup>
              </div>
              <div className='miniform__field__button'>
                <Button 
                  color="primary" 
                  size="sm" 
                  style={{ marginRight: "10px" }}
                  onClick={() => {}}
                >
                  Adicionar Item
                </Button>
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
 
export default AddSupplyForm;