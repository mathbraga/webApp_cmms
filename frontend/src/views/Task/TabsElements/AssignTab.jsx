import React, { Component } from 'react';

import DescriptionTable from '../../../components/Descriptions/DescriptionTable';
import CustomTable from '../../../components/Tables/CustomTable';
import { Button, Input } from 'reactstrap';
import Select from 'react-select';
import { itemsMatrixAssetsHierachy } from '../utils/dispatchTab/descriptionMatrix';

const selectStyles = {
  control: base => ({
    ...base,
    border: "1px solid #e4e7e9",
  }),
};

class AssignTab extends Component {
  state = {}
  render() {
    const data = this.props.data.assets;
    return (
      <>
        <div 
          className='action-container'
        >
          <div className="action__text">Tramitar Tarefa / Alterar Status</div>
          <div className='action__buttons'>
            <Button color="success" size="sm" style={{ marginRight: "10px" }}>
              Tramitar
            </Button>
            <Button color="primary" size="sm">
              Alterar Status
            </Button>
          </div>
        </div>
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
                options={[{value: 'Semac', label: 'Semac'}, {value: 'Coemant', label: 'Coemant'}, {value: 'Sinfra', label: 'Sinfra'}]}
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
        <DescriptionTable
          title={'Unidade Atual'}
          numColumns={2}
          itemsMatrix={itemsMatrixAssetsHierachy(data)}
        />
      </>
    );
  }
}

export default AssignTab;