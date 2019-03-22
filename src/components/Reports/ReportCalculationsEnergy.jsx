import React, { Component } from "react";
import {
  Card,
  CardBody,
  Col,
  Row,
  Table,
  Badge,
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
      bestDemandP: "-",
      bestDemandFP: "-"
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
              bestDemandFP: bestResult.df || "-"
            });
          }
        );
      }
    );
  }

  render() {
    console.log("Calculation:");
    console.log(this.props.data);
    return (
      <Card>
        <CardHeader>
          <i className="fa fa-align-justify" /> <strong>Cálculos</strong>
        </CardHeader>
        <CardBody>
          <CardTitle>
            <div className="calc-title">Demanda Ideal</div>
            <div className="calc-subtitle">
              Mês do Cálculo: <strong>{this.props.date}</strong>
            </div>
          </CardTitle>
          <Row>
            <Col md="6">
              <div className="container-demand">
                <div className="demand-new">{this.state.bestDemandFP} kW</div>
                <div className="demand-subtitle">
                  <strong>Fora Ponta</strong> - Valor Ideal
                </div>
              </div>
            </Col>
            <Col md="6">
              <div className="container-demand">
                <div className="demand-new">{this.state.bestDemandP} kW</div>
                <div className="demand-subtitle">
                  <strong>Ponta</strong> - Valor Ideal
                </div>
              </div>
            </Col>
          </Row>
          <Row>
            <Col md="6">
              <div className="container-old-demand">
                <div className="demand-value">{this.props.data.dcf.N} kW</div>
                <div className="demand-subtitle">
                  <strong>Fora Ponta</strong> - Valor Contratado
                </div>
              </div>
            </Col>
            <Col md="6">
              <div className="container-old-demand">
                <div className="demand-value">{this.props.data.dcp.N} kW</div>
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
