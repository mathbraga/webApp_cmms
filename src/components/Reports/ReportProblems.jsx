import React, { Component } from "react";
import {
  Card,
  CardBody,
  Col,
  Row,
  Button,
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
  Table
} from "reactstrap";

const rowNames = {









  dcontratadaP: {
    name: "Demanda contratada - Ponta",
    obs: "Maior que zero somente na modalidade tarifária Azul. Igual a zero nos outros casos.",
    expected: "≥ 0 kW"
  },
  dcontratadaFP: {
    name: "Demanda contratada - Fora de ponta",
    obs: "Igual a zero somente no contratada junto à CEB Distribuição.",
    expected: "≥ 0 kW"
  },
  dmedidaP: {
    name: "Demanda medida - Ponta",
    obs: "Demanda medida pela CEB.",
    expected: "> 0 kW"
  },
  dmedidaFP: {
    name: "Demanda medida - Fora de ponta",
    obs: "Demanda medida pela CEB.",
    expected: "> 0 kW"
  },
  dfaturadaP: {
    name: "Demanda Faturada Ponta",
    obs: "Demanda faturada pela CEB.",
    expected: false
  },
  dfaturadaFP: {
    name: "Demanda faturada - Fora de ponta",
    obs: "Demanda faturada pela CEB.",
    expected: false
  },
  ultrap: {
    name: "Custo da ultrapassagem de demanda - Ponta",
    obs: "Valor da demanda medida que excedeu a demanda contratada.",
    expected: "0 kW"
  },
  erex: {
    name: "EREX",
    obs: "Energia reativa excedente",
    expected: "Zero" },
  multa: {
    name: "Multas, juros e atualização monetária",
    obs: "O valor inclui multas, juros e atualização monetária decorrentes de atraso no pagamento de faturas anteriores",
    expected: "R$ 0,00"
  },
  compensacao: {
    name: "Descontos e compensações",
    obs: "Total de descontos e compensações devido a baixos indicadores de qualidade do serviço, conforme normas da ANEEL, ou correções de valores cobrados indevidamente em faturas anteriores",
    expected: "R$ 0,00"
  }
};

class ReportProblems extends Component {
  state = {};
  render() {
    return (
      <Modal
        isOpen={this.props.isOpen}
        toggle={this.props.toggle}
        className={this.props.className}
      >
        <ModalHeader toggle={this.props.toggle}>
          Diagnóstico
        </ModalHeader>
        <ModalBody>
          <Table bordered>
            <thead>
              <tr>
                <th>Parâmetro</th>
                <th>Valor registrado</th>
                <th>Faixa de normalidade</th>
                <th>Observações</th>
              </tr>
            </thead>
            <tbody>
              {Object.keys(rowNames).map(row => (
                <tr>
                  <th scope="row">{rowNames[row].name}</th>
                  <td>
                    {this.props.problems && this.props.problems[row].value}
                  </td>
                  <td>{rowNames[row].expected}</td>
                  <td>{rowNames[row].obs}</td>
                </tr>
              ))}
            </tbody>
          </Table>
        </ModalBody>
        <ModalFooter>
          <Button color="secondary" onClick={this.props.toggle}>
            Fechar
          </Button>
        </ModalFooter>
      </Modal>
    );
  }
}

export default ReportProblems;
