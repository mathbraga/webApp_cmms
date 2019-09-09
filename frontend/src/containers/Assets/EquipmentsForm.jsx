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

const assets = [
  { id: 'BL14-001-001', name: 'Bloco 14 - Pavimento 01' },
  { id: 'BL14-002-001', name: 'Bloco 14 - Pavimento 02' },
  { id: 'ANX2-001-001', name: 'Anexo 2 - Rui Barbosa' },
  { id: 'ANX2-002-001', name: 'Anexo 2 - Petrônio Portela' },
  { id: 'ANX2-003-001', name: 'Anexo 2 - Auditório' },
  { id: 'ANX1-001-001', name: 'Anexo 1 - Pavimento 01' },
  { id: 'ANX1-002-001', name: 'Anexo 1 - Pavimento 02' },
  { id: 'ANX1-003-001', name: 'Anexo 1 - Pavimento 03' },
  { id: 'ANX1-004-001', name: 'Anexo 1 - Pavimento 04' },
  { id: 'ACAT-010-019', name: 'Ar condicionado - Midea' },
  { id: 'ACAT-010-020', name: 'Ar condicionado - Carrier' },
  { id: 'ACAT-010-021', name: 'Ar condicionado - MGX12' },
  { id: 'ACAT-010-022', name: 'Ar condicionado - Split' },
  { id: 'QDEN-052-022', name: 'Quadro de Energia Elétrica' },
  { id: 'QDEN-015-045', name: 'Quadro de Energia Elétrica' },
  { id: 'QDEN-035-078', name: 'Quadro de Energia Elétrica' },
  { id: 'GMG1-001-000', name: 'Grupo Motor Gerador' },
  { id: 'GMG1-001-004', name: 'Motor do Grupo Motor Gerador' },
  { id: 'GMG1-001-005', name: 'Gerador do Grupo Motor Gerador' },
];

class EquipmentsForm extends Component {
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
                  <Label htmlFor="equipment-name">Nome do equipamento</Label>
                  <Input type="text" id="equipment-name" placeholder="Digite o nome do equipamento" />
                </FormGroup>
              </Col>
              <Col xs={'4'}>
                <FormGroup>
                  <Label htmlFor="equipment-code">Código</Label>
                  <Input type="text" id="equipment-code" placeholder="Digite o código do equipamento" />
                </FormGroup>
              </Col>
            </FormGroup>
            <FormGroup>
              <Label htmlFor="description">Descrição</Label>
              <Input type="textarea" id="description" placeholder="Descrição do equipamento" rows="4" />
            </FormGroup>
            <FormGroup row>
              <Col xs={'8'}>
                <FormGroup>
                  <SingleInputWithDropDown
                    label={'Ativo pai'}
                    placeholder="Nível superior do equipamento (outro equipamento ou localização)"
                    listDropdown={assets}
                  />
                </FormGroup>
              </Col>
              <Col xs={'4'}>
                <FormGroup>
                  <Label htmlFor="price">Preço (R$)</Label>
                  <Input type="text" id="area" placeholder="Preço de aquisição" />
                </FormGroup>
              </Col>
            </FormGroup>
            <FormGroup row>
              <Col xs={'4'}>
                <FormGroup>
                  <Label htmlFor="manufacturer">Fabricante</Label>
                  <Input type="text" id="manufacturer" placeholder="Empresa fabricante" />
                </FormGroup>
              </Col>
              <Col xs={'4'}>
                <FormGroup>
                  <Label htmlFor="model">Modelo</Label>
                  <Input type="text" id="model" placeholder="Modelo" />
                </FormGroup>
              </Col>
              <Col xs={'4'}>
                <FormGroup>
                  <Label htmlFor="serial-num">Número serial</Label>
                  <Input type="text" id="serial-num" placeholder="Número serial" />
                </FormGroup>
              </Col>
            </FormGroup>
          </Form>
        </AssetCard>
      </div>
    );
  }
}

export default EquipmentsForm;