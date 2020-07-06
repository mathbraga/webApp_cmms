import React, { Component } from 'react';
import Select from 'react-select';
import { Button, Input, InputGroup, InputGroupAddon, InputGroupText } from 'reactstrap';
import classNames from 'classnames';
import './SupplyForm.css';

class EditSupplyForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      supplies: [
        {contract: {value: '9', label: 'CT 02082020'}, item: {value: '8', label: 'Brita'}, quantity: 130.00, unit: 'm³'},
        {contract: {value: '9', label: 'CT 02082020'}, item: {value: '1', label: 'Arame galvanizado, bitola 16 BWG'}, quantity: 7.5, unit: 'm'},
        {contract: {value: '9', label: 'CT 02082020'}, item: {value: '6', label: 'Areia'}, quantity: 22.000, unit: 'dm³'},
        {contract: {value: '9', label: 'CT 02082020'}, item: {value: '7', label: 'Concreto'}, quantity: 12, unit: 'm³'},
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
                  <Input value={supply.contract.label} style={{ backgroundColor: "#f1f1f1" }} disabled/>
                </div>
                <div className='miniform__field__edit-supply' style={{width: '40%'}}>
                  <Input value={supply.item.label} style={{ backgroundColor: "#f1f1f1" }} disabled/>
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
 
export default EditSupplyForm;