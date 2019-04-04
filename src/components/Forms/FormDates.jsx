import React, { Component } from "react";
import { Card, CardHeader, CardBody, Row, Col, Label, Input, FormGroup, Button } from "reactstrap";

class FormDates extends Component {
  render() {
    return (
      <Card>
        <CardHeader>
          <strong>Pesquisar período</strong>
          <inline>
            <em style={{ "color": "grey" }}>&nbsp;&nbsp;&nbsp;&nbsp;Dados desde 01/2017</em>
          </inline>
        </CardHeader>
        <CardBody>
          
          <Row>

            <Col xs="auto">
              <Label htmlFor="initialDate" sm="auto">
                <strong>Mês inicial:</strong>
              </Label>
            </Col>

            <Col xs="auto">
              <Input
                className="date-input"
                name="initialDate"
                id="initialDate"
                type="text"
                placeholder="mm/aaaa"
                value={this.props.initialDate}
                required
                onChange={this.props.onChangeDate}
              />
            </Col>

            <Col sm="auto">
              <Label htmlFor="finalDate" sm="auto">
                <strong>Mês final:</strong>
              </Label>
            </Col>

            <Col sm="auto">
              {!this.props.oneMonth ? (
                <Input
                  className="date-input"
                  type="text"
                  name="finalDate"
                  id="finalDate"
                  placeholder="mm/aaaa"
                  value={this.props.finalDate}
                  required
                  onChange={this.props.onChangeDate}
                />
              ) : (
                <Input
                  className="date-input"
                  type="text"
                  name="finalDate"
                  id="finalDate"
                  placeholder="mm/aaaa"
                  value={this.props.finalDate}
                  required
                  onChange={this.props.onChangeDate}
                  disabled
                />
              )}
            </Col>

            </Row>


            <Row>
            <Col xs={{ size: 6, offset: 3 }}>
              <FormGroup check className="checkbox">
                <Input
                  className="form-check-input"
                  type="checkbox"
                  id="oneMonth"
                  name="oneMonth"
                  value={1}
                  onChange={this.props.onChangeOneMonth}
                />
                <Label check className="form-check-label" htmlFor="oneMonth">
                  Somente um mês
                </Label>
              </FormGroup>
            </Col>
          </Row>
          

          <Row>
            <Col sm="auto">
              <Label htmlFor="finalDate" sm={{ size: "auto", offset: 0 }}>
                <strong>Medidor:</strong>
              </Label>
            </Col>

            <Col sm="auto">
              <Input
                type="select"
                name="chosenMeter"
                id="exampleSelect"
                onChange={this.props.onMeterChange}
              >
                <option value="199">Todos os medidores</option>
                {this.props.meters.map(meter => (
                  <option
                    key={(100*parseInt(meter.tipomed.N, 10) + parseInt(meter.med.N, 10)).toString()}
                    value={(100*parseInt(meter.tipomed.N, 10) + parseInt(meter.med.N, 10)).toString()}>
                    {meter.idceb.S + " - " + meter.nome.S}
                  </option>
                ))}
              </Input>
            </Col>

          </Row>

          <Row>

            <Col xs="auto">
              <Button
                className=""
                type="submit"
                size="md"
                color="primary"
                onClick={this.props.onQuery}
              >Pesquisar
              </Button>
            </Col>
          </Row>



        </CardBody>
      </Card>
    );
  }
}

export default FormDates;
