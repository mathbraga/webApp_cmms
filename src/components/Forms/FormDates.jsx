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
  Button,
  CustomInput
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
              <Row>
                <Label htmlFor="initialDate" className="label-form">
                  <strong>Mês inicial:</strong>
                </Label>
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
              </Row>
            </Col>
            <Col md="3">
              <Row>
                <Label htmlFor="finalDate" className="label-form">
                  <strong>Mês final:</strong>
                </Label>
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
              </Row>
            </Col>
            <Col md="6" style={{ display: "flex" }}>
              <Label htmlFor="chosenMeter" className="label-form">
                <strong>Medidor:</strong>
              </Label>
              <Input
                type="select"
                name="chosenMeter"
                id="exampleSelect"
                onChange={this.props.onMeterChange}
                className="input-meters"
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
            <Col>
              <FormGroup
                check
                className="checkbox"
                style={{ padding: " 15px 10px 5px 5px" }}
              >
                <CustomInput
                  type="checkbox"
                  id="oneMonth"
                  name="oneMonth"
                  label="Pesquisar somente um mês"
                  value={1}
                  onChange={this.props.onChangeOneMonth}
                />
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
                style={{ margin: "10px 20px" }}
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
