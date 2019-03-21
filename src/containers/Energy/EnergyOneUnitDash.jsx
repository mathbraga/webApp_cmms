import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col, Button } from "reactstrap";
import WidgetEnergyUsage from "../../components/Widgets/WidgetEnergyUsage";
import WidgetEnergyDemand from "../../components/Widgets/WidgetEnergyDemand";
import WidgetEnergyProblem from "../../components/Widgets/WidgetEnergyProblem";
import ReportEnergyOneUnit from "../../components/Reports/ReportEnergyOneUnit";
import ReportInfoEnergy from "../../components/Reports/ReportInfoEnergy";
import ReportCalculationsEnergy from "../../components/Reports/ReportCalculationsEnergy";
import { queryEnergyTable } from "../../utils/queryEnergyTable";

const monthList = {
  "01": "Jan",
  "02": "Fev",
  "03": "Mar",
  "04": "Abr",
  "05": "Mai",
  "06": "Jun",
  "07": "Jul",
  "08": "Ago",
  "09": "Set",
  "10": "Out",
  "11": "Nov",
  "12": "Dez"
};

class EnergyOneUnitDash extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    // if (this.props.result1.Items[0].tipo === 1) {
    //   this.props.result1.Items[0].dcf = this.props.result1.Items[0].dc;
    //   this.props.result1.Items[0].dcp = 0;
    // }
    // console.log(this.props.result2.Items[0]);

    return <div>Hey!</div>;

    {
      /*
      <Card>
        <CardHeader>
          <Row>
            <Col md="6">
              <div className="widget-title dash-title">
                <h4>{this.props.result2.Items[0].idceb.S}</h4>
                <div className="dash-subtitle">
                  Medidor: <strong>{this.props.result2.Items[0].nome.S}</strong>
                </div>
              </div>
              <div className="widget-container-center">
                <div className="dash-title-info">
                  Período: <strong>{this.dateString}</strong>
                </div>
                <div className="dash-title-info">
                  Ligação:{" "}
                  <strong>{this.props.result2.Items[0].modtar.S}</strong>
                </div>
              </div>
            </Col>
            <Col md="4" />
            <Col md="2" className="container-left">
              <Button
                block
                outline
                color="primary"
                onClick={this.props.handleClick}
              >
                <i className="cui-magnifying-glass" />
                &nbsp;Nova Pesquisa
              </Button>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
          <Row>
            <Col md="3">
              <WidgetEnergyUsage data={this.props.result1.Items[0]} />
            </Col>
            <Col md="6">
              <WidgetEnergyDemand data={this.props.result1.Items[0]} />
            </Col>
            <Col md="3">
              <WidgetEnergyProblem data={this.props.result1.Items[0]} />
            </Col>
          </Row>
          <Row>
            <Col md="6">
              <ReportInfoEnergy data={this.props.result2.Items[0]} />
            </Col>
            <Col md="6">
              <ReportCalculationsEnergy
                dbObject={this.props.dbObject}
                consumer={this.props.consumer}
                date={this.dateString}
                data={this.props.result2.Items[0]}
              />
            </Col>
          </Row>
          <Row>
            <Col>
              <ReportEnergyOneUnit
                data={this.props.result1.Items[0]}
                dateString={this.dateString}
              />
            </Col>
          </Row>
        </CardBody>
      </Card>

       <div>
        <Card>
          <CardHeader>
            <Row>
              <Col md="6">
                <div className="widget-title dash-title">
                  <h4>{this.state.queryResponse.Items[0].idceb.S}</h4>
                  <div className="dash-subtitle">Medidor: Unidades de Apoio</div>
                </div>
                <div className="widget-container-center">
                  <div className="dash-title-info">
                    Período: <strong>Jan/2018</strong>
                  </div>
                  <div className="dash-title-info">
                    Ligação: <strong>VERDE</strong>
                  </div>
                </div>
              </Col>
              <Col md="6" className="container-left">
                <Button color="ghost-primary" onClick={this.props.handleClick}>
                  <i className="cui-magnifying-glass" />
                  &nbsp;Nova Pesquisa
                </Button>
              </Col>
            </Row>
          </CardHeader>
          <CardBody>
            <Row>
              <Col md="3">
                <WidgetEnergyUsage />
              </Col>
              <Col md="6">
                <WidgetEnergyDemand />
              </Col>
              <Col md="3">
                <WidgetEnergyProblem />
              </Col>
            </Row>
            <Row>
              <Col md="6">
                <ReportInfoEnergy meters={this.props.EnergyState}/>
              </Col>
              <Col md="6">
                <ReportCalculationsEnergy />
              </Col>
            </Row>
            <Row>
              <Col>
                <ReportEnergyOneUnit energyState={this.props.energyState}/>
              </Col>
            </Row>
          </CardBody>
        </Card>
      </div> */
    }
  }
}

export default EnergyOneUnitDash;
