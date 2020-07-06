import React, { useState } from 'react';
import { Button, Input, InputGroup, InputGroupAddon, InputGroupText } from 'reactstrap';
import classNames from 'classnames';
import NumberFormat from 'react-number-format';
import './SupplyForm.css';

function EditSupplyForm({ visible, toggleForm, taskId, supplies = [] }) {
  const [ formSupplies, setFormSupplies ] = useState(supplies);
  
  const miniformClass = classNames({
    'miniform-container': true,
    'miniform-disabled': !visible
  });
  
  function handleChangeQuantity({ target }) {
    const  newSupplies = formSupplies.map(supply => {
      if (supply.supplyId == target.id) {
        return {...supply, qty: parseFloat(target.value.replace(/\./g, '').replace(/,/g, '.'))};
      }
      return {...supply};
    });
    setFormSupplies(newSupplies);
  }
  
  function handleCancel() {
    toggleForm();
    setInterval(() => { setFormSupplies(supplies); }, 1000);
  }
  
  console.log("formSupplies: ", formSupplies)
  
  return ( 
    <div className={miniformClass}>
        <div className='miniform__field'>
          <div className='miniform__field__label'>
            Alterar ou exlcuir suprimento
          </div>
          <div className='miniform__field__sub-label'>
            Ao salvar, os itens alterados na lista abaixo serão gravados na tabela de suprimentos.
          </div>
          {formSupplies.map(supply => (
            <div className='miniform__field__item'>
              <div className='miniform__field__edit-supply' style={{width: '25%'}}>
                <Input value={`${supply.contractSf} - ${supply.company}`} style={{ backgroundColor: "#f1f1f1" }} disabled/>
              </div>
              <div className='miniform__field__edit-supply' style={{width: '40%'}}>
                <Input value={supply.name} style={{ backgroundColor: "#f1f1f1" }} disabled/>
              </div>
              <div className='miniform__field__edit-supply' style={{ width: '25%'}}>
                <InputGroup>
                  <NumberFormat 
                    id={supply.supplyId}
                    className='form-control miniform__field__textarea'
                    thousandSeparator={'.'} 
                    decimalSeparator={','}
                    style={{ textAlign: 'right' }} 
                    placeholder='0,00'
                    decimalScale='2'
                    value={supply.qty}
                    fixedDecimalScale={true}
                    onChange={handleChangeQuantity}
                  />
                  <InputGroupAddon addonType="append" style={{ width: '50%', textOverflow: 'hidden', }}>
                    <InputGroupText style={{ justifyContent: 'center', textOverflow: 'hidden', width: '100%' }}>{supply ? supply.unit  : "-"}</InputGroupText>
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
            color="danger" 
            size="sm"
            onClick={handleCancel}
          >
            Cancelar
          </Button>
        </div>
      </div>
   );
}
 
export default EditSupplyForm;