import React, { Component } from "react";
import {
  Row,
  Button,
  Modal,
  ModalHeader,
  ModalBody,
  ModalFooter,
  Table
} from "reactstrap";
import BadgeWithTooltips from "../Badges/BadgeWithTooltips";
import formatNumber from "../../utils/consumptionMonitor/formatText";

class ReportProblems extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {

    let {
      allUnits,
      unitName,
      unitNumber,
      numOfUnits,
      rowNamesReportProblems,
      isOpen,
      toggle,
      className,
      oneMonth,
      initialDate,
      finalDate,
      typeOfUnit,
      problems,
      meters,
      chosenMeter
    } = this.props;
    
    return (
      <Modal
        isOpen={isOpen}
        toggle={toggle}
        className={className}
      >
        <ModalHeader toggle={toggle}>
          <Row style={{ padding: "0px 20px" }}>
            <div className="widget-title dash-title">
              <h4>
                {allUnits
                  ? "Energia Elétrica"
                  : unitNumber}
              </h4>
              {allUnits ? (
                <div className="dash-subtitle">
                  Total: <strong>{numOfUnits} medidores</strong>
                </div>
              ) : (
                <div className="dash-subtitle">
                  Medidor: <strong>{unitName}</strong>
                </div>
              )}
            </div>
            <div className="widget-container-center">
              {!oneMonth ? (
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
              {allUnits ? (
                <div className="dash-title-info">
                  Várias modalidades tarifárias
                </div>
              ) : (
                <div className="dash-title-info">
                  Modalidade: <strong>{typeOfUnit}</strong>
                </div>
              )}
            </div>
          </Row>
        </ModalHeader>
        <ModalBody style={{ overflow: "scroll" }}>
          <Table bordered>
            <thead>
              <tr>
                <th style={{ textAlign: "center" }}>Parâmetro</th>
                <th style={{ textAlign: "center" }}>Valor registrado</th>
                <th style={{ textAlign: "center" }}>Diagnóstico</th>
              </tr>
            </thead>
            <tbody>
              {Object.keys(rowNamesReportProblems).map(row => (
                <tr key={row}>
                  <th scope="row">{rowNamesReportProblems[row].name}</th>

                  {rowNamesReportProblems[row].unit === "R$" ? (
                    <td style={{ textAlign: "center" }}>
                      {"R$ "}
                      {problems &&
                        formatNumber(problems[row].value)}
                    </td>
                  ) : (
                    <td style={{ textAlign: "center" }}>
                      {problems &&
                        formatNumber(problems[row].value, 0)}
                      {" " + rowNamesReportProblems[row].unit}
                    </td>
                  )}

                  <td style={{ textAlign: "center" }}>
                    {problems && problems[row].problem ? (
                      <BadgeWithTooltips
                        color="danger"
                        id={row}
                        situation="Verificar"
                        name={rowNamesReportProblems[row].name}
                        obs={rowNamesReportProblems[row].obs}
                        expected={rowNamesReportProblems[row].expected}
                        problem={problems[row]}
                        meters={meters}
                        chosenMeter={chosenMeter}
                      />
                    ) : (
                      <BadgeWithTooltips
                        color="success"
                        id={row}
                        situation="OK"
                        name={rowNamesReportProblems[row].name}
                        obs={rowNamesReportProblems[row].obs}
                        expected={rowNamesReportProblems[row].expected}
                        problem={problems[row]}
                        meters={meters}
                        chosenMeter={chosenMeter}
                      />
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </Table>
        </ModalBody>
        <ModalFooter>
          <Button color="secondary" onClick={toggle}>
            Fechar
          </Button>
        </ModalFooter>
      </Modal>
    );
  }
}

export default ReportProblems;
