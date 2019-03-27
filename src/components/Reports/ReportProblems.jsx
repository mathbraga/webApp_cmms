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
    name: "Demanda Contratada Ponta",
    obs: "Demanda contratada junto à CEB Distribuição.",
    expected: "> 0 kW"
  },
  dcontratadaFP: {
    name: "Demanda Contratada Fora de Ponta",
    obs: "Demanda contratada junto à CEB Distribuição.",
    expected: "> 0 kW"
  },
  dmedidaP: {
    name: "Demanda Medida Ponta",
    obs: "Demanda medida pela CEB.",
    expected: "> 0 kW"
  },
  dmedidaFP: {
    name: "Demanda Medida Fora de Ponta",
    obs: "Demanda medida pela CEB.",
    expected: "> 0 kW"
  },
  dfaturadaP: {
    name: "Demanda Faturada Ponta",
    obs: "Demanda faturada pela CEB.",
    expected: false
  },
  dfaturadaFP: {
    name: "Demanda Faturada Fora de Ponta",
    obs: "Demanda faturada pela CEB.",
    expected: false
  },
  ultrap: {
    name: "Ultrapassagem de Demanda",
    obs: "Valor da demanda medida que excedeu a demanda contratada.",
    expected: "0 kW"
  },
  erex: { name: "EREX", obs: "Energia Reativa Excedente", expected: "Zero" },
  multa: {
    name: "Multas e Juros",
    obs: "Multas e juros por atraso no pagamento.",
    expected: "R$ 0,00"
  },
  compensacao: {
    name: "Compensação",
    obs:
      "Desconto financeiro por violação às regras relativas aos indicadores de qualidade.",
    expected: "R$ 0,00"
  }
};

class ReportProblems extends Component {
  state = {};
  render() {
    console.log("ReportProblems:");
    console.log(this.props.problems);
    return (
      <Modal
        isOpen={this.props.isOpen}
        toggle={this.props.toggle}
        className={this.props.className}
      >
        <ModalHeader toggle={this.props.toggle}>
          Diagnóstico de Problemas
        </ModalHeader>
        <ModalBody>
          <Table bordered>
            <thead>
              <tr>
                <th>Parâmetros</th>
                <th>Valor Utilizado</th>
                <th>Valor esperado</th>
                <th>Observação</th>
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
