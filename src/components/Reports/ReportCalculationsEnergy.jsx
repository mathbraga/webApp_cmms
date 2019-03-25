import React, { Component } from "react";
import {
  Card,
  CardBody,
  Col,
  Row,
  Table,
  Badge,
  ButtonDropdown,
  DropdownToggle,
  DropdownItem,
  DropdownMenu,
  CardHeader,
  CardTitle
} from "reactstrap";
import classNames from "classnames";
import DoubleBarChart from "../Charts/DoubleBarChart";
import { queryLastDemands } from "../../utils/queryLastDemands";
import { queryLastDemandsBlue } from "../../utils/queryLastDemandsBlue";
import { bestDemand } from "../../utils/bestDemand";

class ReportCalculationsEnergy extends Component {
  constructor(props) {
    super(props);
    this.state = {
      typeOfResult: "best",
      dropdownOpen: false,
      bestDemandP: "-",
      bestDemandFP: "-",
      bestDemandBlueP: "-",
      bestDemandBlueFP: "-",
      bestDemandGreenP: "-",
      bestDemandGreenFP: "-"
    };
  }

  componentDidMount() {
    queryLastDemands(this.props.dbObject, this.props.consumer).then(
      lastDemands => {
        queryLastDemandsBlue(this.props.dbObject, this.props.consumer).then(
          lastBlueDemands => {
            const lastItems = [];
            const lastBlues = [];
            lastDemands.Items.forEach(item =>
              lastItems.push({
                demandP: item.dmp,
                demandFP: item.dmf,
                usageP: item.kwhp,
                usageFP: item.kwhf,
                type: item.tipo,
                rates: {}
              })
            );
            lastBlueDemands.Items.slice(0, 13).forEach(item =>
              lastBlues.push({
                demandP: item.dmp,
                demandFP: item.dmf,
                type: item.tipo
              })
            );
            const results = bestDemand(lastItems, lastBlues);
            const bestResult =
              results[0].value <= results[1].value ? results[0] : results[1];

            this.setState({
              bestDemandP: bestResult.dp || "-",
              bestDemandFP: bestResult.df || "-",
              bestDemandBlueP: results[0].dp || "-",
              bestDemandBlueFP: results[0].df || "-",
              bestDemandGreenP: results[1].dp || "-",
              bestDemandGreenFP: results[1].df || "-"
            });
          }
        );
      }
    );
  }

  toggle = () => {
    const newState = !this.state.dropdownOpen;
    this.setState({
      dropdownOpen: newState
    });
  };

  showCalcResult = type => {
    const func = () => {
      this.setState({ typeOfResult: type });
    };
    return func;
  };

  render() {
    console.log("Calculation:");
    console.log(this.state);
    console.log(this.props);
    return (
      <Card>
        <CardHeader>
          <Row>
            <Col md="5">
              <div className="calc-title">Demanda Ideal</div>
              <div className="calc-subtitle">
                Mês do Cálculo: <strong>{this.props.date}</strong>
              </div>
            </Col>
            <Col md="7">
              <Row className="center-button-container">
                <p className="button-calc">Modalidade:</p>
                <ButtonDropdown
                  isOpen={this.state.dropdownOpen}
                  toggle={() => {
                    this.toggle();
                  }}
                >
                  <DropdownToggle caret size="sm">
                    {this.state.typeOfResult === "best"
                      ? "Melhor Resultado"
                      : this.state.typeOfResult === "blue"
                      ? "Modalidade Azul"
                      : "Modalidade Verde"}
                  </DropdownToggle>
                  <DropdownMenu>
                    <DropdownItem onClick={this.showCalcResult("best")}>
                      Melhor Resultado
                    </DropdownItem>
                    <DropdownItem onClick={this.showCalcResult("blue")}>
                      Modalidade Azul
                    </DropdownItem>
                    <DropdownItem onClick={this.showCalcResult("green")}>
                      Modalidade Verde
                    </DropdownItem>
                  </DropdownMenu>
                </ButtonDropdown>
              </Row>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
          <Row>
            <Col md="6">
              <div className="container-demand">
                <div className="demand-new">
                  {this.state.typeOfResult === "best"
                    ? this.state.bestDemandFP
                    : this.state.typeOfResult === "blue"
                    ? this.state.bestDemandBlueFP
                    : this.state.bestDemandGreenFP}
                  kW
                </div>
                <div className="demand-subtitle">
                  <strong>Fora Ponta</strong> - Valor Ideal
                </div>
              </div>
            </Col>
            <Col md="6">
              <div className="container-demand">
                <div className="demand-new">
                  {this.state.typeOfResult === "best"
                    ? this.state.bestDemandP
                    : this.state.typeOfResult === "blue"
                    ? this.state.bestDemandBlueP
                    : this.state.bestDemandGreenP}
                  kW
                </div>
                <div className="demand-subtitle">
                  <strong>Ponta</strong> - Valor Ideal
                </div>
              </div>
            </Col>
          </Row>
          <Row>
            <Col md="6">
              <div className="container-old-demand">
                <div className="demand-value">
                  {this.props.demandContract.dcf.N} kW
                </div>
                <div className="demand-subtitle">
                  <strong>Fora Ponta</strong> - Valor Contratado
                </div>
              </div>
            </Col>
            <Col md="6">
              <div className="container-old-demand">
                <div className="demand-value">
                  {this.props.demandContract.dcp.N} kW
                </div>
                <div className="demand-subtitle">
                  <strong>Ponta</strong> - Valor Contratado
                </div>
              </div>
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default ReportCalculationsEnergy;
