import React, { Component } from 'react';
import {
  Label,
  Input,
  FormGroup,
  Form,
  Col
} from 'reactstrap';

import "./FacilitiesForm.css";

import AssetCard from '../../components/Cards/AssetCard'
import InputWithDropdown from '../../components/Forms/InputWithDropdown';
import SingleInputWithDropDown from '../../components/Forms/SingleInputWithDropdown';

import { withRouter } from "react-router-dom";
import { Query, Mutation } from 'react-apollo';
import gql from 'graphql-tag';

const departments = [
  { id: 'sinfra', name: 'Sinfra - Secretaria de Infraestrutura' },
  { id: 'coemant', name: 'Coemant - Coordenação de Manutenção' },
  { id: 'seplag', name: 'Seplag - Serviço de Planejamento e Gestão' },
  { id: 'semac', name: 'Semac - Serviço de Manutenção Civil' },
  { id: 'segen', name: 'Segen - Serviço de Gestão de Energia Elétrica' },
  { id: 'semainst', name: 'Semainst - Serviço de Manutenção de Instalações' },
  { id: 'semel', name: 'Semel - Serviço de Manutenção Eletromecânica' },
  { id: 'seorc', name: 'Seorc - Serviço de Orçamentos' },
  { id: 'copre', name: 'Copre - Coordenação de Projetos e Reformas' },
  { id: 'coproj', name: 'Coproj - Coordenação de Projetos e Obras de Infraestrtura' },
  { id: 'einfra', name: 'Einfra - Escritório Setorial de Gestão da Sinfra' },
];

const facilities = [
  { id: 'BL14-001-001', name: 'Bloco 14 - Pavimento 01' },
  { id: 'BL14-002-001', name: 'Bloco 14 - Pavimento 02' },
  { id: 'ANX2-001-001', name: 'Anexo 2 - Rui Barbosa' },
  { id: 'ANX2-002-001', name: 'Anexo 2 - Petrônio Portela' },
  { id: 'ANX2-003-001', name: 'Anexo 2 - Auditório' },
  { id: 'ANX1-001-001', name: 'Anexo 1 - Pavimento 01' },
  { id: 'ANX1-002-001', name: 'Anexo 1 - Pavimento 02' },
  { id: 'ANX1-003-001', name: 'Anexo 1 - Pavimento 03' },
  { id: 'ANX1-004-001', name: 'Anexo 1 - Pavimento 04' },
];

// const category = [
//   { id: 1, name: 'Ala' },
//   { id: 2, name: 'Auditório' },
//   { id: 3, name: 'Edifício' },
//   { id: 4, name: 'Sala' },
//   { id: 5, name: 'Pavimento' },
// ];

const depQuery = gql`
        query depQuery {
          allDepartments(orderBy: DEPARTMENT_ID_ASC) {
            edges {
              node {
                departmentId
                name
              }
            }
          }
          allFacilities(orderBy: ASSET_ID_ASC) {
            edges {
              node {
                assetId
                name
              }
            }
          }
        }`;

// const testMutation = gql`
//   mutation{

//   }

class FacilitiesForm extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <Query query={depQuery}>{
        ({loading, error, data}) => {
          if(loading) return null
          if(error){
            console.log("Erro ao tentar baixar os dados!");
            return null
          }
          const depsID = data.allDepartments.edges.map((item) => item.node.departmentId);
          const depsName = data.allDepartments.edges.map((item) => item.node.name);

          const facID = data.allFacilities.edges.map((item) => item.node.assetId);
          const facName = data.allFacilities.edges.map((item) => item.node.name);
          //console.log(facID);
          //console.log(facName);
          
          const deps = [];
          for(let i = 0; i<depsID.length; i++)
            deps.push({id: depsID[i], name: depsName[i]});

          const facs = [];
          for(let i = 0; i<facID.length; i++)
            facs.push({id: facID[i], name: facName[i]});

          console.log(facs);
          
        return(
        <div style={{ margin: "0 100px" }}>
          <AssetCard
            sectionName={"Novo edifício"}
            sectionDescription={"Formulário para cadastro de localidades"}
            handleCardButton={() => console.log('Handle Card')}
            buttonName={"Botão"}
            isForm={true}
          >
            <Form className="form-horizontal">
              <FormGroup row>
                <Col xs={'8'}>
                  <FormGroup>
                    <Label htmlFor="facilities-name">Nome do espaço</Label>
                    <Input type="text" id="facilities-name" placeholder="Digite o nome do local ..." />
                  </FormGroup>
                </Col>
                <Col xs={'4'}>
                  <FormGroup>
                    <Label htmlFor="facilities-code">Código</Label>
                    <Input type="text" id="facilities-code" placeholder="Digite o código do endereçamento ..." />
                  </FormGroup>
                </Col>
              </FormGroup>
              <FormGroup>
                <Label htmlFor="description">Descrição</Label>
                <Input type="textarea" id="description" placeholder="Descrição do edifício ..." rows="4" />
              </FormGroup>
              <FormGroup row>
                <Col xs={'8'}>
                  <FormGroup>
                    <SingleInputWithDropDown
                      label={'Ativo pai'}
                      placeholder="Nível superior da localização ..."
                      listDropdown={facs}
                    />
                  </FormGroup>
                </Col>
                <Col xs={'4'}>
                  <FormGroup>
                    <Label htmlFor="area">Área (m²)</Label>
                    <Input type="text" id="area" placeholder="Área total ..." />
                  </FormGroup>
                </Col>
              </FormGroup>
              <FormGroup row>
                <Col xs={'8'}>
                  <InputWithDropdown
                    label={'Departamentos'}
                    placeholder={'Departamentos que utilizam esta área ...'}
                    listDropdown={deps}
                  />
                </Col>
              </FormGroup>
              <FormGroup row>
                {/* <Col xs={'4'}>
                  <FormGroup>
                    <SingleInputWithDropDown
                      label={'Categoria'}
                      placeholder="Categoria ..."
                      listDropdown={category}
                    />
                  </FormGroup>
                </Col> */}
                <Col xs={'4'}>
                  <FormGroup>
                    <Label htmlFor="latitude">Latitude</Label>
                    <Input type="text" id="latitude" placeholder="Latitude ..." />
                  </FormGroup>
                </Col>
                <Col xs={'4'}>
                  <FormGroup>
                    <Label htmlFor="longitude">Longitude</Label>
                    <Input type="text" id="longitude" placeholder="Longitude ..." />
                  </FormGroup>
                </Col>
              </FormGroup>
            </Form>
          </AssetCard>
        </div>
      )}}</Query>
    );
  }
}

export default withRouter(FacilitiesForm);