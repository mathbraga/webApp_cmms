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
  Table,
  Badge,
  Popover,
  PopoverHeader,
  PopoverBody
} from "reactstrap";

const rowNames = {
  dcp: {
    name: "Demanda contratada - Ponta",
    obs: "Maior que zero somente na modalidade tarifária horária Azul. Igual a zero nos outros casos.",
    expected: "≥ 0 kW"
  },
  dcf: {
    name: "Demanda contratada - Fora de ponta",
    obs: "Igual a zero somente na modalidade tarirária convencional",
    expected: "≥ 0 kW"
  },
  dmp: {
    name: "Demanda medida - Ponta",
    obs: "Maior demanda de potência ativa registrada no período - Ponta",
    expected: "≤ Demanda contratada (Ponta)"
  },
  dmf: {
    name: "Demanda medida - Fora de ponta",
    obs: "Maior demanda de potência ativa registrada no período - Fora de ponta",
    expected: "≤ Demanda contratada (Fora de ponta)"
  },
  dfp: {
    name: "Demanda faturada - Ponta",
    obs: "Demanda considerada no faturamento (maior valor entre medida e contratada) - Ponta",
    expected: "≤ Demanda contratada (Ponta)"
  },
  dff: {
    name: "Demanda faturada - Fora de ponta",
    obs: "Demanda considerada no faturamento (maior valor entre medida e contratada) - Fora de ponta",
    expected: "≤ Demanda contratada (Fora de ponta)"
  },

  vudp: {
    name: "Custo da ultrapassagem de demanda - Ponta",
    obs: "Valor adicional em caso de demanda medida superior à demanda contratada",
    expected: "= R$ 0"
  },

  vudf: {
    name: "Custo da ultrapassagem de demanda - Fora de ponta",
    obs: "Valor adicional em caso de demanda medida superior à demanda contratada",
    expected: "= R$ 0"
  },

  verexp: {
    name: "Custo do EREX - Ponta",
    obs: "Valor adicional em caso de excedentes de energia reativa (fator de potência inferior a 0,92)",
    expected: "= R$ 0" },

  verexf: {
    name: "Custo do EREX - Fora de ponta",
    obs: "Valor adicional em caso de excedentes de energia reativa (fator de potência inferior a 0,92)",
    expected: "= R$ 0" },

  jma: {
    name: "Multas, juros e atualização monetária",
    obs: "Valores adicionais decorrentes do atraso no pagamento de faturas anteriores",
    expected: "= R$ 0"
  },
  desc: {
    name: "Descontos e compensações",
    obs: "Total de descontos e compensações devido a baixos indicadores de qualidade do serviço, conforme normas da ANEEL, ou correções de valores cobrados indevidamente em faturas anteriores",
    expected: "= R$ 0"
  }
};

class ReportProblems extends Component {
  constructor(props){
    super(props);
    this.state = {
      openPopovers: {
        dcp: false,
        dcf: false,
        dmp: false,
        dmf: false,
        dfp: false,
        dff: false,
        vudp: false,
        vudf: false,
        verexp: false,
        verexf: false,
        jma: false,
        desc: false
      }
    }
  }

  togglePO(){
    this.setState(prevState => {
      prevState
    });
  }

  render() {
    return (
      <Modal
        isOpen={this.props.isOpen}
        toggle={this.props.toggle}
        className={this.props.className}
      >
        <ModalHeader toggle={this.props.toggle}>
          Verificação de problemas da fatura
        </ModalHeader>
        <ModalBody>
          <Table bordered>
            <thead>
              <tr>
                <th>Parâmetro</th>
                <th>Valor registrado</th>
                {/* <th>Faixa de normalidade</th>
                <th>Observações</th> */}
                <th>Buttons with popovers</th>
              </tr>
            </thead>
            <tbody>
              {Object.keys(rowNames).map(row => (
                <tr>

                  <th scope="row">{rowNames[row].name}</th>
                  
                  <td>
                    {this.props.problems && this.props.problems[row].value}
                  </td>
                  {/* <td>{rowNames[row].expected}</td>
                  <td>{rowNames[row].obs}</td> */}
                  <td>
                    {this.props.problems && this.props.problems[row].problem
                      ? (
                        <div>
                          <Button id={row} color="danger" type="button">VERIFICAR</Button>
                          {/* <Popover placement="right" isOpen={true} target={row} toggle={""}>
                            <PopoverHeader>Title</PopoverHeader>
                            <PopoverBody>Text</PopoverBody>
                          </Popover> */}
                        </div>
                      )
                      : (
                        <div>
                          <Button id={row} color="success" type="button">OK</Button>
                          {/* <Popover placement="right" isOpen={true} target={row} toggle={""}>
                            <PopoverHeader>Title</PopoverHeader>
                            <PopoverBody>Text</PopoverBody>
                          </Popover> */}
                        </div>
                      )
                    }
                  </td>


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
