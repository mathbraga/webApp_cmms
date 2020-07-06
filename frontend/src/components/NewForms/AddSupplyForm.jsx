import React, { useState } from 'react';
import Select from 'react-select';
import { Button, Input, InputGroup, InputGroupAddon, InputGroupText } from 'reactstrap';
import classNames from 'classnames';
import NumberFormat from 'react-number-format';
import './SupplyForm.css';

import { useQuery, useMutation } from '@apollo/react-hooks';

import { SUPPLIES_QUERY, INSERT_SUPPLY, TASK_SUPPLIES_QUERY } from './graphql/supplyFormGql';

const selectStyles = {
  control: base => ({
    ...base,
    border: "1px solid #e4e7e9",
  }),
};

const formatter = new Intl.NumberFormat('pt-BR', {
  style: 'currency',
  currency: 'BRL',
});

function AddSupplyForm({ visible, toggleForm, taskId, setAddFormOpen }) {
  const [ contract, setContract ] = useState(null);
  const [ supply, setSupply ] = useState(null);
  const [ quantity, setQuantity ] = useState(null);
  
  const { loading, data: { allContractData: { nodes: contracts } = {} } = {} } = useQuery(SUPPLIES_QUERY);
  
  const [insertSupply, { error }] = useMutation(INSERT_SUPPLY, {
    variables: {
      taskId,
      supplyId: supply && supply.supplyId,
      qty: quantity
    },
    onCompleted: () => {
      setContract(null);
      setSupply(null);
      setQuantity(null);
      setAddFormOpen(false);
    },
    refetchQueries: [{ query: TASK_SUPPLIES_QUERY, variables: { taskId } }, { query: SUPPLIES_QUERY }],
    onError: (err) => { console.log(err); },
  });
  
  const contractsOption = contracts ? contracts.map(contract => ({
    value: contract.contractId, 
    label: `${contract.contractSf.split(/([0-9]+)/)[0]} ${contract.contractSf.split(/([0-9]+)/)[1]} - ${contract.company}`})) : [];
  
  const suppliesOption = contracts ? contracts.map(contract => ({
    label: `${contract.contractSf.split(/([0-9]+)/)[0]} ${contract.contractSf.split(/([0-9]+)/)[1]} - ${contract.company}`, 
    options: contract.supplies.map(supply => ({
      label: `${supply.supplySf}: ${supply.name}`,
      value: supply.supplyId,
      contract: {value: contract.contractId, label: `${contract.contractSf.split(/([0-9]+)/)[0]} ${contract.contractSf.split(/([0-9]+)/)[1]} - ${contract.company}`},
      bidPrice: supply.bidPrice,
      supplySf: supply.supplySf,
      supplyId: supply.supplyId,
      qtyAvailable: supply.qtyAvailable,
      unit: supply.unit
    }))
  })) : [];
  
  const filteredSuppliesOption = !contract || !contracts ? suppliesOption : suppliesOption.filter(option => (option.label === contract.label));
  
  const miniformClass = classNames({
    'miniform-container': true,
    'miniform-disabled': !visible
  });
  
  function handleChangeContract(contract) {
    setContract(contract);
    setSupply(null);
    setQuantity(null);
  }
  
  function handleChangeSupply(supply) {
    setSupply(supply);
    setQuantity(null);
    if (!contract && supply) {
      setContract(supply.contract);
    }
  }
  
  function handleChangeQuantity(event) {
    setQuantity(parseFloat(event.target.value.replace(/\./g, '').replace(/,/g, '.')));
  }
  
  function handleSubmit() {
    insertSupply();
  }
  
  return ( 
    <div className={miniformClass}>
        <div className='miniform__field'>
          <div className='miniform__field__label'>
            Adicionar suprimento
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
                value={contract}
                options={contractsOption}
                styles={selectStyles}
                onChange={handleChangeContract}
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
                value={supply}
                options={filteredSuppliesOption}
                styles={selectStyles}
                onChange={handleChangeSupply}
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
                {supply ? supply.supplySf : "-"}
              </div>
            </div>
            <div className="miniform__info__container">
              <div className="miniform__info__label">
                Quantidade Disponível
              </div>
              <div className="miniform__info__value" style={{ color: '#f86c6b' }}>
                {supply ? `${supply.qtyAvailable} ${supply.unit}` : "-"}
              </div>
            </div>
            <div className="miniform__info__container">
              <div className="miniform__info__label">
                Preço Unitário
              </div>
              <div className="miniform__info__value">
                {supply ? formatter.format(supply.bidPrice) : "-"}
              </div>
            </div>
          </div>
        </div>
        <div className='miniform__field'>
          <div className='miniform__field__label'>
            Quantidade
          </div>
          <div className='miniform__field__sub-label'>
            Indique a quantidade utilizada. **Atenção com a unidade de medida.
          </div>
          <div className="miniform__field__input__container">
            <div className='miniform__field__input-half'>
              <InputGroup>
                <NumberFormat 
                  className='form-control miniform__field__textarea'
                  thousandSeparator={'.'} 
                  decimalSeparator={','}
                  style={{ textAlign: 'right' }} 
                  placeholder='0,00'
                  decimalScale='2'
                  value={quantity}
                  fixedDecimalScale={true}
                  onChange={handleChangeQuantity}
                />
                <InputGroupAddon addonType="append">
                  <InputGroupText>{supply ? supply.unit  : "-"}</InputGroupText>
                </InputGroupAddon>
               </InputGroup>
            </div>
            <div className='miniform__field__input-half'>
              <div className="miniform__info__label" style={{ textAlign: 'center' }}>
                Valor Total
              </div>
              <div className="miniform__info__value">
                {supply ? formatter.format(supply.bidPrice * quantity) : "-"}
              </div>
            </div>
          </div>
        </div>
        <div className='miniform__buttons'>
          <Button 
            color="success" 
            size="sm" 
            style={{ marginRight: "10px" }}
            onClick={handleSubmit}
          >
            Adicionar Item
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
            Voltar
          </Button>
        </div>
      </div>
   );
}
 
export default AddSupplyForm;