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

    let {
      meters,
      oneMonth,
      initialDate,
      finalDate,
      onChangeDate,
      onMeterChange,
      onChangeOneMonth,
      onQuery
    } = this.props

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
            <Col xl="3" lg="6">
              <Row style={{ marginBottom: "10px" }}>
                <Label htmlFor="initialDate" className="label-form">
                  <strong>Mês inicial:</strong>
                </Label>
                <Input
                  className="date-input"
                  name="initialDate"
                  id="initialDate"
                  type="text"
                  placeholder="mm/aaaa"
                  value={initialDate}
                  required
                  onChange={onChangeDate}
                />
              </Row>
            </Col>
            <Col xl="3" lg="6">
              <Row style={{ marginBottom: "10px" }}>
                <Label htmlFor="finalDate" className="label-form">
                  <strong>Mês final:</strong>
                </Label>
                {!oneMonth ? (
                  <Input
                    className="date-input"
                    type="text"
                    name="finalDate"
                    id="finalDate"
                    placeholder="mm/aaaa"
                    value={finalDate}
                    required
                    onChange={onChangeDate}
                  />
                ) : (
                  <Input
                    className="date-input"
                    type="text"
                    name="finalDate"
                    id="finalDate"
                    placeholder="mm/aaaa"
                    value={finalDate}
                    required
                    onChange={onChangeDate}
                    disabled
                  />
                )}
              </Row>
            </Col>
            <Col xl="6" lg="12">
              <Row style={{ marginBottom: "10px" }}>
                <Label htmlFor="chosenMeter" className="label-form">
                  <strong>Medidor:</strong>
                </Label>
                <Input
                  type="select"
                  name="chosenMeter"
                  id="exampleSelect"
                  onChange={onMeterChange}
                  className="input-meters"
                >
                  <option value="199">Todos medidores</option>
                  {meters.map(meter => (
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
                      {meter.id.S + " - " + meter.nome.S}
                    </option>
                  ))}
                </Input>
              </Row>
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
                  checked={oneMonth}
                  onChange={onChangeOneMonth}
                />
              </FormGroup>
            </Col>
          </Row>

          <Row>
            <Col xs="auto">
              <Button
                disabled={meters.length === 0}
                className=""
                type="submit"
                size="md"
                color="primary"
                onClick={onQuery}
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
