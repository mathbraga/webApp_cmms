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
  constructor(props) {
    super(props);
  }

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
                onChange={this.props.onChange}
              />
            </Col>
            <Label htmlFor="finalDate" sm={"auto"}>
              <strong>Mês final:</strong>
            </Label>
            <Col sm={2}>
              <Input
                type="text"
                name="finalDate"
                id="finalDate"
                placeholder="mm/aaaa"
                value={this.props.finalDate}
                required
                onChange={this.props.onChange}
              />
            </Col>
            <Label htmlFor="finalDate" sm={{ size: "auto", offset: 0 }}>
              <strong>Medidor:</strong>
            </Label>
            <Col sm={3.5}>
              <Input type="select" name="consumerUnit" id="exampleSelect">
                {this.props.consumerUnits.map(unit => (
                  <option value={unit.key}>
                    {unit.num} - {unit.name}
                  </option>
                ))}
              </Input>
            </Col>
            <Col>
              <Button type="submit" size="md" color="primary">
                Pesquisar
              </Button>
            </Col>
          </FormGroup>
        </CardBody>
      </Card>
    );
  }
}

export default FormDates;
