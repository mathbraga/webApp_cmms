import React, { Component } from 'react';
import { Button, Input, InputGroup, InputGroupAddon, InputGroupText } from 'reactstrap';
import Select from 'react-select';
import './AssetForm.css';

const selectStyles = {
  control: base => ({
    ...base,
    border: "1px solid #e4e7e9",
  }),
};

const assetsFake = [
  {id: '9', name: 'Motor-gerador', assetSf: 'DFEF-2304-234'},
  {id: '10', name: 'Circuito elétrico do Seplag', assetSf: 'ASDF-1545-234'},
  {id: '11', name: 'Quadro geral - Sinfra', assetSf: 'GSFD-2345-234'},
  {id: '12', name: 'CM3 - Chiller', assetSf: 'GFSS-8678-234'},
  {id: '1', name: 'Bloco 10 - Subsolo', assetSf: 'BL10-SUB-010'},
  {id: '2', name: 'Anexo I - Térreo', assetSf: 'AX01-TER-002'},
  {id: '3', name: 'Edifício Principal - 2 Andar', assetSf: 'EDPR-2AD-052'},
  {id: '4', name: 'Anexo II - Subsolo', assetSf: 'AX02-SUB-005'},
  {id: '5', name: 'Anexo I - 27 Andar', assetSf: 'AX01-27A-005'},
  {id: '6', name: 'Bloco 14 - Mezanino', assetSf: 'BL14-MEZ-010'},
  {id: '7', name: 'Bloco 12 - Térreo', assetSf: 'BL12-TER-014'},
  {id: '8', name: 'Bloco 10 - Subsolo', assetSf: 'BL10-SUB-014'},
];

const assetsFakeDrop = assetsFake.map(asset => ({value: asset.id, label: `${asset.name} (${asset.assetSf})`}));

class EditAssetForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      assets: [
        {id: '9', name: 'Bloco 14 - Mezanino', assetSf: 'BL14-MEZ-043'},
        {id: '10', name: 'Anexo II - Gabinete 10', assetSf: 'AX02-GAB-010'},
      ],
    };
  }
  
  render() { 
    const { toggleForm } = this.props;

    return ( 
      <div className={'miniform-container'}>
        <div className='miniform__field'>
            <div className='miniform__field__label'>
              Adicionar ativo
            </div>
            <div className='miniform__field__sub-label'>
              Ao incluir um novo ativo, ele será vinculado imediatamente a esta tarefa.
            </div>
            <div className="miniform__field__input__container">
              <div className='miniform__field__input' style={{ width: '80%' }}>
                <Select
                  className="basic-single"
                  classNamePrefix="select"
                  isClearable
                  isSearchable
                  name="team"
                  placeholder={'Edifício / Equipamento'}
                  options={assetsFakeDrop}
                  styles={selectStyles}
                />
              </div>
              <div className='miniform__buttons-inline'>
                <Button 
                  color="primary" 
                  size="sm" 
                  onClick={toggleForm}
                >
                  Incluir Ativo
                </Button>
              </div>
            </div>
          </div>
          <div className='miniform__field'>
            <div className='miniform__field__label'>
              Tabela de ativos
            </div>
            <div className='miniform__field__sub-label'>
              Ao excluir qualquer ativo, ele será retirado imediatamente desta tarefa.
            </div>
            {this.state.assets.map(asset => (
              <div className='miniform__field__item'>
                <div className='miniform__field__edit-supply' style={{width: '25%'}}>
                  <Input value={asset.assetSf} style={{ backgroundColor: "white" }} disabled/>
                </div>
                <div className='miniform__field__edit-supply' style={{width: '60%'}}>
                  <Input value={asset.name} style={{ backgroundColor: "white" }}  disabled/>
                </div>
                <div style={{width: '15%'}}>
                  <div className="miniform__field__remove-button">
                    Exlcuir
                  </div>
                </div>
              </div>
            ))}
          </div>
          <div className='miniform__buttons'>
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
}
 
export default EditAssetForm;