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
import SingleInputWithDropDown from '../../components/Forms/SingleInputWithDropdown';

const ORDER_STATUS = [
  { id: 'can', name: 'Cancelado' },
  { id: 'neg', name: 'Negado' },
  { id: 'sus', name: 'Suspenso' },
  { id: 'fil', name: 'Fila de espera' },
  { id: 'exe', name: 'Em execução' },
  { id: 'conc', name: 'Concluído' },
];

const ORDER_PRIORITY = [
  { id: 'bai', name: 'Baixa' },
  { id: 'nor', name: 'Normal' },
  { id: 'alt', name: 'Alta' },
  { id: 'urg', name: 'Urgente' },
];

const ORDER_CATEGORY = [
  { id: 'hid', name: 'Manutenção Hidráulica' },
  { id: 'ele', name: 'Manutenção Elétrica' },
  { id: 'mec', name: 'Manutenção Mecânica' },
  { id: 'civ', name: 'Manutenção Civil' },
  { id: 'ins', name: 'Instalações Elétricas' },
];

const contract = [
  { id: 'CT001-2019', name: 'Contrato para manutenção elétrica - RCS Tecnologia' },
  { id: 'CT002-2019', name: 'Contrato para manutenção hidráulica - RCS Tecnologia' },
  { id: 'CT003-2019', name: 'Contrato para manutenção civil - AWS Soluções' },
  { id: 'CT004-2019', name: 'Contrato para pintura - RCS Tecnologia' },
  { id: 'CT005-2019', name: 'Contrato para impermeabilização - PREFAC' },
  { id: 'CT006-2019', name: 'Contrato para manutenção de elevadores - RCS Tecnologia' },
  { id: 'CT007-2019', name: 'Contrato para manutenção dos geradores - RCS Tecnologia' },
  { id: 'CT008-2019', name: 'Contrato para abastecimento dos Geradores - RCS Tecnologia' },
];

const orders = [
  { id: 'RQ-001', name: 'Troca de torneiras no Gabinete do Senador José Serra.' },
  { id: 'RQ-002', name: 'Conserto de tomadas na cozinha.' },
  { id: 'RQ-003', name: 'Pintura do apartamento funcional.' },
  { id: 'RQ-004', name: 'Fornecimento de filtro de linha.' },
  { id: 'RQ-005', name: 'Limpeza nos filtros do ar-condicionado.' },
  { id: 'OS-001', name: 'Manutenção no grupo motor gerador.' },
  { id: 'OS-002', name: 'Troca de óleo dos motores.' },
  { id: 'OS-003', name: 'Troca das válvulas das bombas.' },
  { id: 'OS-004', name: 'Troca de disjuntores na cozinha.' },
  { id: 'OS-005', name: 'Conserto de tomadas na cozinha.' },
];

class OrderForm extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div style={{ margin: "0 100px" }}>
        <AssetCard
          sectionName={"Nova Ordem de Serviço"}
          sectionDescription={"Formulário para cadastro de ordem de serviço"}
          handleCardButton={() => console.log('Handle Card')}
          buttonName={"Botão"}
          isForm={true}
        >
          <Form className="form-horizontal">
            <FormGroup row>
              <Col xs={'12'}>
                <FormGroup>
                  <Label htmlFor="order-title">Título</Label>
                  <Input type="text" id="order-title" placeholder="Título da ordem de serviço" />
                </FormGroup>
              </Col>
            </FormGroup>
            <FormGroup row>
              <Col xs={'4'}>
                <FormGroup>
                  <SingleInputWithDropDown
                    label={'Status'}
                    placeholder="Situação da OS"
                    listDropdown={ORDER_STATUS}
                  />
                </FormGroup>
              </Col>
              <Col xs={'4'}>
                <FormGroup>
                  <SingleInputWithDropDown
                    label={'Prioridade'}
                    placeholder="Prioridade da OS"
                    listDropdown={ORDER_PRIORITY}
                  />
                </FormGroup>
              </Col>
              <Col xs={'4'}>
                <FormGroup>
                  <SingleInputWithDropDown
                    label={'Categoria'}
                    placeholder="Categoria da OS"
                    listDropdown={ORDER_CATEGORY}
                  />
                </FormGroup>
              </Col>
            </FormGroup>
            <FormGroup row>
              <Col>
                <FormGroup>
                  <Label htmlFor="description">Descrição</Label>
                  <Input type="textarea" id="description" placeholder="Descrição da ordem de serviço" rows="4" />
                </FormGroup>
              </Col>
            </FormGroup>
            <FormGroup row>
              <Col xs={'8'}>
                <FormGroup>
                  <SingleInputWithDropDown
                    label={'OS pai'}
                    placeholder="Nível superior da localização ..."
                    listDropdown={orders}
                  />
                </FormGroup>
              </Col>
            </FormGroup>
          </Form>
        </AssetCard>
      </div>
    );
  }
}

export default OrderForm;