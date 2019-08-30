import React, { Component } from 'react';
import {
  Label,
  Input,
  FormGroup,
  Form,
  Col
} from 'reactstrap';

import AssetCard from '../../components/Cards/AssetCard'
import InputWithDropdown from '../../components/Forms/InputWithDropdown';

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

class FacilitiesForm extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
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
                  <Label htmlFor="parent-asset">Ativo pai</Label>
                  <Input type="text" id="parent-asset" placeholder="Nível superior da localização ..." />
                </FormGroup>
              </Col>
              <Col xs={'4'}>
                <FormGroup>
                  <Label htmlFor="area">Área</Label>
                  <Input type="text" id="area" placeholder="Área total ..." />
                </FormGroup>
              </Col>
            </FormGroup>
            <FormGroup row>
              <Col xs={'8'}>
                <InputWithDropdown
                  label={'Departamentos'}
                  placeholder={'Departamentos que utilizam esta área ...'}
                  listDropdown={departments}
                />
              </Col>
            </FormGroup>
            <FormGroup row>
              <Col xs={'4'}>
                <FormGroup>
                  <Label htmlFor="latitude">Categoria</Label>
                  <Input type="text" id="latitude" placeholder="Categoria ..." />
                </FormGroup>
              </Col>
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
    );
  }
}

export default FacilitiesForm;
