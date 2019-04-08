import React, { Component } from "react";
import {
  transformDateString,
  dateWithFourDigits
} from "../../utils/transformDateString";
import { Card, CardBody, Col, Row, Button, CardHeader } from "reactstrap";

class ResultCard extends Component {
  /*
   * Props:
   *       - allUnits (boolean): if true, it will receive the header for all units
   *       - unitNumber (string): biggest and first text in the header, it'll receive the unit number
   *       - unitName (string): name of this unit
   *       - numOfUnits (number): number of units
   *       - initialDate (date): initial date for the query
   *       - finalDate (date of false): final date for the query
   *       - typeOfUnit ("azul" or "verde"): type of the unit
   *       - handleNewSearch (function): function to handle the click on the new search button
   *
   */

  render() {
    let {
      allUnits,
      unitNumber,
      unitName,
      numOfUnits,
      initialDate,
      finalDate,
      typeOfUnit,
      handleNewSearch,
      oneMonth,
      children
    } = this.props;

    if (initialDate && initialDate.length === 7)
      initialDate = dateWithFourDigits(initialDate);
    if (!oneMonth) finalDate = dateWithFourDigits(finalDate);

    return (
      <Card>
        <CardHeader>
          <Row>
            <Col md="6">
              <div className="widget-title dash-title">
                <h4>{allUnits ? "Energia Elétrica" : unitNumber}</h4>
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
                      {transformDateString(initialDate)}
                      {" - "}
                      {transformDateString(finalDate)}
                    </strong>
                  </div>
                ) : (
                  <div className="dash-title-info">
                    Período: <strong>{transformDateString(initialDate)}</strong>
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
            </Col>
            <Col md="4" />
            <Col md="2" className="container-left">
              <Button block outline color="primary" onClick={handleNewSearch}>
                <i className="cui-magnifying-glass" />
                &nbsp;Nova pesquisa
              </Button>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>{children}</CardBody>
      </Card>
    );
  }
}

export default ResultCard;
