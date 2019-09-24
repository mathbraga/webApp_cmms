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

const formsQuery = gql`
        query MyQuery {
          allFacilities(orderBy: ASSET_ID_ASC) {
            edges {
              node {
                assetId
                name
              }
            }
          }
          allAssets(condition: {category: A}, orderBy: ASSET_ID_ASC) {
            edges {
              node {
                assetId
                name
                parent
                assetByParent {
                  name
                }
              }
            }
          }
        }`;

class EquipmentsForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      assetName: null,
      assetId: null,
      description: null,
      assetParent: null,
      price: null,
      location: null,
      manufacturer: null,
      model: null,
      serialNum: null
    };

    this.handleParentDropDownChange = this.handleParentDropDownChange.bind(this);
    this.handleLocationDropDownChange = this.handleLocationDropDownChange.bind(this);
    this.handleInputChange = this.handleInputChange.bind(this);
  }

  handleParentDropDownChange(assetId) {
    this.setState({ assetParent: assetId });
  }

  handleLocationDropDownChange(location) {
    this.setState({ location: location });
  }

  handleInputChange(event) {
    if (event.target.value.length === 0)
      return this.setState({ [event.target.name]: null });
    this.setState({ [event.target.name]: event.target.value });
  }

  render() {
    console.log(this.state);
    const newEquipment = gql`
      mutation MyMutation (
          $assetId: String!,
          $description: String!,
          $manufacturer: String,
          $model: String,
          $name: String!,
          $parent: String!,
          $place: String!,
          $price: Float,
          $serialnum: String
        ){
        insertAppliance(
          input: {
            applianceAttributes: {
              assetId: $assetId
              description: $description
              manufacturer: $manufacturer
              model: $model
              name: $name
              parent: $parent
              place: $place
              price: $price
              serialnum: $serialnum
              category: A
            }
          }
        ){
        clientMutationId
        string
      }
    }`;

    const mutate = (insertData) => (
      insertData().then(console.log("Mutation"))
    )

    return (
      <Mutation
        mutation={newEquipment}
        variables={{
          assetId: this.state.assetId,
          description: this.state.description,
          manufacturer: this.state.manufacturer,
          model: this.state.model,
          name: this.state.assetName,
          parent: this.state.assetParent,
          place: this.state.location,
          price: Number(this.state.price),
          serialnum: this.state.serialNum
        }}
      >
        {(mutation, { data, loading, error }) => {
          if (loading) return null;
          if (error) {
            console.log(error);
            return null;
          }
          return (
            <Query query={formsQuery}>{
              ({ loading, error, data }) => {
                if (loading) return null
                if (error) {
                  console.log("Erro ao tentar baixar os dados!");
                  return null
                }

                const assetId = data.allFacilities.edges.map((item) => item.node.assetId);
                const assetName = data.allFacilities.edges.map((item) => item.node.name);
                //console.log(assetId);
                //console.log(assetName);

                const assets = [];
                for (let i = 0; i < assetId.length; i++)
                  assets.push({ id: assetId[i], text: assetName[i], subtext: assetId[i] });

                const applianceId = data.allAssets.edges.map((item) => item.node.assetId);
                const parentName = data.allAssets.edges.map((item) => item.node.assetByParent.name);
                const applianceName = data.allAssets.edges.map((item) => item.node.name);

                const appliances = [];
                for (let i = 0; i < applianceId.length; i++)
                  appliances.push({ id: applianceId[i], text: applianceName[i], subtext: parentName[i] });
                //console.log(appliances);

                return (
                  <div style={{ margin: "0 100px" }}>
                    <Form
                      className="form-horizontal"
                      onSubmit={e => {
                        e.preventDefault();
                        mutate(mutation)
                      }}
                      onReset={() => this.props.history.push('/ativos/equipamentos')}
                    >
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
                                listDropdown={appliances}
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
                )
              }}</Query>
          )
        }}</Mutation>
    );
  }
}

export default withRouter(EquipmentsForm);