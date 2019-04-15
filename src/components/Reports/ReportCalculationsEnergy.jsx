import React, { Component } from "react";
import { Col, Row } from "reactstrap";
import { queryLastDemands } from "../../utils/queryLastDemands";
import { queryLastDemandsBlue } from "../../utils/queryLastDemandsBlue";
import { bestDemand } from "../../utils/bestDemand";
import { transformDateString } from "../../utils/transformDateString";
import ReportCard from "../Cards/ReportCard";

class ReportCalculationsEnergy extends Component {
  constructor(props) {
    super(props);
    this.state = {
      typeOfResult: "best",
      bestDemandP: "-",
      bestDemandFP: "-",
      bestDemandCost: "-",
      bestDemandBlueP: "-",
      bestDemandBlueFP: "-",
      bestDemandcostBlue: "-",
      bestDemandGreenP: "-",
      bestDemandGreenFP: "-",
      bestDemandcostGreen: "-",
      costNow: "-",
      baseDate: 1201
    };
  }

  componentDidMount() {
    let date = 1201;
    queryLastDemands(this.props.dbObject, this.props.consumer).then(
      lastDemands => {
        queryLastDemandsBlue(this.props.dbObject, this.props.consumer).then(
          lastBlueDemands => {
            const lastItems = [];
            const lastBlues = [];
            lastDemands.Items.forEach(item => {
              date = item.aamm >= date ? item.aamm : date;
              lastItems.push({
                demandP: item.dmp,
                demandFP: item.dmf,
                usageP: item.kwhp,
                usageFP: item.kwhf,
                type: item.tipo,
                rates: {}
              });
            });
            lastBlueDemands.Items.slice(0, 13).forEach(item =>
              lastBlues.push({
                demandP: item.dmp,
                demandFP: item.dmf,
                type: item.tipo
              })
            );
            const results = bestDemand(
              lastItems,
              lastBlues,
              parseInt(this.props.demandContract.dcf.S),
              parseInt(this.props.demandContract.dcp.S)
            );
            const bestResult =
              results[0].value <= results[1].value ? results[0] : results[1];

            this.setState({
              bestDemandP: bestResult.dp || "-",
              bestDemandFP: bestResult.df || "-",
              bestDemandCost: bestResult.value || "-",
              bestDemandBlueP: results[0].dp || "-",
              bestDemandBlueFP: results[0].df || "-",
              bestDemandCostBlue: results[0].value || "-",
              bestDemandGreenP: results[1].dp || "-",
              bestDemandGreenFP: results[1].df || "-",
              bestDemandCostGreen: results[1].value || "-",
              costNow: results[2],
              costTime: results[3],
              baseDate: date
            });
          }
        );
      }
    );
  }

  showCalcResult = type => {
    this.setState({ typeOfResult: type });
  };

  render() {
    let economy =
      this.state.costNow -
      (this.state.typeOfResult === "best"
        ? this.state.bestDemandCost
        : this.state.typeOfResult === "blue"
        ? this.state.bestDemandCostBlue
        : this.state.bestDemandCostGreen);
    economy = economy > 0 ? economy : 0;
    economy = (economy / this.state.costTime) * 12;

    return (
      <ReportCard
        title={"Demanda ideal"}
        titleColSize={6}
        subtitle={"Mês de referência:"}
        subvalue={transformDateString(this.state.baseDate)}
        dropdown
        dropdownTitle={"Cálculo para:"}
        dropdownItems={{
          best: "Melhor resultado",
          blue: "Modalidade Azul",
          green: "Modalide Verde"
        }}
        showCalcResult={this.showCalcResult}
        resultID={this.state.typeOfResult}
      >
        {this.props.type == 0 ? (
          <p style={{ textAlign: "center" }}>
            Não há cálculos para a modalidade convencional.
          </p>
        ) : (
          <>
            <Row>
              <Col>
                <div className="calc-subtitle">
                  Modalidade calculada:{" "}
                  <strong>
                    {this.state.typeOfResult === "best"
                      ? this.state.bestDemandP === "-"
                        ? "Verde"
                        : "Azul"
                      : this.state.typeOfResult === "blue"
                      ? "Azul"
                      : "Verde"}
                  </strong>
                </div>
                <div className="calc-subtitle">
                  Economia simulada:{" "}
                  <strong>
                    {Math.trunc((economy / this.state.costNow) * 100) || "- "}%
                    em 12 meses (aprox. R${" "}
                    {Math.ceil(economy / this.state.costNow / 1000) || "- "}{" "}
                    mil)
                  </strong>
                </div>
              </Col>
            </Row>
            <Row>
              <Col xs="6">
                <div className="container-demand">
                  <div className="demand-new text-truncate">
                    {this.state.typeOfResult === "best"
                      ? this.state.bestDemandFP
                      : this.state.typeOfResult === "blue"
                      ? this.state.bestDemandBlueFP
                      : this.state.bestDemandGreenFP}
                    &nbsp;kW
                  </div>
                  <div className="demand-subtitle">
                    <strong>Fora de ponta</strong> - Valor ideal
                  </div>
                </div>
              </Col>
              <Col xs="6">
                <div className="container-demand">
                  <div className="demand-new text-truncate">
                    {this.state.typeOfResult === "best"
                      ? this.state.bestDemandP
                      : this.state.typeOfResult === "blue"
                      ? this.state.bestDemandBlueP
                      : this.state.bestDemandGreenP}
                    &nbsp;kW
                  </div>
                  <div className="demand-subtitle">
                    <strong>Ponta</strong> - Valor ideal
                  </div>
                </div>
              </Col>
            </Row>
            <Row>
              <Col xs="6">
                <div className="container-old-demand">
                  <div className="demand-value text-truncate">
                    {this.props.demandContract.dcf.S} kW
                  </div>
                  <div className="demand-subtitle">
                    <strong>Fora de ponta</strong> - Valor contratado
                  </div>
                </div>
              </Col>
              <Col xs="6">
                <div className="container-old-demand">
                  <div className="demand-value text-truncate">
                    {this.props.demandContract.dcp.S} kW
                  </div>
                  <div className="demand-subtitle">
                    <strong>Ponta</strong> - Valor contratado
                  </div>
                </div>
              </Col>
            </Row>
          </>
        )}
      </ReportCard>
    );
  }
}

export default ReportCalculationsEnergy;
