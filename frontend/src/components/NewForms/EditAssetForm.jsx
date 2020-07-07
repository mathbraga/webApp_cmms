import React, { useState } from 'react';
import { Button, Input, InputGroup, InputGroupAddon, InputGroupText } from 'reactstrap';
import Select from 'react-select';
import './AssetForm.css';
import { List } from 'react-virtualized';
import { useQuery, useMutation } from '@apollo/react-hooks';

import { ALL_ASSETS_QUERY } from './graphql/assetFormGql';

const selectStyles = {
  control: base => ({
    ...base,
    border: "1px solid #e4e7e9",
  }),
};

function MenuList({ children }) {
  const rows = children;
  const rowRenderer = ({ key, index, isScrolling, isVisible, style }) => (
    <div key={key} style={style}>{rows[index]}</div>
  )
  
  return (
    <List 
      style={{ width: '100%' }}
      width={600}
      height={300}
      rowHeight={30}
      rowCount={rows.length}
      rowRenderer={rowRenderer}
    />
  );
}

function EditAssetForm({ toggleForm }) {
  const [ assets, setAssets ] = useState([
    {id: '9', name: 'Bloco 14 - Mezanino', assetSf: 'BL14-MEZ-043'},
    {id: '10', name: 'Anexo II - Gabinete 10', assetSf: 'AX02-GAB-010'},
  ]);
  const [ assetOptions, setAssetOptions ] = useState([]);
  
  const { loading, data } = useQuery(ALL_ASSETS_QUERY, {
    onCompleted: ({ allTaskData: { nodes: [{ assetOptions }]}}) => {
      const assetsSelect = assetOptions.map(asset => ({value: asset.id, label: `${asset.assetSf}: ${asset.name}`}));
      setAssetOptions(assetsSelect);
    }
  });
  
  console.log("AssetOptions: ", assetOptions);

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
                name="assets"
                components={{ MenuList }}
                placeholder={'Edifício / Equipamento'}
                options={assetOptions}
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
            Excluir ativos
          </div>
          <div className='miniform__field__sub-label'>
            Ao excluir qualquer ativo, ele será retirado imediatamente desta tarefa.
          </div>
          {assets.map(asset => (
            <div className='miniform__field__item'>
              <div className='miniform__field__edit-supply' style={{width: '25%'}}>
                <Input value={asset.assetSf} style={{ backgroundColor: "white" }} disabled/>
              </div>
              <div className='miniform__field__edit-supply' style={{width: '60%'}}>
                <Input value={asset.name} style={{ backgroundColor: "white" }}  disabled/>
              </div>
              <div style={{width: '15%', textAlign: 'center'}}>
                <Button outline color="danger" size="sm" onClick={() => {}}>Exlcuir</Button>
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
 
export default EditAssetForm;