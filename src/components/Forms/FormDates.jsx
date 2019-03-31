import React, { Component } from "react";
import { Card, CardHeader, CardBody, Col, Label, Input, FormGroup, Button } from "reactstrap";

class FormDates extends Component {
  render() {
    return (
      <Card>
        <CardHeader>
          <strong>Período de consumo</strong>
        </CardHeader>
        <CardBody>
          <FormGroup row>
            <Label htmlFor="initialDate" sm={"auto"}>
              <strong>Mês inicial:</strong>
            </Label>
            <Col sm={2}>
              <Input
                name="initialDate"
                id="initialDate"
                type="text"
                placeholder="mm/aaaa"
                value={this.props.initialDate}
                required
                onChange={this.props.onChangeDate}
              />
            </Col>
            <Label htmlFor="finalDate" sm={"auto"}>
              <strong>Mês final:</strong>
            </Label>
            <Col sm={2}>
              {!this.props.oneMonth ? (
                <Input
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
            <Label htmlFor="finalDate" sm={{ size: "auto", offset: 0 }}>
              <strong>Medidor:</strong>
            </Label>
            <Col sm={3.5}>
              <Input
                type="select"
                name="chosenMeter"
                id="exampleSelect"
                onChange={this.props.onMeterChange}
              >
                <option value="199">Todos os medidores</option>
                {this.props.meters.map(meter => (
                  <option
                    key={(100*parseInt(meter.medtype.N, 10) + parseInt(meter.med.N, 10)).toString()}
                    value={(100*parseInt(meter.medtype.N, 10) + parseInt(meter.med.N, 10)).toString()}>
                    {meter.idceb.S + " - " + meter.nome.S}
                  </option>
                ))}
              </Input>
            </Col>
            <Col>
              <Button
                type="submit"
                size="md"
                color="primary"
                onClick={this.props.onQuery}
              >Pesquisar
              </Button>
            </Col>
          </FormGroup>
          <FormGroup row>
            <Col md="3">
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
                  Pesquisar somente um mês
                </Label>
              </FormGroup>
            </Col>
          </FormGroup>
        </CardBody>
      </Card>
    );
  }
}

export default FormDates;
