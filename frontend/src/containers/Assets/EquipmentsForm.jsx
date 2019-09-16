import React, { Component } from 'react';
import {
  Label,
  Input,
  FormGroup,
  Form,
  Col
} from 'reactstrap';

import "./EquipmentsForm.css";

import AssetCard from '../../components/Cards/AssetCard'
import InputWithDropdown from '../../components/Forms/InputWithDropdown';
import SingleInputWithDropDown from '../../components/Forms/SingleInputWithDropdown';

import { withRouter } from "react-router-dom";
import { Query, Mutation } from 'react-apollo';
import gql from 'graphql-tag';

// const assets = [
//   { id: 'BL14-001-001', name: 'Bloco 14 - Pavimento 01' },
//   { id: 'BL14-002-001', name: 'Bloco 14 - Pavimento 02' },
//   { id: 'ANX2-001-001', name: 'Anexo 2 - Rui Barbosa' },
//   { id: 'ANX2-002-001', name: 'Anexo 2 - Petrônio Portela' },
//   { id: 'ANX2-003-001', name: 'Anexo 2 - Auditório' },
//   { id: 'ANX1-001-001', name: 'Anexo 1 - Pavimento 01' },
//   { id: 'ANX1-002-001', name: 'Anexo 1 - Pavimento 02' },
//   { id: 'ANX1-003-001', name: 'Anexo 1 - Pavimento 03' },
//   { id: 'ANX1-004-001', name: 'Anexo 1 - Pavimento 04' },
//   { id: 'ACAT-010-019', name: 'Ar condicionado - Midea' },
//   { id: 'ACAT-010-020', name: 'Ar condicionado - Carrier' },
//   { id: 'ACAT-010-021', name: 'Ar condicionado - MGX12' },
//   { id: 'ACAT-010-022', name: 'Ar condicionado - Split' },
//   { id: 'QDEN-052-022', name: 'Quadro de Energia Elétrica' },
//   { id: 'QDEN-015-045', name: 'Quadro de Energia Elétrica' },
//   { id: 'QDEN-035-078', name: 'Quadro de Energia Elétrica' },
//   { id: 'GMG1-001-000', name: 'Grupo Motor Gerador' },
//   { id: 'GMG1-001-004', name: 'Motor do Grupo Motor Gerador' },
//   { id: 'GMG1-001-005', name: 'Gerador do Grupo Motor Gerador' },
// ];

const allFacilities = gql`
        query MyQuery {
          allFacilities(orderBy: ASSET_ID_ASC) {
            edges {
              node {
                assetId
                name
              }
            }
          }
        }`;

class EquipmentsForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      assetName: '',
      assetId: '',
      description: '',
      assetParent: '',
      price: 0,
      location: '',
      manufacturer: '',
      model: '',
      serialNum: ''
    };

    this.handleParentDropDownChange = this.handleParentDropDownChange.bind(this);
    this.handleLocationDropDownChange = this.handleLocationDropDownChange.bind(this);
    this.handleInputChange = this.handleInputChange.bind(this);
  }

  handleParentDropDownChange(assetId){
    this.setState({ assetParent: assetId });
  }

  handleLocationDropDownChange(location){
    this.setState({ location: location });
  }

  handleInputChange(event){
    this.setState({ [event.target.name]: event.target.value });
  }

  render() {
    console.log(this.state);
    return (
      <Query query={allFacilities}>{
        ({loading, error, data}) => {
          if(loading) return null
          if(error){
            console.log("Erro ao tentar baixar os dados!");
            return null
          }

          const assetId = data.allFacilities.edges.map((item) => item.node.assetId);
          const assetName = data.allFacilities.edges.map((item) => item.node.name);
          //console.log(assetId);
          //console.log(assetName);
          
          const assets = [];
          for(let i = 0; i<assetId.length; i++)
            assets.push({id: assetId[i], name: assetName[i]});
          
        return(
          <div style={{ margin: "0 100px" }}>
            <Form className="form-horizontal">
              <AssetCard
                sectionName={"Novo equipamento"}
                sectionDescription={"Formulário para cadastro de equipamentos"}
                handleCardButton={() => console.log('Handle Card')}
                buttonName={"Botão"}
                isForm={true}
              >
                <FormGroup row>
                  <Col xs={'8'}>
                    <FormGroup>
                      <Label htmlFor="equipment-name">Nome do equipamento</Label>
                      <Input 
                        onChange={this.handleInputChange}
                        name="assetName" type="text" id="equipment-name" placeholder="Digite o nome do equipamento" />
                    </FormGroup>
                  </Col>
                  <Col xs={'4'}>
                    <FormGroup>
                      <Label htmlFor="equipment-code">Código</Label>
                      <Input 
                        onChange={this.handleInputChange}
                        name="assetId" type="text" id="equipment-code" placeholder="Digite o código do equipamento" />
                    </FormGroup>
                  </Col>
                </FormGroup>
                <FormGroup>
                  <Label htmlFor="description">Descrição</Label>
                  <Input 
                    onChange={this.handleInputChange}
                    name="description" type="textarea" id="description" placeholder="Descrição do equipamento" rows="4" />
                </FormGroup>
                <FormGroup row>
                  <Col xs={'8'}>
                    <FormGroup>
                      <SingleInputWithDropDown
                        label={'Ativo pai'}
                        placeholder="Nível superior do equipamento (outro equipamento ou localização)"
                        listDropdown={assets}
                        update={this.handleParentDropDownChange}
                      />
                    </FormGroup>
                  </Col>
                  <Col xs={'4'}>
                    <FormGroup>
                      <Label htmlFor="price">Preço (R$)</Label>
                      <Input 
                        onChange={this.handleInputChange}
                        name="price" type="text" id="area" placeholder="Preço de aquisição" />
                    </FormGroup>
                  </Col>
                </FormGroup>
                <FormGroup row>
                  <Col xs='8'>
                    <SingleInputWithDropDown
                      label={'Localização'}
                      placeholder={'Localização da manutenção ...'}
                      listDropdown={assets}
                      update={this.handleLocationDropDownChange}
                    />
                  </Col>
                </FormGroup>
                <FormGroup row>
                  <Col xs={'4'}>
                    <FormGroup>
                      <Label htmlFor="manufacturer">Fabricante</Label>
                      <Input 
                        onChange={this.handleInputChange}
                        name="manufacturer" type="text" id="manufacturer" placeholder="Empresa fabricante" />
                    </FormGroup>
                  </Col>
                  <Col xs={'4'}>
                    <FormGroup>
                      <Label htmlFor="model">Modelo</Label>
                      <Input 
                        onChange={this.handleInputChange}
                        name="model" type="text" id="model" placeholder="Modelo" />
                    </FormGroup>
                  </Col>
                  <Col xs={'4'}>
                    <FormGroup>
                      <Label htmlFor="serial-num">Número serial</Label>
                      <Input 
                        onChange={this.handleInputChange}
                        name="serialNum" type="text" id="serial-num" placeholder="Número serial" />
                    </FormGroup>
                  </Col>
                </FormGroup>
              </AssetCard>
            </Form>
          </div>
        )}}</Query>
    );
  }
}

export default withRouter(EquipmentsForm);