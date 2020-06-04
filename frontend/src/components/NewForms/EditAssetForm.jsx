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

class EditAssetForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      supplies: [
        {id: '9', label: 'Bloco 14 - Mezanino'},
        {id: '10', label: 'Anexo II - Gabinete 10'},
      ],
    };
  }
  
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
            {this.state.supplies.map(supply => (
              <div className='miniform__field__item'>
                <div className='miniform__field__edit-supply' style={{width: '30%'}}>
                  <Select
                    className="basic-single"
                    classNamePrefix="select"
                    defaultValue={'Semac'}
                    isClearable
                    isSearchable
                    name="team"
                    value={supply.contract}
                    placeholder={'Estoque'}
                    options={contractsFake}
                    styles={selectStyles}
                  />
                </div>
                <div className='miniform__field__edit-supply' style={{width: '40%'}}>
                  <Select
                    className="basic-single"
                    classNamePrefix="select"
                    defaultValue={'Semac'}
                    isClearable
                    isSearchable
                    name="team"
                    placeholder={'Suprimento'}
                    value={supply.item}
                    options={suppliesFake}
                    styles={selectStyles}
                  />
                </div>
                <div className='miniform__field__edit-supply' style={{ width: '20%'}}>
                  <InputGroup>
                    <Input className='miniform__field__textarea' style={{ textAlign: 'right', width: '60%' }} value={supply.quantity} placeholder='0,00'/>
                    <InputGroupAddon addonType="append" style={{ width: '40%' }}>
                      <InputGroupText style={{ justifyContent: 'center', textOverflow: 'hidden', width: '100%' }}>{supply.unit}</InputGroupText>
                    </InputGroupAddon>
                  </InputGroup>
                </div>
                <div style={{width: '10%'}}>
                  <div className="miniform__field__remove-button">
                    Exlcuir
                  </div>
                </div>
              </div>
            ))}
          </div>
          <div className='miniform__buttons'>
            <Button 
              color="success" 
              size="sm" 
              style={{ marginRight: "10px" }}
              onClick={toggleForm}
            >
              Salvar
            </Button>
            <Button 
              color="secondary" 
              size="sm" 
              style={{ marginRight: "10px" }}
              onClick={toggleForm}
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
}
 
export default EditAssetForm;