import React, { Component } from "react";
import { formatNumber } from "../../utils/formatText";
import {
  transformDateString,
  dateWithFourDigits
} from "../../utils/transformDateString";
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
import BadgeWithTooltips from "../Badges/BadgeWithTooltips";

class ReportProblems extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    let initialDate = transformDateString(
      dateWithFourDigits(this.props.initialDate)
    );
    let finalDate = transformDateString(
      dateWithFourDigits(this.props.finalDate)
    );

    let rowNames = {
      dcp: {
        name: "Demanda contratada - Ponta",
        unit: "kW",
        obs:
          "Maior que zero somente na modalidade tarifária horária Azul. Igual a zero nos outros casos.",
        expected: "≥ 0 kW"
      },
      dcf: {
        name: "Demanda contratada - Fora de ponta",
        unit: "kW",
        obs: "Igual a zero somente na modalidade tarirária convencional",
        expected: "≥ 0 kW"
      },
      dmp: {
        name: "Demanda medida - Ponta",
        unit: "kW",
        obs: "Maior demanda de potência ativa registrada no período - Ponta",
        expected: "≤ Demanda contratada (Ponta)"
      },
      dmf: {
        name: "Demanda medida - Fora de ponta",
        unit: "kW",
        obs:
          "Maior demanda de potência ativa registrada no período - Fora de ponta",
        expected: "≤ Demanda contratada (Fora de ponta)"
      },
      dfp: {
        name: "Demanda faturada - Ponta",
        unit: "kW",
        obs:
          "Demanda considerada no faturamento (maior valor entre medida e contratada) - Ponta",
        expected: "≤ Demanda contratada (Ponta)"
      },
      dff: {
        name: "Demanda faturada - Fora de ponta",
        unit: "kW",
        obs:
          "Demanda considerada no faturamento (maior valor entre medida e contratada) - Fora de ponta",
        expected: "≤ Demanda contratada (Fora de ponta)"
      },

      vudp: {
        name: "Custo da ultrapassagem de demanda - Ponta",
        unit: "R$",
        obs:
          "Valor adicional em caso de demanda medida superior à demanda contratada",
        expected: "= R$ 0,00"
      },

      vudf: {
        name: "Custo da ultrapassagem de demanda - Fora de ponta",
        unit: "R$",
        obs:
          "Valor adicional em caso de demanda medida superior à demanda contratada",
        expected: "= R$ 0,00"
      },

      verexp: {
        name: "Custo do EREX - Ponta",
        unit: "R$",
        obs:
          "Valor adicional em caso de excedentes de energia reativa (fator de potência inferior a 0,92)",
        expected: "= R$ 0,00"
      },

      verexf: {
        name: "Custo do EREX - Fora de ponta",
        unit: "R$",
        obs:
          "Valor adicional em caso de excedentes de energia reativa (fator de potência inferior a 0,92)",
        expected: "= R$ 0,00"
      },

      jma: {
        name: "Multas, juros e atualização monetária",
        unit: "R$",
        obs:
          "Valores adicionais decorrentes do atraso no pagamento de faturas anteriores",
        expected: "= R$ 0,00"
      },
      desc: {
        name: "Descontos e compensações",
        unit: "R$",
        obs:
          "Total de descontos e compensações devido a baixos indicadores de qualidade do serviço, conforme normas da ANEEL, ou correções de valores cobrados indevidamente em faturas anteriores",
        expected: "= R$ 0,00"
      }
    };

    return (
      <Modal
        isOpen={this.props.isOpen}
        toggle={this.props.toggle}
        className={this.props.className}
      >
        <ModalHeader toggle={this.props.toggle}>
          {/* Verificação de problemas
          {" - " + this.props.chosenMeter}
          {" - " + this.props.initialDate} */}

          <Row>
            <Col md="12">
              <div className="widget-title dash-title">
                <h4>
                  {this.props.allUnits
                    ? "Energia Elétrica"
                    : this.props.unitNumber}
                </h4>
                {this.props.allUnits ? (
                  <div className="dash-subtitle">
                    Total: <strong>{this.props.numOfUnits} medidores</strong>
                  </div>
                ) : (
                  <div className="dash-subtitle">
                    Medidor: <strong>{this.props.unitName}</strong>
                  </div>
                )}
              </div>
              <div className="widget-container-center">
                {!this.props.oneMonth ? (
                  <div className="dash-title-info">
                    Período:{" "}
                    <strong>
                      {initialDate}
                      {" - "}
                      {finalDate}
                    </strong>
                  </div>
                ) : (
                  <div className="dash-title-info">
                    Período: <strong>{initialDate}</strong>
                  </div>
                )}
                {this.props.allUnits ? (
                  <div className="dash-title-info">
                    Várias modalidades tarifárias
                  </div>
                ) : (
                  <div className="dash-title-info">
                    Modalidade: <strong>{this.props.typeOfUnit}</strong>
                  </div>
                )}
              </div>
            </Col>
            {/* <Col md="4" />
            <Col md="2" className="container-left">
              <Button block outline color="primary" onClick={handleNewSearch}>
                <i className="cui-magnifying-glass" />
                &nbsp;Nova pesquisa
              </Button>
            </Col> */}
          </Row>
        </ModalHeader>
        <ModalBody style={{ overflow: "scroll" }}>
          <Table bordered>
            <thead>
              <tr>
                <th style={{ "text-align": "center" }}>Parâmetro</th>
                <th style={{ "text-align": "center" }}>Valor registrado</th>
                <th style={{ "text-align": "center" }}>Diagnóstico</th>
              </tr>
            </thead>
            <tbody>
              {Object.keys(rowNames).map(row => (
                <tr>
                  <th scope="row">{rowNames[row].name}</th>

                  {rowNames[row].unit === "R$" ? (
                    <td style={{ "text-align": "center" }}>
                      {"R$ "}
                      {this.props.problems &&
                        formatNumber(this.props.problems[row].value)}
                    </td>
                  ) : (
                    <td style={{ "text-align": "center" }}>
                      {this.props.problems &&
                        formatNumber(this.props.problems[row].value, 0)}
                      {" " + rowNames[row].unit}
                    </td>
                  )}

                  <td style={{ "text-align": "center" }}>
                    {this.props.problems && this.props.problems[row].problem ? (
                      <BadgeWithTooltips
                        color="danger"
                        id={row}
                        situation="Verificar"
                        name={rowNames[row].name}
                        obs={rowNames[row].obs}
                        expected={rowNames[row].expected}
                        problem={this.props.problems[row]}
                        meters={this.props.meters}
                      />
                    ) : (
                      <BadgeWithTooltips
                        color="success"
                        id={row}
                        situation="OK"
                        name={rowNames[row].name}
                        obs={rowNames[row].obs}
                        expected={rowNames[row].expected}
                        problem={this.props.problems[row]}
                        meters={this.props.meters}
                      />
                    )}
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
