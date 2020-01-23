import React, { Component } from 'react';
import {
  Label,
  Input,
  FormGroup,
  Form,
  Col,
  Row,
  CustomInput
} from 'reactstrap';
import AssetCard from '../../components/Cards/AssetCard';

import "./AssetForm.css";

class AssetForm extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
      <div style={{ margin: "0 100px" }}>
        <AssetCard
          sectionName={"Novo equipamento"}
          sectionDescription={"Formulário para cadastro de equipamentos"}
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
                <FormGroup>
                  <Label htmlFor="department">Departamentos</Label>
                  <Input type="text" id="department" placeholder="Departamentos que utilizam esta área ..." />
                </FormGroup>
              </Col>
            </FormGroup>
            <FormGroup row>
              <Col xs={'4'}>
                <FormGroup>
                  <Label htmlFor="visit">Visitação</Label>
                  <CustomInput type="switch" id="visit" label="Local utilizado pela Visitação Institucional" />
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

export default AssetForm;