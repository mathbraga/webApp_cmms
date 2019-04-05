import React, { Component } from "react";
import {
  Card,
  CardHeader,
  CardBody,
  Row,
  Col,
  Label,
  Input,
  FormGroup,
  Button
} from "reactstrap";

class FormDates extends Component {
  render() {
    return (
      <Card>
        <CardHeader>
          <Row>
            <Col md="12">
              <div className="calc-title">Pesquisar período</div>
              <div className="calc-subtitle">
                <em>Dados desde 01/2017</em>
              </div>
            </Col>
          </Row>
        </CardHeader>
        <CardBody>
          <Row>
            <Col md="3">
              <Label htmlFor="initialDate">
                <strong>Mês inicial:</strong>
              </Label>
            </Col>
            <Col md="3">
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
            <Col md="3">
              <Label htmlFor="finalDate" sm="auto">
                <strong>Mês final:</strong>
              </Label>
            </Col>
            <Col md="3">
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
            <Col sm="4">
              <Label htmlFor="finalDate">
                <strong>Medidor:</strong>
              </Label>
            </Col>

            <Col sm="8">
              <Input
                type="select"
                name="chosenMeter"
                id="exampleSelect"
                onChange={this.props.onMeterChange}
              >
                <option value="199">Todos os medidores</option>
                {this.props.meters.map(meter => (
                  <option
                    key={(
                      100 * parseInt(meter.tipomed.N, 10) +
                      parseInt(meter.med.N, 10)
                    ).toString()}
                    value={(
                      100 * parseInt(meter.tipomed.N, 10) +
                      parseInt(meter.med.N, 10)
                    ).toString()}
                  >
                    {meter.idceb.S + " - " + meter.nome.S}
                  </option>
                ))}
              </Input>
            </Col>
          </Row>

          <Row>
            <Col md="6">
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
            <Col xs="auto">
              <Button
                className=""
                type="submit"
                size="md"
                color="primary"
                onClick={this.props.onQuery}
              >
                Pesquisar
              </Button>
            </Col>
          </Row>
        </CardBody>
      </Card>
    );
  }
}

export default FormDates;
