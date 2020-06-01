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

const contractsFake = [
  {value: '1', label: 'CT 02002020'}, 
  {value: '2', label: 'CT 02012020'}, 
  {value: '3', label: 'CT 02022020'},
  {value: '4', label: 'CT 02032020'},
  {value: '5', label: 'CT 02042020'},
  {value: '6', label: 'CT 02052020'},
  {value: '7', label: 'CT 02062020'},
  {value: '8', label: 'CT 02072020'},
  {value: '9', label: 'CT 02082020'},
  {value: '10', label: 'CT 02092020'},
  {value: '11', label: 'CT 02102020'},
  {value: '12', label: 'CT 02112020'},
];

const suppliesFake = [
  {value: '1', label: 'Arame galvanizado, bitola 16 BWG'}, 
  {value: '2', label: 'Arame farpado'}, 
  {value: '3', label: 'Alicate'},
  {value: '4', label: 'Parafuso'},
  {value: '5', label: 'Tinta cor branca'},
  {value: '6', label: 'Areia'},
  {value: '7', label: 'Concreto'},
  {value: '8', label: 'Brita'},
];

class EditSupplyForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      supplies: [
        {contract: {value: '9', label: 'CT 02082020'}, item: {value: '8', label: 'Brita'}, quantity: 122.12, unit: 'm³'},
        {contract: {value: '9', label: 'CT 02082020'}, item: {value: '1', label: 'Arame galvanizado, bitola 16 BWG'}, quantity: 122.12, unit: 'm³'},
        {contract: {value: '9', label: 'CT 02082020'}, item: {value: '6', label: 'Areia'}, quantity: 122.12, unit: 'm³'},
        {contract: {value: '9', label: 'CT 02082020'}, item: {value: '7', label: 'Concreto'}, quantity: 122.12, unit: 'm³'},
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
                <div className='miniform__field__edit-supply' style={{flexGrow: '1'}}>
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
                <div className='miniform__field__edit-supply' style={{flexGrow: '1'}}>
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
                <div className='miniform__field__edit-supply' style={{flexGrow: '1'}}>
                  <InputGroup>
                    <Input className='miniform__field__textarea' style={{ textAlign: 'right' }} value={supply.quantity} placeholder='0,00'/>
                    <InputGroupAddon addonType="append">
                      <InputGroupText>{supply.unit}</InputGroupText>
                    </InputGroupAddon>
                  </InputGroup>
                </div>
                <div style={{flexGrow: '1'}}>
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